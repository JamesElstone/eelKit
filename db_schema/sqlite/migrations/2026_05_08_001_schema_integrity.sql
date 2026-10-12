-- Native SQLite equivalent of 2026_05_08_001_schema_integrity.sql
CREATE TABLE "__eelkit_users" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -2147483648 AND 2147483647),
  "display_name" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("display_name" IS NULL OR eelkit_char_length("display_name") <= 255),
  "email_address" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("email_address" IS NULL OR eelkit_char_length("email_address") <= 255),
  "password_hash" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("password_hash" IS NULL OR eelkit_char_length("password_hash") <= 255),
  "current_session_token_hash" TEXT COLLATE BINARY DEFAULT NULL CHECK ("current_session_token_hash" IS NULL OR eelkit_char_length("current_session_token_hash") <= 64 AND eelkit_ascii("current_session_token_hash")),
  "current_session_started_at" TEXT DEFAULT NULL,
  "current_session_last_seen_at" TEXT DEFAULT NULL,
  "current_session_device_id" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("current_session_device_id" IS NULL OR eelkit_char_length("current_session_device_id") <= 64),
  "current_session_ip_address" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("current_session_ip_address" IS NULL OR eelkit_char_length("current_session_ip_address") <= 45),
  "current_session_user_agent" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("current_session_user_agent" IS NULL OR eelkit_char_length("current_session_user_agent") <= 1000),
  "current_session_browser_label" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("current_session_browser_label" IS NULL OR eelkit_char_length("current_session_browser_label") <= 255),
  "last_login_at" TEXT DEFAULT NULL,
  "password_changed_at" TEXT DEFAULT NULL,
  "is_active" INTEGER NOT NULL DEFAULT 1 CHECK ("is_active" IS NULL OR (typeof("is_active") = 'integer' AND "is_active" BETWEEN -128 AND 127)),
  "role_id" INTEGER NOT NULL DEFAULT -1 CHECK ("role_id" IS NULL OR (typeof("role_id") = 'integer' AND "role_id" BETWEEN -2147483648 AND 2147483647)),
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "__eelkit_users" ("id","display_name","email_address","password_hash","current_session_token_hash","current_session_started_at","current_session_last_seen_at","current_session_device_id","current_session_ip_address","current_session_user_agent","current_session_browser_label","last_login_at","password_changed_at","is_active","role_id","created_at","updated_at") SELECT "id","display_name","email_address","password_hash","current_session_token_hash","current_session_started_at","current_session_last_seen_at","current_session_device_id","current_session_ip_address","current_session_user_agent","current_session_browser_label","last_login_at","password_changed_at","is_active","role_id","created_at","updated_at" FROM "users";
DROP TABLE "users";
ALTER TABLE "__eelkit_users" RENAME TO "users";
CREATE UNIQUE INDEX "uq_users_email_address" ON "users" ("email_address");
CREATE UNIQUE INDEX "uq_users_current_session_token_hash" ON "users" ("current_session_token_hash");
CREATE INDEX "idx_users_role_id" ON "users" ("role_id");
CREATE TRIGGER "eelkit_users_updated_at" AFTER UPDATE ON "users"
WHEN NEW.updated_at IS OLD.updated_at AND (NEW."id" COLLATE BINARY IS NOT OLD."id" COLLATE BINARY OR NEW."display_name" COLLATE BINARY IS NOT OLD."display_name" COLLATE BINARY OR NEW."email_address" COLLATE BINARY IS NOT OLD."email_address" COLLATE BINARY OR NEW."password_hash" COLLATE BINARY IS NOT OLD."password_hash" COLLATE BINARY OR NEW."current_session_token_hash" COLLATE BINARY IS NOT OLD."current_session_token_hash" COLLATE BINARY OR NEW."current_session_started_at" COLLATE BINARY IS NOT OLD."current_session_started_at" COLLATE BINARY OR NEW."current_session_last_seen_at" COLLATE BINARY IS NOT OLD."current_session_last_seen_at" COLLATE BINARY OR NEW."current_session_device_id" COLLATE BINARY IS NOT OLD."current_session_device_id" COLLATE BINARY OR NEW."current_session_ip_address" COLLATE BINARY IS NOT OLD."current_session_ip_address" COLLATE BINARY OR NEW."current_session_user_agent" COLLATE BINARY IS NOT OLD."current_session_user_agent" COLLATE BINARY OR NEW."current_session_browser_label" COLLATE BINARY IS NOT OLD."current_session_browser_label" COLLATE BINARY OR NEW."last_login_at" COLLATE BINARY IS NOT OLD."last_login_at" COLLATE BINARY OR NEW."password_changed_at" COLLATE BINARY IS NOT OLD."password_changed_at" COLLATE BINARY OR NEW."is_active" COLLATE BINARY IS NOT OLD."is_active" COLLATE BINARY OR NEW."role_id" COLLATE BINARY IS NOT OLD."role_id" COLLATE BINARY OR NEW."created_at" COLLATE BINARY IS NOT OLD."created_at" COLLATE BINARY)
BEGIN
  UPDATE "users" SET updated_at = CURRENT_TIMESTAMP WHERE "id" = NEW."id";
END;
CREATE TABLE "__eelkit_users" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -2147483648 AND 2147483647),
  "display_name" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("display_name" IS NULL OR eelkit_char_length("display_name") <= 255),
  "email_address" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("email_address" IS NULL OR eelkit_char_length("email_address") <= 255),
  "password_hash" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("password_hash" IS NULL OR eelkit_char_length("password_hash") <= 255),
  "current_session_token_hash" TEXT COLLATE BINARY DEFAULT NULL CHECK ("current_session_token_hash" IS NULL OR eelkit_char_length("current_session_token_hash") <= 64 AND eelkit_ascii("current_session_token_hash")),
  "current_session_started_at" TEXT DEFAULT NULL,
  "current_session_last_seen_at" TEXT DEFAULT NULL,
  "current_session_device_id" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("current_session_device_id" IS NULL OR eelkit_char_length("current_session_device_id") <= 64),
  "current_session_ip_address" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("current_session_ip_address" IS NULL OR eelkit_char_length("current_session_ip_address") <= 45),
  "current_session_user_agent" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("current_session_user_agent" IS NULL OR eelkit_char_length("current_session_user_agent") <= 1000),
  "current_session_browser_label" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("current_session_browser_label" IS NULL OR eelkit_char_length("current_session_browser_label") <= 255),
  "last_login_at" TEXT DEFAULT NULL,
  "password_changed_at" TEXT DEFAULT NULL,
  "is_active" INTEGER NOT NULL DEFAULT 1 CHECK ("is_active" IS NULL OR (typeof("is_active") = 'integer' AND "is_active" BETWEEN -128 AND 127)),
  "role_id" INTEGER NOT NULL DEFAULT -1 CHECK ("role_id" IS NULL OR (typeof("role_id") = 'integer' AND "role_id" BETWEEN -2147483648 AND 2147483647)),
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_users_email_address_not_blank
  CHECK (email_address <> '')
);
INSERT INTO "__eelkit_users" ("id","display_name","email_address","password_hash","current_session_token_hash","current_session_started_at","current_session_last_seen_at","current_session_device_id","current_session_ip_address","current_session_user_agent","current_session_browser_label","last_login_at","password_changed_at","is_active","role_id","created_at","updated_at") SELECT "id","display_name","email_address","password_hash","current_session_token_hash","current_session_started_at","current_session_last_seen_at","current_session_device_id","current_session_ip_address","current_session_user_agent","current_session_browser_label","last_login_at","password_changed_at","is_active","role_id","created_at","updated_at" FROM "users";
DROP TABLE "users";
ALTER TABLE "__eelkit_users" RENAME TO "users";
CREATE UNIQUE INDEX "uq_users_email_address" ON "users" ("email_address");
CREATE UNIQUE INDEX "uq_users_current_session_token_hash" ON "users" ("current_session_token_hash");
CREATE INDEX "idx_users_role_id" ON "users" ("role_id");
CREATE TRIGGER "eelkit_users_updated_at" AFTER UPDATE ON "users"
WHEN NEW.updated_at IS OLD.updated_at AND (NEW."id" COLLATE BINARY IS NOT OLD."id" COLLATE BINARY OR NEW."display_name" COLLATE BINARY IS NOT OLD."display_name" COLLATE BINARY OR NEW."email_address" COLLATE BINARY IS NOT OLD."email_address" COLLATE BINARY OR NEW."password_hash" COLLATE BINARY IS NOT OLD."password_hash" COLLATE BINARY OR NEW."current_session_token_hash" COLLATE BINARY IS NOT OLD."current_session_token_hash" COLLATE BINARY OR NEW."current_session_started_at" COLLATE BINARY IS NOT OLD."current_session_started_at" COLLATE BINARY OR NEW."current_session_last_seen_at" COLLATE BINARY IS NOT OLD."current_session_last_seen_at" COLLATE BINARY OR NEW."current_session_device_id" COLLATE BINARY IS NOT OLD."current_session_device_id" COLLATE BINARY OR NEW."current_session_ip_address" COLLATE BINARY IS NOT OLD."current_session_ip_address" COLLATE BINARY OR NEW."current_session_user_agent" COLLATE BINARY IS NOT OLD."current_session_user_agent" COLLATE BINARY OR NEW."current_session_browser_label" COLLATE BINARY IS NOT OLD."current_session_browser_label" COLLATE BINARY OR NEW."last_login_at" COLLATE BINARY IS NOT OLD."last_login_at" COLLATE BINARY OR NEW."password_changed_at" COLLATE BINARY IS NOT OLD."password_changed_at" COLLATE BINARY OR NEW."is_active" COLLATE BINARY IS NOT OLD."is_active" COLLATE BINARY OR NEW."role_id" COLLATE BINARY IS NOT OLD."role_id" COLLATE BINARY OR NEW."created_at" COLLATE BINARY IS NOT OLD."created_at" COLLATE BINARY)
BEGIN
  UPDATE "users" SET updated_at = CURRENT_TIMESTAMP WHERE "id" = NEW."id";
