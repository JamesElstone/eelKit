<?php
/** SQLite production schema, migration, compatibility, and concurrency acceptance tests. */
declare(strict_types=1);
require_once __DIR__ . '/testFramework/ServiceClassTestHarness.php';
require_once dirname(__DIR__, 2) . '/tools/php/migrateDb.php';
$harness = new GeneratedServiceClassTestHarness();
$sqliteRoot = dirname(__DIR__, 2) . '/db_schema/sqlite';
$sqliteFiles = migrationFiles($sqliteRoot . '/migrations');

$withSqlite = static function (callable $test, bool $seed = true) use ($sqliteRoot): void {
    $property = new ReflectionProperty(InterfaceDB::class, 'connection');
    $original = $property->getValue();
    $pdo = new PDO('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]);
    SqliteDB::configure($pdo);
    $property->setValue(null, $pdo); InterfaceDB::clearMetadataCache();
    try {
        if ($seed) InterfaceDB::executeScript((string)file_get_contents($sqliteRoot . '/eelKit.schema.sql'));
        $test($pdo);
    } finally {
        if (InterfaceDB::inTransaction()) InterfaceDB::rollBack();
        $property->setValue(null, $original); InterfaceDB::clearMetadataCache();
    }
};

$harness->check(SqliteDB::class, 'preserves legacy Unicode weights, padding, expansions, and binary tokens', function () use ($harness, $withSqlite): void {
    $withSqlite(function () use ($harness): void {
        foreach ([['É','e'], ['Straße','STRASSE'], ['á','á'], ['ﬃ','ffi'], ['a ','a'], ['😀','😁']] as [$left,$right]) {
            $harness->assertSame(0, SqliteDB::compare($left, $right));
        }
        $harness->assertSame('0e33', bin2hex(SqliteDB::key('A')));
        $harness->assertSame('fffd', bin2hex(SqliteDB::key('😀')));
        InterfaceDB::execute("INSERT INTO users (display_name,email_address,current_session_token_hash) VALUES ('Unicode','É@example.test','Token')");
        $harness->assertSame(1, (int)InterfaceDB::fetchColumn("SELECT COUNT(*) FROM users WHERE email_address='e@example.test'"));
        $harness->assertSame(0, (int)InterfaceDB::fetchColumn("SELECT COUNT(*) FROM users WHERE current_session_token_hash='token'"));
        try { InterfaceDB::execute("INSERT INTO users (display_name,email_address) VALUES ('Duplicate','e@example.test')"); throw new RuntimeException('Duplicate Unicode identity was accepted.'); }
        catch (PDOException) { }
    });
});

$harness->check(SqliteDB::class, 'implements character-wise wildcard searches and escaping', function () use ($harness, $withSqlite): void {
    $withSqlite(function () use ($harness): void {
        foreach ([['é%','Éclair',1], ['_','😀',1], ['ss','ß',0], ['s_','ß',0], ['\\%','%',1], ['a','a ',0], ['%a%b%','aaxbb',1]] as [$pattern,$value,$expected]) {
            $harness->assertSame($expected, (int)InterfaceDB::fetchColumn('SELECT :value LIKE :pattern', ['value'=>$value,'pattern'=>$pattern]));
        }
        $harness->assertSame(1, (int)InterfaceDB::fetchColumn("SELECT 'a_b' LIKE 'a!_b' ESCAPE '!'"));
        $harness->assertSame(null, InterfaceDB::fetchColumn("SELECT NULL LIKE '%'"));
    });
});

$harness->check(SqliteDB::class, 'enforces enum, length, nonnegative counters, and foreign keys', function () use ($harness, $withSqlite): void {
    $withSqlite(function () use ($harness): void {
        foreach (["INSERT INTO signup_token_rate_limits (client_ip,failed_attempts) VALUES ('203.0.113.1',-1)", "INSERT INTO users (display_name) VALUES ('" . str_repeat('x',256) . "')", "INSERT INTO user_totp (user_id,otp_algorithm) VALUES (999,'MD5')"] as $sql) {
            try { InterfaceDB::execute($sql); throw new RuntimeException('Invalid data was accepted.'); } catch (PDOException) { }
        }
        InterfaceDB::execute("INSERT INTO users (display_name) VALUES ('MFA')"); $id=InterfaceDB::lastInsertId();
        InterfaceDB::execute("INSERT INTO user_totp (user_id,otp_algorithm) VALUES (:id,'sha256')", ['id'=>$id]);
        $harness->assertSame('SHA256', InterfaceDB::fetchColumn('SELECT otp_algorithm FROM user_totp WHERE user_id=:id',['id'=>$id]));
        InterfaceDB::execute('DELETE FROM users WHERE id=:id',['id'=>$id]);
        $harness->assertSame(0,(int)InterfaceDB::fetchColumn('SELECT COUNT(*) FROM user_totp'));
    });
});

$harness->check(SqliteDB::class, 'updates timestamps and supports nested write transactions with rollback', function () use ($harness, $withSqlite): void {
    $withSqlite(function () use ($harness): void {
        InterfaceDB::execute("INSERT INTO users (display_name,updated_at) VALUES ('Before','2000-01-01 00:00:00')");
        $id=InterfaceDB::lastInsertId();
        InterfaceDB::writeTransaction(function () use ($harness,$id): void {
            $harness->assertTrue(InterfaceDB::inTransaction());
            InterfaceDB::writeTransaction(static fn() => InterfaceDB::execute("UPDATE users SET display_name='After' WHERE id=:id",['id'=>$id]));
        });
        $harness->assertTrue(!InterfaceDB::inTransaction());
        $harness->assertTrue(InterfaceDB::fetchColumn('SELECT updated_at FROM users WHERE id=:id',['id'=>$id]) > '2000-01-01 00:00:00');
        try { InterfaceDB::writeTransaction(static function () use ($id): void { InterfaceDB::execute('DELETE FROM users WHERE id=:id',['id'=>$id]); throw new RuntimeException('rollback'); }); }
        catch (RuntimeException $exception) { $harness->assertSame('rollback',$exception->getMessage()); }
        $harness->assertSame(1,(int)InterfaceDB::fetchColumn('SELECT COUNT(*) FROM users'));
    });
});

$harness->check(SqliteMigrationDB::class, 'initializes an empty database and repeated setup preserves records', function () use ($harness, $withSqlite, $sqliteRoot): void {
    $withSqlite(function () use ($harness,$sqliteRoot): void {
        ob_start(); try { SqliteMigrationDB::run($sqliteRoot.'/eelKit.schema.sql',$sqliteRoot.'/migrations'); } finally { ob_end_clean(); }
        InterfaceDB::execute("INSERT INTO users (display_name) VALUES ('Persistent')");
        ob_start(); try { SqliteMigrationDB::run($sqliteRoot.'/eelKit.schema.sql',$sqliteRoot.'/migrations'); } finally { ob_end_clean(); }
        $harness->assertSame('Persistent',InterfaceDB::fetchColumn('SELECT display_name FROM users'));
        $harness->assertSame(1,(int)InterfaceDB::fetchColumn('PRAGMA foreign_keys'));
    },false);
});

foreach ($sqliteFiles as $boundary=>$file) {
    $harness->check(SqliteMigrationDB::class, 'upgrades from '.basename($file).' preserving data and issued IDs', function () use ($harness,$withSqlite,$sqliteFiles,$boundary,$sqliteRoot): void {
        $withSqlite(function () use ($harness,$sqliteFiles,$boundary,$sqliteRoot): void {
            InterfaceDB::execute('PRAGMA foreign_keys=OFF');
            foreach (array_slice($sqliteFiles,0,$boundary+1) as $migration) {
                InterfaceDB::executeScript((string)file_get_contents($migration));
                InterfaceDB::execute('INSERT INTO schema_migrations (migration) VALUES (:name)',['name'=>basename($migration)]);
            }
            InterfaceDB::execute('PRAGMA foreign_keys=ON');
            InterfaceDB::execute("INSERT INTO users (id,display_name,email_address,password_hash) VALUES (41,'Preserved','preserved@example.test','hash'),(900,'Deleted','deleted@example.test','hash')");
            InterfaceDB::execute('DELETE FROM users WHERE id=900');
            InterfaceDB::executeScript('CREATE INDEX downstream_user_name ON users(display_name); CREATE TRIGGER downstream_user_change AFTER UPDATE ON users BEGIN SELECT 1; END;');
            ob_start(); try { SqliteMigrationDB::run($sqliteRoot.'/eelKit.schema.sql',$sqliteRoot.'/migrations'); } finally { ob_end_clean(); }
            $harness->assertSame('Preserved',InterfaceDB::fetchColumn('SELECT display_name FROM users WHERE id=41'));
            InterfaceDB::execute("INSERT INTO users (display_name,email_address,password_hash) VALUES ('Next','next@example.test','hash')");
            $harness->assertTrue(InterfaceDB::lastInsertId()>900);
            $harness->assertSame(2,(int)InterfaceDB::fetchColumn("SELECT COUNT(*) FROM sqlite_master WHERE name IN ('downstream_user_name','downstream_user_change')"));
            $harness->assertSame(count($sqliteFiles),(int)InterfaceDB::fetchColumn('SELECT COUNT(*) FROM schema_migrations'));
        },false);
    });
}

$harness->check(SqliteMigrationDB::class, 'rejects partial schemas and missing integrity indexes without mutation', function () use ($harness,$withSqlite,$sqliteRoot): void {
    $withSqlite(function () use ($harness,$sqliteRoot): void {
        InterfaceDB::execute('DROP INDEX uq_users_email_address');
        try { ob_start(); SqliteMigrationDB::run($sqliteRoot.'/eelKit.schema.sql',$sqliteRoot.'/migrations'); throw new RuntimeException('Partial schema was accepted.'); }
        catch (RuntimeException $exception) { $harness->assertTrue(str_contains($exception->getMessage(),'Unrecognized partial')); }
        finally { ob_end_clean(); }
        $harness->assertSame(1,(int)InterfaceDB::fetchColumn('PRAGMA foreign_keys'));
        $harness->assertTrue(!InterfaceDB::inTransaction());
    });
});

$harness->check(SqliteDB::class, 'requires private persistent file paths and rejects invalid lock settings', function () use ($harness): void {
    foreach (['sqlite:','sqlite:file:test.sqlite','sqlite:'.__DIR__.'/bad.sqlite'] as $dsn) {
        try { SqliteDB::normaliseDsn($dsn); throw new RuntimeException('Unsafe path accepted.'); }
        catch (RuntimeException $exception) { $harness->assertTrue(!str_contains($exception->getMessage(),'Unsafe path accepted')); }
    }
    try { SqliteDB::configure(new PDO('sqlite::memory:'),['sqlite_busy_timeout_ms'=>-1]); throw new RuntimeException('Invalid timeout accepted.'); }
    catch (RuntimeException $exception) { $harness->assertTrue(str_contains($exception->getMessage(),'sqlite_busy_timeout_ms')); }
});

$harness->check(SqliteMigrationDB::class, 'rolls back failed schema changes and migration tracking together', function () use ($harness,$withSqlite,$sqliteRoot): void {
    $directory=sys_get_temp_dir().'/eelkit-migrations-'.bin2hex(random_bytes(8));mkdir($directory,0700);mkdir($directory.'/migrations',0700);
    try {
        foreach (glob($sqliteRoot.'/migrations/*.sql') as $file) copy($file,$directory.'/migrations/'.basename($file));
        $states=json_decode((string)file_get_contents($sqliteRoot.'/schema-states.json'),true,flags:JSON_THROW_ON_ERROR);
        $name='2099_01_01_001_failure.sql';$states[$name]=$states[array_key_last($states)];
        file_put_contents($directory.'/schema-states.json',json_encode($states));
        file_put_contents($directory.'/migrations/'.$name,'CREATE TABLE should_rollback(id INTEGER); INSERT INTO missing_table VALUES(1);');
        $withSqlite(function () use ($harness,$directory,$sqliteRoot,$name): void {
            $before=InterfaceDB::fetchColumn('SELECT COUNT(*) FROM schema_migrations');
            try { ob_start(); SqliteMigrationDB::run($sqliteRoot.'/eelKit.schema.sql',$directory.'/migrations');throw new RuntimeException('Broken migration was accepted.'); }
            catch (RuntimeException $exception) { $harness->assertTrue(str_contains($exception->getMessage(),$name)); }
            finally { ob_end_clean(); }
            $harness->assertTrue(!InterfaceDB::tableExists('should_rollback'));
            $harness->assertSame($before,InterfaceDB::fetchColumn('SELECT COUNT(*) FROM schema_migrations'));
            $harness->assertSame(1,(int)InterfaceDB::fetchColumn('PRAGMA foreign_keys'));
            $harness->assertTrue(!InterfaceDB::inTransaction());
        });
    } finally {
        foreach (glob($directory.'/migrations/*') ?: [] as $file) unlink($file);
        rmdir($directory.'/migrations');unlink($directory.'/schema-states.json');rmdir($directory);
    }
});

$harness->check(PdoDB::class, 'production connections reject missing files and retired fixture hydration', function () use ($harness): void {
    $directory=sys_get_temp_dir().'/eelkit-connection-'.bin2hex(random_bytes(8));mkdir($directory,0700);
    $instance=(new ReflectionMethod(PdoDB::class,'getInstance'))->invoke(null);
    $property=new ReflectionProperty(PdoDB::class,'dbConfig');$original=$property->getValue($instance);
    $connect=new ReflectionMethod(PdoDB::class,'connect');$path=$directory.'/missing.sqlite';
    try {
        $property->setValue($instance,['dsn'=>'sqlite:'.$path]);
        try { $connect->invoke(null);throw new RuntimeException('Missing database was silently created.'); }
        catch (RuntimeException $exception) { $harness->assertTrue(str_contains($exception->getMessage(),'does not exist')); }
        $harness->assertTrue(!is_file($path));
        SqliteDB::createDatabase('sqlite:'.$path);
        $property->setValue($instance,['dsn'=>'sqlite:'.$path,'sqlite_schema'=>'anything']);
        try { $connect->invoke(null);throw new RuntimeException('Fixture hydration was accepted.'); }
        catch (RuntimeException $exception) { $harness->assertTrue(str_contains($exception->getMessage(),'retired test fixture')); }
    } finally {
        $property->setValue($instance,$original);
        foreach ([$path,$path.'-wal',$path.'-shm'] as $file) if (is_file($file)) unlink($file);
        rmdir($directory);
    }
});

$harness->check(SqliteDB::class, 'serializes real concurrent counters and IDs, permits readers, and bounds lock waits', function () use ($harness): void {
    $directory=sys_get_temp_dir().'/eelkit-sqlite-'.bin2hex(random_bytes(8)); mkdir($directory,0700);
    $path=$directory.'/test.sqlite';
    $property=new ReflectionProperty(InterfaceDB::class,'connection');$original=$property->getValue();
    $processes=[];$pdo=null;
    try {
        SqliteDB::createDatabase('sqlite:'.$path);
        $pdo=new PDO('sqlite:'.$path,null,null,[PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
        eel_test_database_fixture($pdo);
        $worker=__DIR__.'/testFramework/SqliteConcurrencyWorker.php';
        $environment=getenv(); unset($environment['EELKIT_TEST_DATABASE']);
        for ($i=0;$i<4;$i++) {
            $process=proc_open([PHP_BINARY,$worker,$path],[0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']],$pipes,null,$environment);
            if (!is_resource($process)) throw new RuntimeException('Concurrency worker could not start.');
            fclose($pipes[0]);$processes[]=[$process,$pipes];
        }
        $ids=[];
        foreach ($processes as [$process,$pipes]) {
            $output=stream_get_contents($pipes[1]);$errors=stream_get_contents($pipes[2]);fclose($pipes[1]);fclose($pipes[2]);
            if (proc_close($process)!==0) throw new RuntimeException('Concurrency worker failed: '.$errors.$output);
            $ids[]=(int)$output;
        }
        $processes=[];
        $harness->assertSame(4,count(array_unique($ids)));
        $harness->assertSame(12,(int)InterfaceDB::fetchColumn('SELECT failed_attempts FROM signup_token_rate_limits'));
        InterfaceDB::beginWriteTransaction();
        $reader=new PDO('sqlite:'.$path);$harness->assertSame(4,(int)$reader->query('SELECT COUNT(*) FROM users')->fetchColumn());$reader=null;
        $process=proc_open([PHP_BINARY,$worker,$path,'timeout'],[0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']],$pipes,null,$environment);fclose($pipes[0]);
        $output=stream_get_contents($pipes[1]);$errors=stream_get_contents($pipes[2]);fclose($pipes[1]);fclose($pipes[2]);
        $harness->assertSame(0,proc_close($process));$harness->assertSame('busy',$output);$harness->assertSame('',$errors);
        InterfaceDB::rollBack();
        InterfaceDB::execute("INSERT INTO users (display_name,email_address,mobile_number,is_active,account_status) VALUES ('Pending','once@example.test','+447700900123',0,'pending_invitation')");
        $userId=InterfaceDB::lastInsertId();
        InterfaceDB::execute("INSERT INTO user_account_invites (user_id,token_hash,status,expires_at) VALUES (:user,:hash,'verified',:expires)",['user'=>$userId,'hash'=>hash('sha256','one-time-test'),'expires'=>(new DateTimeImmutable('now'))->modify('+1 day')->format('Y-m-d H:i:s')]);
        $inviteId=InterfaceDB::lastInsertId();
        for ($i=0;$i<2;$i++) {
            $process=proc_open([PHP_BINARY,$worker,$path,'complete',(string)$inviteId,(string)$userId],[0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']],$pipes,null,$environment);
            fclose($pipes[0]);$processes[]=[$process,$pipes];
        }
        $completed=0;
        foreach ($processes as [$process,$pipes]) {
            $output=stream_get_contents($pipes[1]);$errors=stream_get_contents($pipes[2]);fclose($pipes[1]);fclose($pipes[2]);
            if (proc_close($process)!==0 || !in_array($output,['0','1'],true)) throw new RuntimeException('Completion worker failed: '.$errors.$output);
            $completed+=(int)$output;
        }
        $processes=[];$harness->assertSame(1,$completed);
        $harness->assertSame('completed',InterfaceDB::fetchColumn('SELECT status FROM user_account_invites WHERE id=:id',['id'=>$inviteId]));
        $harness->assertSame(1,(int)InterfaceDB::fetchColumn("SELECT COUNT(*) FROM user_account_audit WHERE affected_user_id=:id AND action_type='invite_completed'",['id'=>$userId]));
        $property->setValue(null,$original);$pdo=null;
        $reopened=new PDO('sqlite:'.$path);$harness->assertSame(5,(int)$reopened->query('SELECT COUNT(*) FROM users')->fetchColumn());$reopened=null;
    } finally {
        if (InterfaceDB::inTransaction()) InterfaceDB::rollBack();
        foreach ($processes as [$process,$pipes]) { if (is_resource($process)) { proc_terminate($process);proc_close($process); } }
        $property->setValue(null,$original);InterfaceDB::clearMetadataCache();$pdo=null;
        foreach ([$path,$path.'-wal',$path.'-shm',$path.'.keys'] as $file) if (is_file($file)) unlink($file);
        rmdir($directory);
    }
});