END;
CREATE TABLE "__eelkit_users" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -2147483648 AND 2147483647),
  "display_name" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("display_name" IS NULL OR eelkit_char_length("display_name") <= 255),
  "email_address" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("email_address" IS NULL OR eelkit_char_length("email_address") <= 255),
  "password_hash" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("password_hash" IS NULL OR eelkit_char_length("password_hash") <= 255),
  "current_session_token_hash" TEXT COLLATE BINARY DEFAULT NULL CHECK ("current_session_token_hash" IS NULL OR eelkit_char_length("current_session_token_hash") <= 64 AND eelkit_ascii("current_session_token_hash")),
  "current_session_started_at" TEXT DEFAULT NULL,
  "current_session_last_seen_at" TEXT DEFAULT NULL,
  "current_session_device_id" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("current_session_device_id" IS NULL OR eelkit_char_length("current_session_device_id") <= 64),
  "current_session_ip_address" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("current_session_ip_address" IS NULL OR eelkit_char_length("current_session_ip_address") <= 45),
  "current_session_user_agent" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("current_session_user_agent" IS NULL OR eelkit_char_length("current_session_user_agent") <= 1000),
  "current_session_browser_label" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("current_session_browser_label" IS NULL OR eelkit_char_length("current_session_browser_label") <= 255),
  "last_login_at" TEXT DEFAULT NULL,
  "password_changed_at" TEXT DEFAULT NULL,
  "is_active" INTEGER NOT NULL DEFAULT 1 CHECK ("is_active" IS NULL OR (typeof("is_active") = 'integer' AND "is_active" BETWEEN -128 AND 127)),
  "role_id" INTEGER NOT NULL DEFAULT -1 CHECK ("role_id" IS NULL OR (typeof("role_id") = 'integer' AND "role_id" BETWEEN -2147483648 AND 2147483647)),
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_users_email_address_not_blank
  CHECK (email_address <> ''),
  CONSTRAINT chk_users_role_id_reserved_or_positive
  CHECK (role_id = -1 OR role_id > 0)
);
INSERT INTO "__eelkit_users" ("id","display_name","email_address","password_hash","current_session_token_hash","current_session_started_at","current_session_last_seen_at","current_session_device_id","current_session_ip_address","current_session_user_agent","current_session_browser_label","last_login_at","password_changed_at","is_active","role_id","created_at","updated_at") SELECT "id","display_name","email_address","password_hash","current_session_token_hash","current_session_started_at","current_session_last_seen_at","current_session_device_id","current_session_ip_address","current_session_user_agent","current_session_browser_label","last_login_at","password_changed_at","is_active","role_id","created_at","updated_at" FROM "users";
DROP TABLE "users";
ALTER TABLE "__eelkit_users" RENAME TO "users";
CREATE UNIQUE INDEX "uq_users_email_address" ON "users" ("email_address");
CREATE UNIQUE INDEX "uq_users_current_session_token_hash" ON "users" ("current_session_token_hash");
CREATE INDEX "idx_users_role_id" ON "users" ("role_id");
CREATE TRIGGER "eelkit_users_updated_at" AFTER UPDATE ON "users"
WHEN NEW.updated_at IS OLD.updated_at AND (NEW."id" COLLATE BINARY IS NOT OLD."id" COLLATE BINARY OR NEW."display_name" COLLATE BINARY IS NOT OLD."display_name" COLLATE BINARY OR NEW."email_address" COLLATE BINARY IS NOT OLD."email_address" COLLATE BINARY OR NEW."password_hash" COLLATE BINARY IS NOT OLD."password_hash" COLLATE BINARY OR NEW."current_session_token_hash" COLLATE BINARY IS NOT OLD."current_session_token_hash" COLLATE BINARY OR NEW."current_session_started_at" COLLATE BINARY IS NOT OLD."current_session_started_at" COLLATE BINARY OR NEW."current_session_last_seen_at" COLLATE BINARY IS NOT OLD."current_session_last_seen_at" COLLATE BINARY OR NEW."current_session_device_id" COLLATE BINARY IS NOT OLD."current_session_device_id" COLLATE BINARY OR NEW."current_session_ip_address" COLLATE BINARY IS NOT OLD."current_session_ip_address" COLLATE BINARY OR NEW."current_session_user_agent" COLLATE BINARY IS NOT OLD."current_session_user_agent" COLLATE BINARY OR NEW."current_session_browser_label" COLLATE BINARY IS NOT OLD."current_session_browser_label" COLLATE BINARY OR NEW."last_login_at" COLLATE BINARY IS NOT OLD."last_login_at" COLLATE BINARY OR NEW."password_changed_at" COLLATE BINARY IS NOT OLD."password_changed_at" COLLATE BINARY OR NEW."is_active" COLLATE BINARY IS NOT OLD."is_active" COLLATE BINARY OR NEW."role_id" COLLATE BINARY IS NOT OLD."role_id" COLLATE BINARY OR NEW."created_at" COLLATE BINARY IS NOT OLD."created_at" COLLATE BINARY)
BEGIN
  UPDATE "users" SET updated_at = CURRENT_TIMESTAMP WHERE "id" = NEW."id";
END;
CREATE TABLE "__eelkit_role_card_permissions" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -2147483648 AND 2147483647),
  "role_id" INTEGER NOT NULL CHECK ("role_id" IS NULL OR (typeof("role_id") = 'integer' AND "role_id" BETWEEN -2147483648 AND 2147483647)),
  "card_key" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("card_key" IS NULL OR eelkit_char_length("card_key") <= 255),
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "fk_role_card_permissions_role" FOREIGN KEY ("role_id") REFERENCES "roles" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_role_card_permissions_card_key_not_blank
  CHECK (card_key <> '')
);
INSERT INTO "__eelkit_role_card_permissions" ("id","role_id","card_key","created_at") SELECT "id","role_id","card_key","created_at" FROM "role_card_permissions";
DROP TABLE "role_card_permissions";
ALTER TABLE "__eelkit_role_card_permissions" RENAME TO "role_card_permissions";
CREATE UNIQUE INDEX "uq_role_card_permissions_role_card" ON "role_card_permissions" ("role_id","card_key");
CREATE INDEX "idx_role_card_permissions_card_key" ON "role_card_permissions" ("card_key");
CREATE TABLE "__eelkit_user_login_rate_limits" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN 0 AND 4294967295),
  "email_address" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("email_address" IS NULL OR eelkit_char_length("email_address") <= 255),
  "scope_type" TEXT COLLATE eelkit_unicode_ci NOT NULL DEFAULT 'email' CHECK ("scope_type" IS NULL OR eelkit_char_length("scope_type") <= 20),
  "scope_key" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("scope_key" IS NULL OR eelkit_char_length("scope_key") <= 255),
  "user_id" INTEGER DEFAULT NULL CHECK ("user_id" IS NULL OR (typeof("user_id") = 'integer' AND "user_id" BETWEEN -2147483648 AND 2147483647)),
  "consecutive_failed_password_attempts" INTEGER NOT NULL DEFAULT 0 CHECK ("consecutive_failed_password_attempts" IS NULL OR (typeof("consecutive_failed_password_attempts") = 'integer' AND "consecutive_failed_password_attempts" BETWEEN 0 AND 4294967295)),
  "failed_attempt_window_started_at" TEXT DEFAULT NULL,
  "last_failed_password_attempt_at" TEXT DEFAULT NULL,
  "next_allowed_login_at" TEXT DEFAULT NULL,
  "locked_at" TEXT DEFAULT NULL,
  "lock_reason" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("lock_reason" IS NULL OR eelkit_char_length("lock_reason") <= 100),
  "lock_expires_at" TEXT DEFAULT NULL,
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "fk_user_login_rate_limits_user" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_user_login_rate_limits_email_address_not_blank
  CHECK (email_address <> '')
);
INSERT INTO "__eelkit_user_login_rate_limits" ("id","email_address","scope_type","scope_key","user_id","consecutive_failed_password_attempts","failed_attempt_window_started_at","last_failed_password_attempt_at","next_allowed_login_at","locked_at","lock_reason","lock_expires_at","created_at","updated_at") SELECT "id","email_address","scope_type","scope_key","user_id","consecutive_failed_password_attempts","failed_attempt_window_started_at","last_failed_password_attempt_at","next_allowed_login_at","locked_at","lock_reason","lock_expires_at","created_at","updated_at" FROM "user_login_rate_limits";
DROP TABLE "user_login_rate_limits";
ALTER TABLE "__eelkit_user_login_rate_limits" RENAME TO "user_login_rate_limits";
CREATE UNIQUE INDEX "uq_user_login_rate_limits_scope" ON "user_login_rate_limits" ("scope_type","scope_key");
CREATE INDEX "idx_user_login_rate_limits_email_address" ON "user_login_rate_limits" ("email_address");
CREATE INDEX "idx_user_login_rate_limits_user_id" ON "user_login_rate_limits" ("user_id");
CREATE INDEX "idx_user_login_rate_limits_next_allowed_login_at" ON "user_login_rate_limits" ("next_allowed_login_at");
CREATE INDEX "idx_user_login_rate_limits_locked_at" ON "user_login_rate_limits" ("locked_at");
CREATE INDEX "idx_user_login_rate_limits_lock_expires_at" ON "user_login_rate_limits" ("lock_expires_at");
CREATE TRIGGER "eelkit_user_login_rate_limits_updated_at" AFTER UPDATE ON "user_login_rate_limits"
WHEN NEW.updated_at IS OLD.updated_at AND (NEW."id" COLLATE BINARY IS NOT OLD."id" COLLATE BINARY OR NEW."email_address" COLLATE BINARY IS NOT OLD."email_address" COLLATE BINARY OR NEW."scope_type" COLLATE BINARY IS NOT OLD."scope_type" COLLATE BINARY OR NEW."scope_key" COLLATE BINARY IS NOT OLD."scope_key" COLLATE BINARY OR NEW."user_id" COLLATE BINARY IS NOT OLD."user_id" COLLATE BINARY OR NEW."consecutive_failed_password_attempts" COLLATE BINARY IS NOT OLD."consecutive_failed_password_attempts" COLLATE BINARY OR NEW."failed_attempt_window_started_at" COLLATE BINARY IS NOT OLD."failed_attempt_window_started_at" COLLATE BINARY OR NEW."last_failed_password_attempt_at" COLLATE BINARY IS NOT OLD."last_failed_password_attempt_at" COLLATE BINARY OR NEW."next_allowed_login_at" COLLATE BINARY IS NOT OLD."next_allowed_login_at" COLLATE BINARY OR NEW."locked_at" COLLATE BINARY IS NOT OLD."locked_at" COLLATE BINARY OR NEW."lock_reason" COLLATE BINARY IS NOT OLD."lock_reason" COLLATE BINARY OR NEW."lock_expires_at" COLLATE BINARY IS NOT OLD."lock_expires_at" COLLATE BINARY OR NEW."created_at" COLLATE BINARY IS NOT OLD."created_at" COLLATE BINARY)
BEGIN
  UPDATE "user_login_rate_limits" SET updated_at = CURRENT_TIMESTAMP WHERE "id" = NEW."id";
END;
CREATE TABLE "__eelkit_user_login_rate_limits" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN 0 AND 4294967295),
  "email_address" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("email_address" IS NULL OR eelkit_char_length("email_address") <= 255),
  "scope_type" TEXT COLLATE eelkit_unicode_ci NOT NULL DEFAULT 'email' CHECK ("scope_type" IS NULL OR eelkit_char_length("scope_type") <= 20),
  "scope_key" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("scope_key" IS NULL OR eelkit_char_length("scope_key") <= 255),
  "user_id" INTEGER DEFAULT NULL CHECK ("user_id" IS NULL OR (typeof("user_id") = 'integer' AND "user_id" BETWEEN -2147483648 AND 2147483647)),
  "consecutive_failed_password_attempts" INTEGER NOT NULL DEFAULT 0 CHECK ("consecutive_failed_password_attempts" IS NULL OR (typeof("consecutive_failed_password_attempts") = 'integer' AND "consecutive_failed_password_attempts" BETWEEN 0 AND 4294967295)),
  "failed_attempt_window_started_at" TEXT DEFAULT NULL,
  "last_failed_password_attempt_at" TEXT DEFAULT NULL,
  "next_allowed_login_at" TEXT DEFAULT NULL,
  "locked_at" TEXT DEFAULT NULL,
  "lock_reason" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("lock_reason" IS NULL OR eelkit_char_length("lock_reason") <= 100),
  "lock_expires_at" TEXT DEFAULT NULL,
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "fk_user_login_rate_limits_user" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_user_login_rate_limits_email_address_not_blank
  CHECK (email_address <> ''),
  CONSTRAINT chk_user_login_rate_limits_scope_type_not_blank
  CHECK (scope_type <> '')
);
INSERT INTO "__eelkit_user_login_rate_limits" ("id","email_address","scope_type","scope_key","user_id","consecutive_failed_password_attempts","failed_attempt_window_started_at","last_failed_password_attempt_at","next_allowed_login_at","locked_at","lock_reason","lock_expires_at","created_at","updated_at") SELECT "id","email_address","scope_type","scope_key","user_id","consecutive_failed_password_attempts","failed_attempt_window_started_at","last_failed_password_attempt_at","next_allowed_login_at","locked_at","lock_reason","lock_expires_at","created_at","updated_at" FROM "user_login_rate_limits";
DROP TABLE "user_login_rate_limits";
ALTER TABLE "__eelkit_user_login_rate_limits" RENAME TO "user_login_rate_limits";
CREATE UNIQUE INDEX "uq_user_login_rate_limits_scope" ON "user_login_rate_limits" ("scope_type","scope_key");
CREATE INDEX "idx_user_login_rate_limits_email_address" ON "user_login_rate_limits" ("email_address");
CREATE INDEX "idx_user_login_rate_limits_user_id" ON "user_login_rate_limits" ("user_id");
CREATE INDEX "idx_user_login_rate_limits_next_allowed_login_at" ON "user_login_rate_limits" ("next_allowed_login_at");
CREATE INDEX "idx_user_login_rate_limits_locked_at" ON "user_login_rate_limits" ("locked_at");
CREATE INDEX "idx_user_login_rate_limits_lock_expires_at" ON "user_login_rate_limits" ("lock_expires_at");
CREATE TRIGGER "eelkit_user_login_rate_limits_updated_at" AFTER UPDATE ON "user_login_rate_limits"
WHEN NEW.updated_at IS OLD.updated_at AND (NEW."id" COLLATE BINARY IS NOT OLD."id" COLLATE BINARY OR NEW."email_address" COLLATE BINARY IS NOT OLD."email_address" COLLATE BINARY OR NEW."scope_type" COLLATE BINARY IS NOT OLD."scope_type" COLLATE BINARY OR NEW."scope_key" COLLATE BINARY IS NOT OLD."scope_key" COLLATE BINARY OR NEW."user_id" COLLATE BINARY IS NOT OLD."user_id" COLLATE BINARY OR NEW."consecutive_failed_password_attempts" COLLATE BINARY IS NOT OLD."consecutive_failed_password_attempts" COLLATE BINARY OR NEW."failed_attempt_window_started_at" COLLATE BINARY IS NOT OLD."failed_attempt_window_started_at" COLLATE BINARY OR NEW."last_failed_password_attempt_at" COLLATE BINARY IS NOT OLD."last_failed_password_attempt_at" COLLATE BINARY OR NEW."next_allowed_login_at" COLLATE BINARY IS NOT OLD."next_allowed_login_at" COLLATE BINARY OR NEW."locked_at" COLLATE BINARY IS NOT OLD."locked_at" COLLATE BINARY OR NEW."lock_reason" COLLATE BINARY IS NOT OLD."lock_reason" COLLATE BINARY OR NEW."lock_expires_at" COLLATE BINARY IS NOT OLD."lock_expires_at" COLLATE BINARY OR NEW."created_at" COLLATE BINARY IS NOT OLD."created_at" COLLATE BINARY)
BEGIN
  UPDATE "user_login_rate_limits" SET updated_at = CURRENT_TIMESTAMP WHERE "id" = NEW."id";
END;
CREATE TABLE "__eelkit_user_account_audit" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -9223372036854775808 AND 9223372036854775807),
  "affected_user_id" INTEGER NOT NULL CHECK ("affected_user_id" IS NULL OR (typeof("affected_user_id") = 'integer' AND "affected_user_id" BETWEEN -2147483648 AND 2147483647)),
  "actor_user_id" INTEGER DEFAULT NULL CHECK ("actor_user_id" IS NULL OR (typeof("actor_user_id") = 'integer' AND "actor_user_id" BETWEEN -2147483648 AND 2147483647)),
  "action_type" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("action_type" IS NULL OR "action_type" IN ('user_created','user_enabled','user_disabled','password_set_admin','password_changed_self','email_changed','display_name_changed','otp_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed')),
  "reason" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("reason" IS NULL OR eelkit_char_length("reason") <= 255),
  "details_json" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("details_json" IS NULL OR eelkit_valid_utf8("details_json")),
  "device_id" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("device_id" IS NULL OR eelkit_char_length("device_id") <= 64),
  "ip_address" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("ip_address" IS NULL OR eelkit_char_length("ip_address") <= 45),
  "user_agent" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("user_agent" IS NULL OR eelkit_char_length("user_agent") <= 1000),
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "fk_user_account_audit_affected_user" FOREIGN KEY ("affected_user_id") REFERENCES "users" ("id") ON DELETE RESTRICT ON UPDATE CASCADE
);
INSERT INTO "__eelkit_user_account_audit" ("id","affected_user_id","actor_user_id","action_type","reason","details_json","device_id","ip_address","user_agent","created_at") SELECT "id","affected_user_id","actor_user_id","action_type","reason","details_json","device_id","ip_address","user_agent","created_at" FROM "user_account_audit";
DROP TABLE "user_account_audit";
ALTER TABLE "__eelkit_user_account_audit" RENAME TO "user_account_audit";
CREATE INDEX "idx_user_account_audit_affected_time" ON "user_account_audit" ("affected_user_id","created_at");
CREATE INDEX "idx_user_account_audit_actor_time" ON "user_account_audit" ("actor_user_id","created_at");
CREATE INDEX "idx_user_account_audit_action_time" ON "user_account_audit" ("action_type","created_at");
CREATE TRIGGER "eelkit_user_account_audit_enum_insert" AFTER INSERT ON "user_account_audit"
WHEN (NEW."action_type" IS NOT NULL AND NEW."action_type" COLLATE BINARY NOT IN ('user_created','user_enabled','user_disabled','password_set_admin','password_changed_self','email_changed','display_name_changed','otp_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed'))
BEGIN
  UPDATE "user_account_audit" SET "action_type" = CASE WHEN NEW."action_type" = 'user_created' THEN 'user_created' WHEN NEW."action_type" = 'user_enabled' THEN 'user_enabled' WHEN NEW."action_type" = 'user_disabled' THEN 'user_disabled' WHEN NEW."action_type" = 'password_set_admin' THEN 'password_set_admin' WHEN NEW."action_type" = 'password_changed_self' THEN 'password_changed_self' WHEN NEW."action_type" = 'email_changed' THEN 'email_changed' WHEN NEW."action_type" = 'display_name_changed' THEN 'display_name_changed' WHEN NEW."action_type" = 'otp_reset_admin' THEN 'otp_reset_admin' WHEN NEW."action_type" = 'otp_rotation_started' THEN 'otp_rotation_started' WHEN NEW."action_type" = 'otp_rotation_completed' THEN 'otp_rotation_completed' WHEN NEW."action_type" = 'mfa_authenticated' THEN 'mfa_authenticated' WHEN NEW."action_type" = 'role_changed' THEN 'role_changed' ELSE NEW."action_type" END WHERE "id" = NEW."id";
END;
CREATE TRIGGER "eelkit_user_account_audit_enum_update" AFTER UPDATE ON "user_account_audit"
WHEN (NEW."action_type" IS NOT NULL AND NEW."action_type" COLLATE BINARY NOT IN ('user_created','user_enabled','user_disabled','password_set_admin','password_changed_self','email_changed','display_name_changed','otp_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed'))
BEGIN
  UPDATE "user_account_audit" SET "action_type" = CASE WHEN NEW."action_type" = 'user_created' THEN 'user_created' WHEN NEW."action_type" = 'user_enabled' THEN 'user_enabled' WHEN NEW."action_type" = 'user_disabled' THEN 'user_disabled' WHEN NEW."action_type" = 'password_set_admin' THEN 'password_set_admin' WHEN NEW."action_type" = 'password_changed_self' THEN 'password_changed_self' WHEN NEW."action_type" = 'email_changed' THEN 'email_changed' WHEN NEW."action_type" = 'display_name_changed' THEN 'display_name_changed' WHEN NEW."action_type" = 'otp_reset_admin' THEN 'otp_reset_admin' WHEN NEW."action_type" = 'otp_rotation_started' THEN 'otp_rotation_started' WHEN NEW."action_type" = 'otp_rotation_completed' THEN 'otp_rotation_completed' WHEN NEW."action_type" = 'mfa_authenticated' THEN 'mfa_authenticated' WHEN NEW."action_type" = 'role_changed' THEN 'role_changed' ELSE NEW."action_type" END WHERE "id" = NEW."id";
END;
CREATE TABLE "__eelkit_user_account_audit" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -9223372036854775808 AND 9223372036854775807),
  "affected_user_id" INTEGER NOT NULL CHECK ("affected_user_id" IS NULL OR (typeof("affected_user_id") = 'integer' AND "affected_user_id" BETWEEN -2147483648 AND 2147483647)),
  "actor_user_id" INTEGER DEFAULT NULL CHECK ("actor_user_id" IS NULL OR (typeof("actor_user_id") = 'integer' AND "actor_user_id" BETWEEN -2147483648 AND 2147483647)),
  "action_type" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("action_type" IS NULL OR "action_type" IN ('user_created','user_enabled','user_disabled','password_set_admin','password_changed_self','email_changed','display_name_changed','otp_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed')),
  "reason" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("reason" IS NULL OR eelkit_char_length("reason") <= 255),
  "details_json" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("details_json" IS NULL OR eelkit_valid_utf8("details_json")),
  "device_id" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("device_id" IS NULL OR eelkit_char_length("device_id") <= 64),
  "ip_address" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("ip_address" IS NULL OR eelkit_char_length("ip_address") <= 45),
  "user_agent" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("user_agent" IS NULL OR eelkit_char_length("user_agent") <= 1000),
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "__eelkit_user_account_audit" ("id","affected_user_id","actor_user_id","action_type","reason","details_json","device_id","ip_address","user_agent","created_at") SELECT "id","affected_user_id","actor_user_id","action_type","reason","details_json","device_id","ip_address","user_agent","created_at" FROM "user_account_audit";
DROP TABLE "user_account_audit";
ALTER TABLE "__eelkit_user_account_audit" RENAME TO "user_account_audit";
CREATE INDEX "idx_user_account_audit_affected_time" ON "user_account_audit" ("affected_user_id","created_at");
CREATE INDEX "idx_user_account_audit_actor_time" ON "user_account_audit" ("actor_user_id","created_at");
CREATE INDEX "idx_user_account_audit_action_time" ON "user_account_audit" ("action_type","created_at");
CREATE TRIGGER "eelkit_user_account_audit_enum_insert" AFTER INSERT ON "user_account_audit"
WHEN (NEW."action_type" IS NOT NULL AND NEW."action_type" COLLATE BINARY NOT IN ('user_created','user_enabled','user_disabled','password_set_admin','password_changed_self','email_changed','display_name_changed','otp_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed'))
BEGIN
  UPDATE "user_account_audit" SET "action_type" = CASE WHEN NEW."action_type" = 'user_created' THEN 'user_created' WHEN NEW."action_type" = 'user_enabled' THEN 'user_enabled' WHEN NEW."action_type" = 'user_disabled' THEN 'user_disabled' WHEN NEW."action_type" = 'password_set_admin' THEN 'password_set_admin' WHEN NEW."action_type" = 'password_changed_self' THEN 'password_changed_self' WHEN NEW."action_type" = 'email_changed' THEN 'email_changed' WHEN NEW."action_type" = 'display_name_changed' THEN 'display_name_changed' WHEN NEW."action_type" = 'otp_reset_admin' THEN 'otp_reset_admin' WHEN NEW."action_type" = 'otp_rotation_started' THEN 'otp_rotation_started' WHEN NEW."action_type" = 'otp_rotation_completed' THEN 'otp_rotation_completed' WHEN NEW."action_type" = 'mfa_authenticated' THEN 'mfa_authenticated' WHEN NEW."action_type" = 'role_changed' THEN 'role_changed' ELSE NEW."action_type" END WHERE "id" = NEW."id";
END;
CREATE TRIGGER "eelkit_user_account_audit_enum_update" AFTER UPDATE ON "user_account_audit"
WHEN (NEW."action_type" IS NOT NULL AND NEW."action_type" COLLATE BINARY NOT IN ('user_created','user_enabled','user_disabled','password_set_admin','password_changed_self','email_changed','display_name_changed','otp_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed'))
BEGIN
  UPDATE "user_account_audit" SET "action_type" = CASE WHEN NEW."action_type" = 'user_created' THEN 'user_created' WHEN NEW."action_type" = 'user_enabled' THEN 'user_enabled' WHEN NEW."action_type" = 'user_disabled' THEN 'user_disabled' WHEN NEW."action_type" = 'password_set_admin' THEN 'password_set_admin' WHEN NEW."action_type" = 'password_changed_self' THEN 'password_changed_self' WHEN NEW."action_type" = 'email_changed' THEN 'email_changed' WHEN NEW."action_type" = 'display_name_changed' THEN 'display_name_changed' WHEN NEW."action_type" = 'otp_reset_admin' THEN 'otp_reset_admin' WHEN NEW."action_type" = 'otp_rotation_started' THEN 'otp_rotation_started' WHEN NEW."action_type" = 'otp_rotation_completed' THEN 'otp_rotation_completed' WHEN NEW."action_type" = 'mfa_authenticated' THEN 'mfa_authenticated' WHEN NEW."action_type" = 'role_changed' THEN 'role_changed' ELSE NEW."action_type" END WHERE "id" = NEW."id";
END;
CREATE TABLE "__eelkit_user_account_audit" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -9223372036854775808 AND 9223372036854775807),
  "affected_user_id" INTEGER NOT NULL CHECK ("affected_user_id" IS NULL OR (typeof("affected_user_id") = 'integer' AND "affected_user_id" BETWEEN -2147483648 AND 2147483647)),
  "actor_user_id" INTEGER DEFAULT NULL CHECK ("actor_user_id" IS NULL OR (typeof("actor_user_id") = 'integer' AND "actor_user_id" BETWEEN -2147483648 AND 2147483647)),
  "action_type" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("action_type" IS NULL OR "action_type" IN ('user_created','user_enabled','user_disabled','password_set_admin','password_changed_self','email_changed','display_name_changed','otp_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed')),
  "reason" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("reason" IS NULL OR eelkit_char_length("reason") <= 255),
  "details_json" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("details_json" IS NULL OR eelkit_valid_utf8("details_json")),
  "device_id" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("device_id" IS NULL OR eelkit_char_length("device_id") <= 64),
  "ip_address" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("ip_address" IS NULL OR eelkit_char_length("ip_address") <= 45),
  "user_agent" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("user_agent" IS NULL OR eelkit_char_length("user_agent") <= 1000),
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_user_account_audit_actor_user
  FOREIGN KEY (actor_user_id)
  REFERENCES users (id)
  ON DELETE SET NULL
  ON UPDATE CASCADE
);
INSERT INTO "__eelkit_user_account_audit" ("id","affected_user_id","actor_user_id","action_type","reason","details_json","device_id","ip_address","user_agent","created_at") SELECT "id","affected_user_id","actor_user_id","action_type","reason","details_json","device_id","ip_address","user_agent","created_at" FROM "user_account_audit";
DROP TABLE "user_account_audit";
ALTER TABLE "__eelkit_user_account_audit" RENAME TO "user_account_audit";
CREATE INDEX "idx_user_account_audit_affected_time" ON "user_account_audit" ("affected_user_id","created_at");
CREATE INDEX "idx_user_account_audit_actor_time" ON "user_account_audit" ("actor_user_id","created_at");
CREATE INDEX "idx_user_account_audit_action_time" ON "user_account_audit" ("action_type","created_at");
CREATE TRIGGER "eelkit_user_account_audit_enum_insert" AFTER INSERT ON "user_account_audit"
WHEN (NEW."action_type" IS NOT NULL AND NEW."action_type" COLLATE BINARY NOT IN ('user_created','user_enabled','user_disabled','password_set_admin','password_changed_self','email_changed','display_name_changed','otp_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed'))
BEGIN
  UPDATE "user_account_audit" SET "action_type" = CASE WHEN NEW."action_type" = 'user_created' THEN 'user_created' WHEN NEW."action_type" = 'user_enabled' THEN 'user_enabled' WHEN NEW."action_type" = 'user_disabled' THEN 'user_disabled' WHEN NEW."action_type" = 'password_set_admin' THEN 'password_set_admin' WHEN NEW."action_type" = 'password_changed_self' THEN 'password_changed_self' WHEN NEW."action_type" = 'email_changed' THEN 'email_changed' WHEN NEW."action_type" = 'display_name_changed' THEN 'display_name_changed' WHEN NEW."action_type" = 'otp_reset_admin' THEN 'otp_reset_admin' WHEN NEW."action_type" = 'otp_rotation_started' THEN 'otp_rotation_started' WHEN NEW."action_type" = 'otp_rotation_completed' THEN 'otp_rotation_completed' WHEN NEW."action_type" = 'mfa_authenticated' THEN 'mfa_authenticated' WHEN NEW."action_type" = 'role_changed' THEN 'role_changed' ELSE NEW."action_type" END WHERE "id" = NEW."id";
END;
CREATE TRIGGER "eelkit_user_account_audit_enum_update" AFTER UPDATE ON "user_account_audit"
WHEN (NEW."action_type" IS NOT NULL AND NEW."action_type" COLLATE BINARY NOT IN ('user_created','user_enabled','user_disabled','password_set_admin','password_changed_self','email_changed','display_name_changed','otp_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed'))
BEGIN
  UPDATE "user_account_audit" SET "action_type" = CASE WHEN NEW."action_type" = 'user_created' THEN 'user_created' WHEN NEW."action_type" = 'user_enabled' THEN 'user_enabled' WHEN NEW."action_type" = 'user_disabled' THEN 'user_disabled' WHEN NEW."action_type" = 'password_set_admin' THEN 'password_set_admin' WHEN NEW."action_type" = 'password_changed_self' THEN 'password_changed_self' WHEN NEW."action_type" = 'email_changed' THEN 'email_changed' WHEN NEW."action_type" = 'display_name_changed' THEN 'display_name_changed' WHEN NEW."action_type" = 'otp_reset_admin' THEN 'otp_reset_admin' WHEN NEW."action_type" = 'otp_rotation_started' THEN 'otp_rotation_started' WHEN NEW."action_type" = 'otp_rotation_completed' THEN 'otp_rotation_completed' WHEN NEW."action_type" = 'mfa_authenticated' THEN 'mfa_authenticated' WHEN NEW."action_type" = 'role_changed' THEN 'role_changed' ELSE NEW."action_type" END WHERE "id" = NEW."id";
END;
CREATE TABLE "__eelkit_user_account_audit" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -9223372036854775808 AND 9223372036854775807),
  "affected_user_id" INTEGER NOT NULL CHECK ("affected_user_id" IS NULL OR (typeof("affected_user_id") = 'integer' AND "affected_user_id" BETWEEN -2147483648 AND 2147483647)),
  "actor_user_id" INTEGER DEFAULT NULL CHECK ("actor_user_id" IS NULL OR (typeof("actor_user_id") = 'integer' AND "actor_user_id" BETWEEN -2147483648 AND 2147483647)),
  "action_type" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("action_type" IS NULL OR "action_type" IN ('user_created','user_enabled','user_disabled','password_set_admin','password_changed_self','email_changed','display_name_changed','otp_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed')),
  "reason" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("reason" IS NULL OR eelkit_char_length("reason") <= 255),
  "details_json" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("details_json" IS NULL OR eelkit_valid_utf8("details_json")),
  "device_id" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("device_id" IS NULL OR eelkit_char_length("device_id") <= 64),
  "ip_address" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("ip_address" IS NULL OR eelkit_char_length("ip_address") <= 45),
  "user_agent" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("user_agent" IS NULL OR eelkit_char_length("user_agent") <= 1000),
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_user_account_audit_actor_user
  FOREIGN KEY (actor_user_id)
  REFERENCES users (id)
  ON DELETE SET NULL
  ON UPDATE CASCADE,
  CONSTRAINT fk_user_account_audit_affected_user
  FOREIGN KEY (affected_user_id)
  REFERENCES users (id)
  ON DELETE RESTRICT
  ON UPDATE CASCADE
);
INSERT INTO "__eelkit_user_account_audit" ("id","affected_user_id","actor_user_id","action_type","reason","details_json","device_id","ip_address","user_agent","created_at") SELECT "id","affected_user_id","actor_user_id","action_type","reason","details_json","device_id","ip_address","user_agent","created_at" FROM "user_account_audit";
DROP TABLE "user_account_audit";
ALTER TABLE "__eelkit_user_account_audit" RENAME TO "user_account_audit";
CREATE INDEX "idx_user_account_audit_affected_time" ON "user_account_audit" ("affected_user_id","created_at");
CREATE INDEX "idx_user_account_audit_actor_time" ON "user_account_audit" ("actor_user_id","created_at");
CREATE INDEX "idx_user_account_audit_action_time" ON "user_account_audit" ("action_type","created_at");
CREATE TRIGGER "eelkit_user_account_audit_enum_insert" AFTER INSERT ON "user_account_audit"
WHEN (NEW."action_type" IS NOT NULL AND NEW."action_type" COLLATE BINARY NOT IN ('user_created','user_enabled','user_disabled','password_set_admin','password_changed_self','email_changed','display_name_changed','otp_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed'))
BEGIN
  UPDATE "user_account_audit" SET "action_type" = CASE WHEN NEW."action_type" = 'user_created' THEN 'user_created' WHEN NEW."action_type" = 'user_enabled' THEN 'user_enabled' WHEN NEW."action_type" = 'user_disabled' THEN 'user_disabled' WHEN NEW."action_type" = 'password_set_admin' THEN 'password_set_admin' WHEN NEW."action_type" = 'password_changed_self' THEN 'password_changed_self' WHEN NEW."action_type" = 'email_changed' THEN 'email_changed' WHEN NEW."action_type" = 'display_name_changed' THEN 'display_name_changed' WHEN NEW."action_type" = 'otp_reset_admin' THEN 'otp_reset_admin' WHEN NEW."action_type" = 'otp_rotation_started' THEN 'otp_rotation_started' WHEN NEW."action_type" = 'otp_rotation_completed' THEN 'otp_rotation_completed' WHEN NEW."action_type" = 'mfa_authenticated' THEN 'mfa_authenticated' WHEN NEW."action_type" = 'role_changed' THEN 'role_changed' ELSE NEW."action_type" END WHERE "id" = NEW."id";
END;
CREATE TRIGGER "eelkit_user_account_audit_enum_update" AFTER UPDATE ON "user_account_audit"
WHEN (NEW."action_type" IS NOT NULL AND NEW."action_type" COLLATE BINARY NOT IN ('user_created','user_enabled','user_disabled','password_set_admin','password_changed_self','email_changed','display_name_changed','otp_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed'))
BEGIN
  UPDATE "user_account_audit" SET "action_type" = CASE WHEN NEW."action_type" = 'user_created' THEN 'user_created' WHEN NEW."action_type" = 'user_enabled' THEN 'user_enabled' WHEN NEW."action_type" = 'user_disabled' THEN 'user_disabled' WHEN NEW."action_type" = 'password_set_admin' THEN 'password_set_admin' WHEN NEW."action_type" = 'password_changed_self' THEN 'password_changed_self' WHEN NEW."action_type" = 'email_changed' THEN 'email_changed' WHEN NEW."action_type" = 'display_name_changed' THEN 'display_name_changed' WHEN NEW."action_type" = 'otp_reset_admin' THEN 'otp_reset_admin' WHEN NEW."action_type" = 'otp_rotation_started' THEN 'otp_rotation_started' WHEN NEW."action_type" = 'otp_rotation_completed' THEN 'otp_rotation_completed' WHEN NEW."action_type" = 'mfa_authenticated' THEN 'mfa_authenticated' WHEN NEW."action_type" = 'role_changed' THEN 'role_changed' ELSE NEW."action_type" END WHERE "id" = NEW."id";
END;
CREATE TABLE "__eelkit_user_logon_history" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -9223372036854775808 AND 9223372036854775807),
  "user_id" INTEGER DEFAULT NULL CHECK ("user_id" IS NULL OR (typeof("user_id") = 'integer' AND "user_id" BETWEEN -2147483648 AND 2147483647)),
  "attempted_email_address" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("attempted_email_address" IS NULL OR eelkit_char_length("attempted_email_address") <= 255),
  "event_type" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("event_type" IS NULL OR "event_type" IN ('login_succeeded','login_failed','logout','forced_logout','session_replaced','otp_challenge_passed','otp_challenge_failed','otp_setup_started','otp_setup_completed')),
  "success" INTEGER NOT NULL DEFAULT 1 CHECK ("success" IS NULL OR (typeof("success") = 'integer' AND "success" BETWEEN -128 AND 127)),
  "reason" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("reason" IS NULL OR eelkit_char_length("reason") <= 255),
  "session_token_hash" TEXT COLLATE BINARY DEFAULT NULL CHECK ("session_token_hash" IS NULL OR eelkit_char_length("session_token_hash") <= 64 AND eelkit_ascii("session_token_hash")),
  "device_id" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("device_id" IS NULL OR eelkit_char_length("device_id") <= 64),
  "ip_address" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("ip_address" IS NULL OR eelkit_char_length("ip_address") <= 45),
  "user_agent" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("user_agent" IS NULL OR eelkit_char_length("user_agent") <= 1000),
  "browser_label" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("browser_label" IS NULL OR eelkit_char_length("browser_label") <= 255),
  "occurred_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO "__eelkit_user_logon_history" ("id","user_id","attempted_email_address","event_type","success","reason","session_token_hash","device_id","ip_address","user_agent","browser_label","occurred_at") SELECT "id","user_id","attempted_email_address","event_type","success","reason","session_token_hash","device_id","ip_address","user_agent","browser_label","occurred_at" FROM "user_logon_history";
DROP TABLE "user_logon_history";
ALTER TABLE "__eelkit_user_logon_history" RENAME TO "user_logon_history";
CREATE INDEX "idx_user_logon_history_user_time" ON "user_logon_history" ("user_id","occurred_at");
CREATE INDEX "idx_user_logon_history_email_time" ON "user_logon_history" ("attempted_email_address","occurred_at");
CREATE INDEX "idx_user_logon_history_token" ON "user_logon_history" ("session_token_hash");
CREATE INDEX "idx_user_logon_history_event_time" ON "user_logon_history" ("event_type","occurred_at");
CREATE TRIGGER "eelkit_user_logon_history_enum_insert" AFTER INSERT ON "user_logon_history"
WHEN (NEW."event_type" IS NOT NULL AND NEW."event_type" COLLATE BINARY NOT IN ('login_succeeded','login_failed','logout','forced_logout','session_replaced','otp_challenge_passed','otp_challenge_failed','otp_setup_started','otp_setup_completed'))
BEGIN
  UPDATE "user_logon_history" SET "event_type" = CASE WHEN NEW."event_type" = 'login_succeeded' THEN 'login_succeeded' WHEN NEW."event_type" = 'login_failed' THEN 'login_failed' WHEN NEW."event_type" = 'logout' THEN 'logout' WHEN NEW."event_type" = 'forced_logout' THEN 'forced_logout' WHEN NEW."event_type" = 'session_replaced' THEN 'session_replaced' WHEN NEW."event_type" = 'otp_challenge_passed' THEN 'otp_challenge_passed' WHEN NEW."event_type" = 'otp_challenge_failed' THEN 'otp_challenge_failed' WHEN NEW."event_type" = 'otp_setup_started' THEN 'otp_setup_started' WHEN NEW."event_type" = 'otp_setup_completed' THEN 'otp_setup_completed' ELSE NEW."event_type" END WHERE "id" = NEW."id";
END;
CREATE TRIGGER "eelkit_user_logon_history_enum_update" AFTER UPDATE ON "user_logon_history"
WHEN (NEW."event_type" IS NOT NULL AND NEW."event_type" COLLATE BINARY NOT IN ('login_succeeded','login_failed','logout','forced_logout','session_replaced','otp_challenge_passed','otp_challenge_failed','otp_setup_started','otp_setup_completed'))
BEGIN
  UPDATE "user_logon_history" SET "event_type" = CASE WHEN NEW."event_type" = 'login_succeeded' THEN 'login_succeeded' WHEN NEW."event_type" = 'login_failed' THEN 'login_failed' WHEN NEW."event_type" = 'logout' THEN 'logout' WHEN NEW."event_type" = 'forced_logout' THEN 'forced_logout' WHEN NEW."event_type" = 'session_replaced' THEN 'session_replaced' WHEN NEW."event_type" = 'otp_challenge_passed' THEN 'otp_challenge_passed' WHEN NEW."event_type" = 'otp_challenge_failed' THEN 'otp_challenge_failed' WHEN NEW."event_type" = 'otp_setup_started' THEN 'otp_setup_started' WHEN NEW."event_type" = 'otp_setup_completed' THEN 'otp_setup_completed' ELSE NEW."event_type" END WHERE "id" = NEW."id";
END;
CREATE TABLE "__eelkit_user_logon_history" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -9223372036854775808 AND 9223372036854775807),
  "user_id" INTEGER DEFAULT NULL CHECK ("user_id" IS NULL OR (typeof("user_id") = 'integer' AND "user_id" BETWEEN -2147483648 AND 2147483647)),
  "attempted_email_address" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("attempted_email_address" IS NULL OR eelkit_char_length("attempted_email_address") <= 255),
  "event_type" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("event_type" IS NULL OR "event_type" IN ('login_succeeded','login_failed','logout','forced_logout','session_replaced','otp_challenge_passed','otp_challenge_failed','otp_setup_started','otp_setup_completed')),
  "success" INTEGER NOT NULL DEFAULT 1 CHECK ("success" IS NULL OR (typeof("success") = 'integer' AND "success" BETWEEN -128 AND 127)),
  "reason" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("reason" IS NULL OR eelkit_char_length("reason") <= 255),
  "session_token_hash" TEXT COLLATE BINARY DEFAULT NULL CHECK ("session_token_hash" IS NULL OR eelkit_char_length("session_token_hash") <= 64 AND eelkit_ascii("session_token_hash")),
  "device_id" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("device_id" IS NULL OR eelkit_char_length("device_id") <= 64),
  "ip_address" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("ip_address" IS NULL OR eelkit_char_length("ip_address") <= 45),
  "user_agent" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("user_agent" IS NULL OR eelkit_char_length("user_agent") <= 1000),
  "browser_label" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("browser_label" IS NULL OR eelkit_char_length("browser_label") <= 255),
  "occurred_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_user_logon_history_user
  FOREIGN KEY (user_id)
  REFERENCES users (id)
  ON DELETE SET NULL
  ON UPDATE CASCADE
);
INSERT INTO "__eelkit_user_logon_history" ("id","user_id","attempted_email_address","event_type","success","reason","session_token_hash","device_id","ip_address","user_agent","browser_label","occurred_at") SELECT "id","user_id","attempted_email_address","event_type","success","reason","session_token_hash","device_id","ip_address","user_agent","browser_label","occurred_at" FROM "user_logon_history";
DROP TABLE "user_logon_history";
ALTER TABLE "__eelkit_user_logon_history" RENAME TO "user_logon_history";
CREATE INDEX "idx_user_logon_history_user_time" ON "user_logon_history" ("user_id","occurred_at");
CREATE INDEX "idx_user_logon_history_email_time" ON "user_logon_history" ("attempted_email_address","occurred_at");
CREATE INDEX "idx_user_logon_history_token" ON "user_logon_history" ("session_token_hash");
CREATE INDEX "idx_user_logon_history_event_time" ON "user_logon_history" ("event_type","occurred_at");
CREATE TRIGGER "eelkit_user_logon_history_enum_insert" AFTER INSERT ON "user_logon_history"
WHEN (NEW."event_type" IS NOT NULL AND NEW."event_type" COLLATE BINARY NOT IN ('login_succeeded','login_failed','logout','forced_logout','session_replaced','otp_challenge_passed','otp_challenge_failed','otp_setup_started','otp_setup_completed'))
BEGIN
  UPDATE "user_logon_history" SET "event_type" = CASE WHEN NEW."event_type" = 'login_succeeded' THEN 'login_succeeded' WHEN NEW."event_type" = 'login_failed' THEN 'login_failed' WHEN NEW."event_type" = 'logout' THEN 'logout' WHEN NEW."event_type" = 'forced_logout' THEN 'forced_logout' WHEN NEW."event_type" = 'session_replaced' THEN 'session_replaced' WHEN NEW."event_type" = 'otp_challenge_passed' THEN 'otp_challenge_passed' WHEN NEW."event_type" = 'otp_challenge_failed' THEN 'otp_challenge_failed' WHEN NEW."event_type" = 'otp_setup_started' THEN 'otp_setup_started' WHEN NEW."event_type" = 'otp_setup_completed' THEN 'otp_setup_completed' ELSE NEW."event_type" END WHERE "id" = NEW."id";
END;
CREATE TRIGGER "eelkit_user_logon_history_enum_update" AFTER UPDATE ON "user_logon_history"
WHEN (NEW."event_type" IS NOT NULL AND NEW."event_type" COLLATE BINARY NOT IN ('login_succeeded','login_failed','logout','forced_logout','session_replaced','otp_challenge_passed','otp_challenge_failed','otp_setup_started','otp_setup_completed'))
BEGIN
  UPDATE "user_logon_history" SET "event_type" = CASE WHEN NEW."event_type" = 'login_succeeded' THEN 'login_succeeded' WHEN NEW."event_type" = 'login_failed' THEN 'login_failed' WHEN NEW."event_type" = 'logout' THEN 'logout' WHEN NEW."event_type" = 'forced_logout' THEN 'forced_logout' WHEN NEW."event_type" = 'session_replaced' THEN 'session_replaced' WHEN NEW."event_type" = 'otp_challenge_passed' THEN 'otp_challenge_passed' WHEN NEW."event_type" = 'otp_challenge_failed' THEN 'otp_challenge_failed' WHEN NEW."event_type" = 'otp_setup_started' THEN 'otp_setup_started' WHEN NEW."event_type" = 'otp_setup_completed' THEN 'otp_setup_completed' ELSE NEW."event_type" END WHERE "id" = NEW."id";
END;
CREATE TABLE "__eelkit_user_totp" (
  "user_id" INTEGER NOT NULL CHECK ("user_id" IS NULL OR (typeof("user_id") = 'integer' AND "user_id" BETWEEN -2147483648 AND 2147483647)),
  "otp_secret" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("otp_secret" IS NULL OR eelkit_char_length("otp_secret") <= 128),
  "pending_otp_secret" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("pending_otp_secret" IS NULL OR eelkit_char_length("pending_otp_secret") <= 128),
  "pending_otp_algorithm" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("pending_otp_algorithm" IS NULL OR "pending_otp_algorithm" IN ('SHA1','SHA256','SHA512')),
  "pending_otp_digits" INTEGER DEFAULT NULL CHECK ("pending_otp_digits" IS NULL OR (typeof("pending_otp_digits") = 'integer' AND "pending_otp_digits" BETWEEN -128 AND 127)),
  "pending_otp_period" INTEGER DEFAULT NULL CHECK ("pending_otp_period" IS NULL OR (typeof("pending_otp_period") = 'integer' AND "pending_otp_period" BETWEEN -2147483648 AND 2147483647)),
  "pending_otp_requested_at" TEXT DEFAULT NULL,
  "otp_algorithm" TEXT COLLATE eelkit_unicode_ci NOT NULL DEFAULT 'SHA1' CHECK ("otp_algorithm" IS NULL OR "otp_algorithm" IN ('SHA1','SHA256','SHA512')),
  "otp_digits" INTEGER NOT NULL DEFAULT 6 CHECK ("otp_digits" IS NULL OR (typeof("otp_digits") = 'integer' AND "otp_digits" BETWEEN -128 AND 127)),
  "otp_period" INTEGER NOT NULL DEFAULT 30 CHECK ("otp_period" IS NULL OR (typeof("otp_period") = 'integer' AND "otp_period" BETWEEN -2147483648 AND 2147483647)),
  "otp_enabled" INTEGER NOT NULL DEFAULT 0 CHECK ("otp_enabled" IS NULL OR (typeof("otp_enabled") = 'integer' AND "otp_enabled" BETWEEN -128 AND 127)),
  "otp_confirmed_at" TEXT DEFAULT NULL,
  "otp_last_used_timestep" INTEGER DEFAULT NULL CHECK ("otp_last_used_timestep" IS NULL OR (typeof("otp_last_used_timestep") = 'integer' AND "otp_last_used_timestep" BETWEEN -9223372036854775808 AND 9223372036854775807)),
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("user_id"),
  CONSTRAINT "fk_user_totp_user" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_user_totp_otp_digits
  CHECK (otp_digits BETWEEN 6 AND 8)
);
INSERT INTO "__eelkit_user_totp" ("user_id","otp_secret","pending_otp_secret","pending_otp_algorithm","pending_otp_digits","pending_otp_period","pending_otp_requested_at","otp_algorithm","otp_digits","otp_period","otp_enabled","otp_confirmed_at","otp_last_used_timestep","created_at","updated_at") SELECT "user_id","otp_secret","pending_otp_secret","pending_otp_algorithm","pending_otp_digits","pending_otp_period","pending_otp_requested_at","otp_algorithm","otp_digits","otp_period","otp_enabled","otp_confirmed_at","otp_last_used_timestep","created_at","updated_at" FROM "user_totp";
DROP TABLE "user_totp";
ALTER TABLE "__eelkit_user_totp" RENAME TO "user_totp";
CREATE TRIGGER "eelkit_user_totp_updated_at" AFTER UPDATE ON "user_totp"
WHEN NEW.updated_at IS OLD.updated_at AND (NEW."user_id" COLLATE BINARY IS NOT OLD."user_id" COLLATE BINARY OR NEW."otp_secret" COLLATE BINARY IS NOT OLD."otp_secret" COLLATE BINARY OR NEW."pending_otp_secret" COLLATE BINARY IS NOT OLD."pending_otp_secret" COLLATE BINARY OR NEW."pending_otp_algorithm" COLLATE BINARY IS NOT OLD."pending_otp_algorithm" COLLATE BINARY OR NEW."pending_otp_digits" COLLATE BINARY IS NOT OLD."pending_otp_digits" COLLATE BINARY OR NEW."pending_otp_period" COLLATE BINARY IS NOT OLD."pending_otp_period" COLLATE BINARY OR NEW."pending_otp_requested_at" COLLATE BINARY IS NOT OLD."pending_otp_requested_at" COLLATE BINARY OR NEW."otp_algorithm" COLLATE BINARY IS NOT OLD."otp_algorithm" COLLATE BINARY OR NEW."otp_digits" COLLATE BINARY IS NOT OLD."otp_digits" COLLATE BINARY OR NEW."otp_period" COLLATE BINARY IS NOT OLD."otp_period" COLLATE BINARY OR NEW."otp_enabled" COLLATE BINARY IS NOT OLD."otp_enabled" COLLATE BINARY OR NEW."otp_confirmed_at" COLLATE BINARY IS NOT OLD."otp_confirmed_at" COLLATE BINARY OR NEW."otp_last_used_timestep" COLLATE BINARY IS NOT OLD."otp_last_used_timestep" COLLATE BINARY OR NEW."created_at" COLLATE BINARY IS NOT OLD."created_at" COLLATE BINARY)
BEGIN
  UPDATE "user_totp" SET updated_at = CURRENT_TIMESTAMP WHERE "user_id" = NEW."user_id";
END;
CREATE TRIGGER "eelkit_user_totp_enum_insert" AFTER INSERT ON "user_totp"
WHEN (NEW."pending_otp_algorithm" IS NOT NULL AND NEW."pending_otp_algorithm" COLLATE BINARY NOT IN ('SHA1','SHA256','SHA512')) OR (NEW."otp_algorithm" IS NOT NULL AND NEW."otp_algorithm" COLLATE BINARY NOT IN ('SHA1','SHA256','SHA512'))
BEGIN
  UPDATE "user_totp" SET "pending_otp_algorithm" = CASE WHEN NEW."pending_otp_algorithm" = 'SHA1' THEN 'SHA1' WHEN NEW."pending_otp_algorithm" = 'SHA256' THEN 'SHA256' WHEN NEW."pending_otp_algorithm" = 'SHA512' THEN 'SHA512' ELSE NEW."pending_otp_algorithm" END, "otp_algorithm" = CASE WHEN NEW."otp_algorithm" = 'SHA1' THEN 'SHA1' WHEN NEW."otp_algorithm" = 'SHA256' THEN 'SHA256' WHEN NEW."otp_algorithm" = 'SHA512' THEN 'SHA512' ELSE NEW."otp_algorithm" END WHERE "user_id" = NEW."user_id";
END;
CREATE TRIGGER "eelkit_user_totp_enum_update" AFTER UPDATE ON "user_totp"
WHEN (NEW."pending_otp_algorithm" IS NOT NULL AND NEW."pending_otp_algorithm" COLLATE BINARY NOT IN ('SHA1','SHA256','SHA512')) OR (NEW."otp_algorithm" IS NOT NULL AND NEW."otp_algorithm" COLLATE BINARY NOT IN ('SHA1','SHA256','SHA512'))
BEGIN
  UPDATE "user_totp" SET "pending_otp_algorithm" = CASE WHEN NEW."pending_otp_algorithm" = 'SHA1' THEN 'SHA1' WHEN NEW."pending_otp_algorithm" = 'SHA256' THEN 'SHA256' WHEN NEW."pending_otp_algorithm" = 'SHA512' THEN 'SHA512' ELSE NEW."pending_otp_algorithm" END, "otp_algorithm" = CASE WHEN NEW."otp_algorithm" = 'SHA1' THEN 'SHA1' WHEN NEW."otp_algorithm" = 'SHA256' THEN 'SHA256' WHEN NEW."otp_algorithm" = 'SHA512' THEN 'SHA512' ELSE NEW."otp_algorithm" END WHERE "user_id" = NEW."user_id";
END;
CREATE TABLE "__eelkit_user_totp" (
  "user_id" INTEGER NOT NULL CHECK ("user_id" IS NULL OR (typeof("user_id") = 'integer' AND "user_id" BETWEEN -2147483648 AND 2147483647)),
  "otp_secret" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("otp_secret" IS NULL OR eelkit_char_length("otp_secret") <= 128),
  "pending_otp_secret" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("pending_otp_secret" IS NULL OR eelkit_char_length("pending_otp_secret") <= 128),
  "pending_otp_algorithm" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("pending_otp_algorithm" IS NULL OR "pending_otp_algorithm" IN ('SHA1','SHA256','SHA512')),
  "pending_otp_digits" INTEGER DEFAULT NULL CHECK ("pending_otp_digits" IS NULL OR (typeof("pending_otp_digits") = 'integer' AND "pending_otp_digits" BETWEEN -128 AND 127)),
  "pending_otp_period" INTEGER DEFAULT NULL CHECK ("pending_otp_period" IS NULL OR (typeof("pending_otp_period") = 'integer' AND "pending_otp_period" BETWEEN -2147483648 AND 2147483647)),
  "pending_otp_requested_at" TEXT DEFAULT NULL,
  "otp_algorithm" TEXT COLLATE eelkit_unicode_ci NOT NULL DEFAULT 'SHA1' CHECK ("otp_algorithm" IS NULL OR "otp_algorithm" IN ('SHA1','SHA256','SHA512')),
  "otp_digits" INTEGER NOT NULL DEFAULT 6 CHECK ("otp_digits" IS NULL OR (typeof("otp_digits") = 'integer' AND "otp_digits" BETWEEN -128 AND 127)),
  "otp_period" INTEGER NOT NULL DEFAULT 30 CHECK ("otp_period" IS NULL OR (typeof("otp_period") = 'integer' AND "otp_period" BETWEEN -2147483648 AND 2147483647)),
  "otp_enabled" INTEGER NOT NULL DEFAULT 0 CHECK ("otp_enabled" IS NULL OR (typeof("otp_enabled") = 'integer' AND "otp_enabled" BETWEEN -128 AND 127)),
  "otp_confirmed_at" TEXT DEFAULT NULL,
  "otp_last_used_timestep" INTEGER DEFAULT NULL CHECK ("otp_last_used_timestep" IS NULL OR (typeof("otp_last_used_timestep") = 'integer' AND "otp_last_used_timestep" BETWEEN -9223372036854775808 AND 9223372036854775807)),
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("user_id"),
  CONSTRAINT "fk_user_totp_user" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_user_totp_otp_digits
  CHECK (otp_digits BETWEEN 6 AND 8),
  CONSTRAINT chk_user_totp_pending_otp_digits
  CHECK (pending_otp_digits IS NULL OR pending_otp_digits BETWEEN 6 AND 8)
);
INSERT INTO "__eelkit_user_totp" ("user_id","otp_secret","pending_otp_secret","pending_otp_algorithm","pending_otp_digits","pending_otp_period","pending_otp_requested_at","otp_algorithm","otp_digits","otp_period","otp_enabled","otp_confirmed_at","otp_last_used_timestep","created_at","updated_at") SELECT "user_id","otp_secret","pending_otp_secret","pending_otp_algorithm","pending_otp_digits","pending_otp_period","pending_otp_requested_at","otp_algorithm","otp_digits","otp_period","otp_enabled","otp_confirmed_at","otp_last_used_timestep","created_at","updated_at" FROM "user_totp";
DROP TABLE "user_totp";
ALTER TABLE "__eelkit_user_totp" RENAME TO "user_totp";
CREATE TRIGGER "eelkit_user_totp_updated_at" AFTER UPDATE ON "user_totp"
WHEN NEW.updated_at IS OLD.updated_at AND (NEW."user_id" COLLATE BINARY IS NOT OLD."user_id" COLLATE BINARY OR NEW."otp_secret" COLLATE BINARY IS NOT OLD."otp_secret" COLLATE BINARY OR NEW."pending_otp_secret" COLLATE BINARY IS NOT OLD."pending_otp_secret" COLLATE BINARY OR NEW."pending_otp_algorithm" COLLATE BINARY IS NOT OLD."pending_otp_algorithm" COLLATE BINARY OR NEW."pending_otp_digits" COLLATE BINARY IS NOT OLD."pending_otp_digits" COLLATE BINARY OR NEW."pending_otp_period" COLLATE BINARY IS NOT OLD."pending_otp_period" COLLATE BINARY OR NEW."pending_otp_requested_at" COLLATE BINARY IS NOT OLD."pending_otp_requested_at" COLLATE BINARY OR NEW."otp_algorithm" COLLATE BINARY IS NOT OLD."otp_algorithm" COLLATE BINARY OR NEW."otp_digits" COLLATE BINARY IS NOT OLD."otp_digits" COLLATE BINARY OR NEW."otp_period" COLLATE BINARY IS NOT OLD."otp_period" COLLATE BINARY OR NEW."otp_enabled" COLLATE BINARY IS NOT OLD."otp_enabled" COLLATE BINARY OR NEW."otp_confirmed_at" COLLATE BINARY IS NOT OLD."otp_confirmed_at" COLLATE BINARY OR NEW."otp_last_used_timestep" COLLATE BINARY IS NOT OLD."otp_last_used_timestep" COLLATE BINARY OR NEW."created_at" COLLATE BINARY IS NOT OLD."created_at" COLLATE BINARY)
BEGIN
  UPDATE "user_totp" SET updated_at = CURRENT_TIMESTAMP WHERE "user_id" = NEW."user_id";
END;
CREATE TRIGGER "eelkit_user_totp_enum_insert" AFTER INSERT ON "user_totp"
WHEN (NEW."pending_otp_algorithm" IS NOT NULL AND NEW."pending_otp_algorithm" COLLATE BINARY NOT IN ('SHA1','SHA256','SHA512')) OR (NEW."otp_algorithm" IS NOT NULL AND NEW."otp_algorithm" COLLATE BINARY NOT IN ('SHA1','SHA256','SHA512'))
BEGIN
  UPDATE "user_totp" SET "pending_otp_algorithm" = CASE WHEN NEW."pending_otp_algorithm" = 'SHA1' THEN 'SHA1' WHEN NEW."pending_otp_algorithm" = 'SHA256' THEN 'SHA256' WHEN NEW."pending_otp_algorithm" = 'SHA512' THEN 'SHA512' ELSE NEW."pending_otp_algorithm" END, "otp_algorithm" = CASE WHEN NEW."otp_algorithm" = 'SHA1' THEN 'SHA1' WHEN NEW."otp_algorithm" = 'SHA256' THEN 'SHA256' WHEN NEW."otp_algorithm" = 'SHA512' THEN 'SHA512' ELSE NEW."otp_algorithm" END WHERE "user_id" = NEW."user_id";
END;
CREATE TRIGGER "eelkit_user_totp_enum_update" AFTER UPDATE ON "user_totp"
WHEN (NEW."pending_otp_algorithm" IS NOT NULL AND NEW."pending_otp_algorithm" COLLATE BINARY NOT IN ('SHA1','SHA256','SHA512')) OR (NEW."otp_algorithm" IS NOT NULL AND NEW."otp_algorithm" COLLATE BINARY NOT IN ('SHA1','SHA256','SHA512'))
BEGIN
  UPDATE "user_totp" SET "pending_otp_algorithm" = CASE WHEN NEW."pending_otp_algorithm" = 'SHA1' THEN 'SHA1' WHEN NEW."pending_otp_algorithm" = 'SHA256' THEN 'SHA256' WHEN NEW."pending_otp_algorithm" = 'SHA512' THEN 'SHA512' ELSE NEW."pending_otp_algorithm" END, "otp_algorithm" = CASE WHEN NEW."otp_algorithm" = 'SHA1' THEN 'SHA1' WHEN NEW."otp_algorithm" = 'SHA256' THEN 'SHA256' WHEN NEW."otp_algorithm" = 'SHA512' THEN 'SHA512' ELSE NEW."otp_algorithm" END WHERE "user_id" = NEW."user_id";
END;
CREATE TABLE "__eelkit_user_totp" (
  "user_id" INTEGER NOT NULL CHECK ("user_id" IS NULL OR (typeof("user_id") = 'integer' AND "user_id" BETWEEN -2147483648 AND 2147483647)),
  "otp_secret" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("otp_secret" IS NULL OR eelkit_char_length("otp_secret") <= 128),
  "pending_otp_secret" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("pending_otp_secret" IS NULL OR eelkit_char_length("pending_otp_secret") <= 128),
  "pending_otp_algorithm" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("pending_otp_algorithm" IS NULL OR "pending_otp_algorithm" IN ('SHA1','SHA256','SHA512')),
  "pending_otp_digits" INTEGER DEFAULT NULL CHECK ("pending_otp_digits" IS NULL OR (typeof("pending_otp_digits") = 'integer' AND "pending_otp_digits" BETWEEN -128 AND 127)),
  "pending_otp_period" INTEGER DEFAULT NULL CHECK ("pending_otp_period" IS NULL OR (typeof("pending_otp_period") = 'integer' AND "pending_otp_period" BETWEEN -2147483648 AND 2147483647)),
  "pending_otp_requested_at" TEXT DEFAULT NULL,
  "otp_algorithm" TEXT COLLATE eelkit_unicode_ci NOT NULL DEFAULT 'SHA1' CHECK ("otp_algorithm" IS NULL OR "otp_algorithm" IN ('SHA1','SHA256','SHA512')),
  "otp_digits" INTEGER NOT NULL DEFAULT 6 CHECK ("otp_digits" IS NULL OR (typeof("otp_digits") = 'integer' AND "otp_digits" BETWEEN -128 AND 127)),
  "otp_period" INTEGER NOT NULL DEFAULT 30 CHECK ("otp_period" IS NULL OR (typeof("otp_period") = 'integer' AND "otp_period" BETWEEN -2147483648 AND 2147483647)),
  "otp_enabled" INTEGER NOT NULL DEFAULT 0 CHECK ("otp_enabled" IS NULL OR (typeof("otp_enabled") = 'integer' AND "otp_enabled" BETWEEN -128 AND 127)),
  "otp_confirmed_at" TEXT DEFAULT NULL,
  "otp_last_used_timestep" INTEGER DEFAULT NULL CHECK ("otp_last_used_timestep" IS NULL OR (typeof("otp_last_used_timestep") = 'integer' AND "otp_last_used_timestep" BETWEEN -9223372036854775808 AND 9223372036854775807)),
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("user_id"),
  CONSTRAINT "fk_user_totp_user" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_user_totp_otp_digits
  CHECK (otp_digits BETWEEN 6 AND 8),
  CONSTRAINT chk_user_totp_pending_otp_digits
  CHECK (pending_otp_digits IS NULL OR pending_otp_digits BETWEEN 6 AND 8),
  CONSTRAINT chk_user_totp_otp_period_positive
  CHECK (otp_period > 0)
);
INSERT INTO "__eelkit_user_totp" ("user_id","otp_secret","pending_otp_secret","pending_otp_algorithm","pending_otp_digits","pending_otp_period","pending_otp_requested_at","otp_algorithm","otp_digits","otp_period","otp_enabled","otp_confirmed_at","otp_last_used_timestep","created_at","updated_at") SELECT "user_id","otp_secret","pending_otp_secret","pending_otp_algorithm","pending_otp_digits","pending_otp_period","pending_otp_requested_at","otp_algorithm","otp_digits","otp_period","otp_enabled","otp_confirmed_at","otp_last_used_timestep","created_at","updated_at" FROM "user_totp";
DROP TABLE "user_totp";
ALTER TABLE "__eelkit_user_totp" RENAME TO "user_totp";
CREATE TRIGGER "eelkit_user_totp_updated_at" AFTER UPDATE ON "user_totp"
WHEN NEW.updated_at IS OLD.updated_at AND (NEW."user_id" COLLATE BINARY IS NOT OLD."user_id" COLLATE BINARY OR NEW."otp_secret" COLLATE BINARY IS NOT OLD."otp_secret" COLLATE BINARY OR NEW."pending_otp_secret" COLLATE BINARY IS NOT OLD."pending_otp_secret" COLLATE BINARY OR NEW."pending_otp_algorithm" COLLATE BINARY IS NOT OLD."pending_otp_algorithm" COLLATE BINARY OR NEW."pending_otp_digits" COLLATE BINARY IS NOT OLD."pending_otp_digits" COLLATE BINARY OR NEW."pending_otp_period" COLLATE BINARY IS NOT OLD."pending_otp_period" COLLATE BINARY OR NEW."pending_otp_requested_at" COLLATE BINARY IS NOT OLD."pending_otp_requested_at" COLLATE BINARY OR NEW."otp_algorithm" COLLATE BINARY IS NOT OLD."otp_algorithm" COLLATE BINARY OR NEW."otp_digits" COLLATE BINARY IS NOT OLD."otp_digits" COLLATE BINARY OR NEW."otp_period" COLLATE BINARY IS NOT OLD."otp_period" COLLATE BINARY OR NEW."otp_enabled" COLLATE BINARY IS NOT OLD."otp_enabled" COLLATE BINARY OR NEW."otp_confirmed_at" COLLATE BINARY IS NOT OLD."otp_confirmed_at" COLLATE BINARY OR NEW."otp_last_used_timestep" COLLATE BINARY IS NOT OLD."otp_last_used_timestep" COLLATE BINARY OR NEW."created_at" COLLATE BINARY IS NOT OLD."created_at" COLLATE BINARY)
BEGIN
  UPDATE "user_totp" SET updated_at = CURRENT_TIMESTAMP WHERE "user_id" = NEW."user_id";
END;
CREATE TRIGGER "eelkit_user_totp_enum_insert" AFTER INSERT ON "user_totp"
WHEN (NEW."pending_otp_algorithm" IS NOT NULL AND NEW."pending_otp_algorithm" COLLATE BINARY NOT IN ('SHA1','SHA256','SHA512')) OR (NEW."otp_algorithm" IS NOT NULL AND NEW."otp_algorithm" COLLATE BINARY NOT IN ('SHA1','SHA256','SHA512'))
BEGIN
  UPDATE "user_totp" SET "pending_otp_algorithm" = CASE WHEN NEW."pending_otp_algorithm" = 'SHA1' THEN 'SHA1' WHEN NEW."pending_otp_algorithm" = 'SHA256' THEN 'SHA256' WHEN NEW."pending_otp_algorithm" = 'SHA512' THEN 'SHA512' ELSE NEW."pending_otp_algorithm" END, "otp_algorithm" = CASE WHEN NEW."otp_algorithm" = 'SHA1' THEN 'SHA1' WHEN NEW."otp_algorithm" = 'SHA256' THEN 'SHA256' WHEN NEW."otp_algorithm" = 'SHA512' THEN 'SHA512' ELSE NEW."otp_algorithm" END WHERE "user_id" = NEW."user_id";
END;
CREATE TRIGGER "eelkit_user_totp_enum_update" AFTER UPDATE ON "user_totp"
WHEN (NEW."pending_otp_algorithm" IS NOT NULL AND NEW."pending_otp_algorithm" COLLATE BINARY NOT IN ('SHA1','SHA256','SHA512')) OR (NEW."otp_algorithm" IS NOT NULL AND NEW."otp_algorithm" COLLATE BINARY NOT IN ('SHA1','SHA256','SHA512'))
BEGIN
  UPDATE "user_totp" SET "pending_otp_algorithm" = CASE WHEN NEW."pending_otp_algorithm" = 'SHA1' THEN 'SHA1' WHEN NEW."pending_otp_algorithm" = 'SHA256' THEN 'SHA256' WHEN NEW."pending_otp_algorithm" = 'SHA512' THEN 'SHA512' ELSE NEW."pending_otp_algorithm" END, "otp_algorithm" = CASE WHEN NEW."otp_algorithm" = 'SHA1' THEN 'SHA1' WHEN NEW."otp_algorithm" = 'SHA256' THEN 'SHA256' WHEN NEW."otp_algorithm" = 'SHA512' THEN 'SHA512' ELSE NEW."otp_algorithm" END WHERE "user_id" = NEW."user_id";
END;
CREATE TABLE "__eelkit_user_totp" (
  "user_id" INTEGER NOT NULL CHECK ("user_id" IS NULL OR (typeof("user_id") = 'integer' AND "user_id" BETWEEN -2147483648 AND 2147483647)),
  "otp_secret" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("otp_secret" IS NULL OR eelkit_char_length("otp_secret") <= 128),
  "pending_otp_secret" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("pending_otp_secret" IS NULL OR eelkit_char_length("pending_otp_secret") <= 128),
  "pending_otp_algorithm" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("pending_otp_algorithm" IS NULL OR "pending_otp_algorithm" IN ('SHA1','SHA256','SHA512')),
  "pending_otp_digits" INTEGER DEFAULT NULL CHECK ("pending_otp_digits" IS NULL OR (typeof("pending_otp_digits") = 'integer' AND "pending_otp_digits" BETWEEN -128 AND 127)),
  "pending_otp_period" INTEGER DEFAULT NULL CHECK ("pending_otp_period" IS NULL OR (typeof("pending_otp_period") = 'integer' AND "pending_otp_period" BETWEEN -2147483648 AND 2147483647)),
  "pending_otp_requested_at" TEXT DEFAULT NULL,
  "otp_algorithm" TEXT COLLATE eelkit_unicode_ci NOT NULL DEFAULT 'SHA1' CHECK ("otp_algorithm" IS NULL OR "otp_algorithm" IN ('SHA1','SHA256','SHA512')),
  "otp_digits" INTEGER NOT NULL DEFAULT 6 CHECK ("otp_digits" IS NULL OR (typeof("otp_digits") = 'integer' AND "otp_digits" BETWEEN -128 AND 127)),
  "otp_period" INTEGER NOT NULL DEFAULT 30 CHECK ("otp_period" IS NULL OR (typeof("otp_period") = 'integer' AND "otp_period" BETWEEN -2147483648 AND 2147483647)),
  "otp_enabled" INTEGER NOT NULL DEFAULT 0 CHECK ("otp_enabled" IS NULL OR (typeof("otp_enabled") = 'integer' AND "otp_enabled" BETWEEN -128 AND 127)),
  "otp_confirmed_at" TEXT DEFAULT NULL,
  "otp_last_used_timestep" INTEGER DEFAULT NULL CHECK ("otp_last_used_timestep" IS NULL OR (typeof("otp_last_used_timestep") = 'integer' AND "otp_last_used_timestep" BETWEEN -9223372036854775808 AND 9223372036854775807)),
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("user_id"),
  CONSTRAINT "fk_user_totp_user" FOREIGN KEY ("user_id") REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_user_totp_otp_digits
  CHECK (otp_digits BETWEEN 6 AND 8),
  CONSTRAINT chk_user_totp_pending_otp_digits
  CHECK (pending_otp_digits IS NULL OR pending_otp_digits BETWEEN 6 AND 8),
  CONSTRAINT chk_user_totp_otp_period_positive
  CHECK (otp_period > 0),
  CONSTRAINT chk_user_totp_pending_otp_period_positive
  CHECK (pending_otp_period IS NULL OR pending_otp_period > 0)
);
INSERT INTO "__eelkit_user_totp" ("user_id","otp_secret","pending_otp_secret","pending_otp_algorithm","pending_otp_digits","pending_otp_period","pending_otp_requested_at","otp_algorithm","otp_digits","otp_period","otp_enabled","otp_confirmed_at","otp_last_used_timestep","created_at","updated_at") SELECT "user_id","otp_secret","pending_otp_secret","pending_otp_algorithm","pending_otp_digits","pending_otp_period","pending_otp_requested_at","otp_algorithm","otp_digits","otp_period","otp_enabled","otp_confirmed_at","otp_last_used_timestep","created_at","updated_at" FROM "user_totp";
DROP TABLE "user_totp";
ALTER TABLE "__eelkit_user_totp" RENAME TO "user_totp";
CREATE TRIGGER "eelkit_user_totp_updated_at" AFTER UPDATE ON "user_totp"
WHEN NEW.updated_at IS OLD.updated_at AND (NEW."user_id" COLLATE BINARY IS NOT OLD."user_id" COLLATE BINARY OR NEW."otp_secret" COLLATE BINARY IS NOT OLD."otp_secret" COLLATE BINARY OR NEW."pending_otp_secret" COLLATE BINARY IS NOT OLD."pending_otp_secret" COLLATE BINARY OR NEW."pending_otp_algorithm" COLLATE BINARY IS NOT OLD."pending_otp_algorithm" COLLATE BINARY OR NEW."pending_otp_digits" COLLATE BINARY IS NOT OLD."pending_otp_digits" COLLATE BINARY OR NEW."pending_otp_period" COLLATE BINARY IS NOT OLD."pending_otp_period" COLLATE BINARY OR NEW."pending_otp_requested_at" COLLATE BINARY IS NOT OLD."pending_otp_requested_at" COLLATE BINARY OR NEW."otp_algorithm" COLLATE BINARY IS NOT OLD."otp_algorithm" COLLATE BINARY OR NEW."otp_digits" COLLATE BINARY IS NOT OLD."otp_digits" COLLATE BINARY OR NEW."otp_period" COLLATE BINARY IS NOT OLD."otp_period" COLLATE BINARY OR NEW."otp_enabled" COLLATE BINARY IS NOT OLD."otp_enabled" COLLATE BINARY OR NEW."otp_confirmed_at" COLLATE BINARY IS NOT OLD."otp_confirmed_at" COLLATE BINARY OR NEW."otp_last_used_timestep" COLLATE BINARY IS NOT OLD."otp_last_used_timestep" COLLATE BINARY OR NEW."created_at" COLLATE BINARY IS NOT OLD."created_at" COLLATE BINARY)
BEGIN
  UPDATE "user_totp" SET updated_at = CURRENT_TIMESTAMP WHERE "user_id" = NEW."user_id";
END;
CREATE TRIGGER "eelkit_user_totp_enum_insert" AFTER INSERT ON "user_totp"
WHEN (NEW."pending_otp_algorithm" IS NOT NULL AND NEW."pending_otp_algorithm" COLLATE BINARY NOT IN ('SHA1','SHA256','SHA512')) OR (NEW."otp_algorithm" IS NOT NULL AND NEW."otp_algorithm" COLLATE BINARY NOT IN ('SHA1','SHA256','SHA512'))
BEGIN
  UPDATE "user_totp" SET "pending_otp_algorithm" = CASE WHEN NEW."pending_otp_algorithm" = 'SHA1' THEN 'SHA1' WHEN NEW."pending_otp_algorithm" = 'SHA256' THEN 'SHA256' WHEN NEW."pending_otp_algorithm" = 'SHA512' THEN 'SHA512' ELSE NEW."pending_otp_algorithm" END, "otp_algorithm" = CASE WHEN NEW."otp_algorithm" = 'SHA1' THEN 'SHA1' WHEN NEW."otp_algorithm" = 'SHA256' THEN 'SHA256' WHEN NEW."otp_algorithm" = 'SHA512' THEN 'SHA512' ELSE NEW."otp_algorithm" END WHERE "user_id" = NEW."user_id";
END;
CREATE TRIGGER "eelkit_user_totp_enum_update" AFTER UPDATE ON "user_totp"
WHEN (NEW."pending_otp_algorithm" IS NOT NULL AND NEW."pending_otp_algorithm" COLLATE BINARY NOT IN ('SHA1','SHA256','SHA512')) OR (NEW."otp_algorithm" IS NOT NULL AND NEW."otp_algorithm" COLLATE BINARY NOT IN ('SHA1','SHA256','SHA512'))
BEGIN
  UPDATE "user_totp" SET "pending_otp_algorithm" = CASE WHEN NEW."pending_otp_algorithm" = 'SHA1' THEN 'SHA1' WHEN NEW."pending_otp_algorithm" = 'SHA256' THEN 'SHA256' WHEN NEW."pending_otp_algorithm" = 'SHA512' THEN 'SHA512' ELSE NEW."pending_otp_algorithm" END, "otp_algorithm" = CASE WHEN NEW."otp_algorithm" = 'SHA1' THEN 'SHA1' WHEN NEW."otp_algorithm" = 'SHA256' THEN 'SHA256' WHEN NEW."otp_algorithm" = 'SHA512' THEN 'SHA512' ELSE NEW."otp_algorithm" END WHERE "user_id" = NEW."user_id";
END;
