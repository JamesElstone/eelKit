-- eelKit native SQLite baseline. Initialize only through setupDb.
CREATE TABLE "schema_migrations" (
  "migration" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("migration" IS NULL OR eelkit_char_length("migration") <= 255),
  "applied_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY ("migration")
);


CREATE TABLE "roles" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -2147483648 AND 2147483647),
  "role_name" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("role_name" IS NULL OR eelkit_char_length("role_name") <= 255),
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE UNIQUE INDEX "uq_roles_role_name" ON "roles" ("role_name");
CREATE TRIGGER "eelkit_roles_updated_at" AFTER UPDATE ON "roles"
WHEN NEW.updated_at IS OLD.updated_at AND (NEW."id" COLLATE BINARY IS NOT OLD."id" COLLATE BINARY OR NEW."role_name" COLLATE BINARY IS NOT OLD."role_name" COLLATE BINARY OR NEW."created_at" COLLATE BINARY IS NOT OLD."created_at" COLLATE BINARY)
BEGIN
  UPDATE "roles" SET updated_at = CURRENT_TIMESTAMP WHERE "id" = NEW."id";
END;

CREATE TABLE "users" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -2147483648 AND 2147483647),
  "display_name" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("display_name" IS NULL OR eelkit_char_length("display_name") <= 255),
  "email_address" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("email_address" IS NULL OR eelkit_char_length("email_address") <= 255),
  "password_hash" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("password_hash" IS NULL OR eelkit_char_length("password_hash") <= 255),
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
  "must_change_password" INTEGER NOT NULL DEFAULT 0 CHECK ("must_change_password" IS NULL OR (typeof("must_change_password") = 'integer' AND "must_change_password" BETWEEN -128 AND 127)),
  "otp_required" INTEGER NOT NULL DEFAULT 1 CHECK ("otp_required" IS NULL OR (typeof("otp_required") = 'integer' AND "otp_required" BETWEEN -128 AND 127)),
  "mobile_number" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("mobile_number" IS NULL OR eelkit_char_length("mobile_number") <= 32),
  "account_status" TEXT COLLATE eelkit_unicode_ci NOT NULL DEFAULT 'active' CHECK ("account_status" IS NULL OR eelkit_char_length("account_status") <= 30),
  "account_completed_at" TEXT DEFAULT NULL,
  CONSTRAINT chk_users_role_id_reserved_or_positive
  CHECK (role_id = -1 OR role_id > 0)
);
CREATE UNIQUE INDEX "uq_users_email_address" ON "users" ("email_address");
CREATE UNIQUE INDEX "uq_users_current_session_token_hash" ON "users" ("current_session_token_hash");
CREATE INDEX "idx_users_role_id" ON "users" ("role_id");
CREATE TRIGGER "eelkit_users_updated_at" AFTER UPDATE ON "users"
WHEN NEW.updated_at IS OLD.updated_at AND (NEW."id" COLLATE BINARY IS NOT OLD."id" COLLATE BINARY OR NEW."display_name" COLLATE BINARY IS NOT OLD."display_name" COLLATE BINARY OR NEW."email_address" COLLATE BINARY IS NOT OLD."email_address" COLLATE BINARY OR NEW."password_hash" COLLATE BINARY IS NOT OLD."password_hash" COLLATE BINARY OR NEW."current_session_token_hash" COLLATE BINARY IS NOT OLD."current_session_token_hash" COLLATE BINARY OR NEW."current_session_started_at" COLLATE BINARY IS NOT OLD."current_session_started_at" COLLATE BINARY OR NEW."current_session_last_seen_at" COLLATE BINARY IS NOT OLD."current_session_last_seen_at" COLLATE BINARY OR NEW."current_session_device_id" COLLATE BINARY IS NOT OLD."current_session_device_id" COLLATE BINARY OR NEW."current_session_ip_address" COLLATE BINARY IS NOT OLD."current_session_ip_address" COLLATE BINARY OR NEW."current_session_user_agent" COLLATE BINARY IS NOT OLD."current_session_user_agent" COLLATE BINARY OR NEW."current_session_browser_label" COLLATE BINARY IS NOT OLD."current_session_browser_label" COLLATE BINARY OR NEW."last_login_at" COLLATE BINARY IS NOT OLD."last_login_at" COLLATE BINARY OR NEW."password_changed_at" COLLATE BINARY IS NOT OLD."password_changed_at" COLLATE BINARY OR NEW."is_active" COLLATE BINARY IS NOT OLD."is_active" COLLATE BINARY OR NEW."role_id" COLLATE BINARY IS NOT OLD."role_id" COLLATE BINARY OR NEW."created_at" COLLATE BINARY IS NOT OLD."created_at" COLLATE BINARY OR NEW."must_change_password" COLLATE BINARY IS NOT OLD."must_change_password" COLLATE BINARY OR NEW."otp_required" COLLATE BINARY IS NOT OLD."otp_required" COLLATE BINARY OR NEW."mobile_number" COLLATE BINARY IS NOT OLD."mobile_number" COLLATE BINARY OR NEW."account_status" COLLATE BINARY IS NOT OLD."account_status" COLLATE BINARY OR NEW."account_completed_at" COLLATE BINARY IS NOT OLD."account_completed_at" COLLATE BINARY)
BEGIN
  UPDATE "users" SET updated_at = CURRENT_TIMESTAMP WHERE "id" = NEW."id";
END;

CREATE TABLE "role_card_permissions" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -2147483648 AND 2147483647),
  "role_id" INTEGER NOT NULL CHECK ("role_id" IS NULL OR (typeof("role_id") = 'integer' AND "role_id" BETWEEN -2147483648 AND 2147483647)),
  "card_key" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("card_key" IS NULL OR eelkit_char_length("card_key") <= 255),
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "fk_role_card_permissions_role" FOREIGN KEY ("role_id") REFERENCES "roles" ("id") ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT chk_role_card_permissions_card_key_not_blank
  CHECK (card_key <> '')
);
CREATE UNIQUE INDEX "uq_role_card_permissions_role_card" ON "role_card_permissions" ("role_id","card_key");
CREATE INDEX "idx_role_card_permissions_card_key" ON "role_card_permissions" ("card_key");

CREATE TABLE "user_login_rate_limits" (
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

CREATE TABLE "user_account_audit" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -9223372036854775808 AND 9223372036854775807),
  "affected_user_id" INTEGER NOT NULL CHECK ("affected_user_id" IS NULL OR (typeof("affected_user_id") = 'integer' AND "affected_user_id" BETWEEN -2147483648 AND 2147483647)),
  "actor_user_id" INTEGER DEFAULT NULL CHECK ("actor_user_id" IS NULL OR (typeof("actor_user_id") = 'integer' AND "actor_user_id" BETWEEN -2147483648 AND 2147483647)),
  "action_type" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("action_type" IS NULL OR "action_type" IN ('user_created','user_enabled','user_disabled','password_set_admin','password_change_required_admin','password_changed_self','email_changed','display_name_changed','mobile_number_changed','otp_requirement_changed','otp_reset_admin','login_lockout_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed','invite_created','invite_link_copied','invite_email_sent','invite_sms_sent','invite_opened','invite_verification_failed','invite_verification_succeeded','invite_completion_failed','invite_completed','invite_expired','invite_revoked','invite_locked','user_restored')),
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
CREATE INDEX "idx_user_account_audit_affected_time" ON "user_account_audit" ("affected_user_id","created_at");
CREATE INDEX "idx_user_account_audit_actor_time" ON "user_account_audit" ("actor_user_id","created_at");
CREATE INDEX "idx_user_account_audit_action_time" ON "user_account_audit" ("action_type","created_at");
CREATE TRIGGER "eelkit_user_account_audit_enum_insert" AFTER INSERT ON "user_account_audit"
WHEN (NEW."action_type" IS NOT NULL AND NEW."action_type" COLLATE BINARY NOT IN ('user_created','user_enabled','user_disabled','password_set_admin','password_change_required_admin','password_changed_self','email_changed','display_name_changed','mobile_number_changed','otp_requirement_changed','otp_reset_admin','login_lockout_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed','invite_created','invite_link_copied','invite_email_sent','invite_sms_sent','invite_opened','invite_verification_failed','invite_verification_succeeded','invite_completion_failed','invite_completed','invite_expired','invite_revoked','invite_locked','user_restored'))
BEGIN
  UPDATE "user_account_audit" SET "action_type" = CASE WHEN NEW."action_type" = 'user_created' THEN 'user_created' WHEN NEW."action_type" = 'user_enabled' THEN 'user_enabled' WHEN NEW."action_type" = 'user_disabled' THEN 'user_disabled' WHEN NEW."action_type" = 'password_set_admin' THEN 'password_set_admin' WHEN NEW."action_type" = 'password_change_required_admin' THEN 'password_change_required_admin' WHEN NEW."action_type" = 'password_changed_self' THEN 'password_changed_self' WHEN NEW."action_type" = 'email_changed' THEN 'email_changed' WHEN NEW."action_type" = 'display_name_changed' THEN 'display_name_changed' WHEN NEW."action_type" = 'mobile_number_changed' THEN 'mobile_number_changed' WHEN NEW."action_type" = 'otp_requirement_changed' THEN 'otp_requirement_changed' WHEN NEW."action_type" = 'otp_reset_admin' THEN 'otp_reset_admin' WHEN NEW."action_type" = 'login_lockout_reset_admin' THEN 'login_lockout_reset_admin' WHEN NEW."action_type" = 'otp_rotation_started' THEN 'otp_rotation_started' WHEN NEW."action_type" = 'otp_rotation_completed' THEN 'otp_rotation_completed' WHEN NEW."action_type" = 'mfa_authenticated' THEN 'mfa_authenticated' WHEN NEW."action_type" = 'role_changed' THEN 'role_changed' WHEN NEW."action_type" = 'invite_created' THEN 'invite_created' WHEN NEW."action_type" = 'invite_link_copied' THEN 'invite_link_copied' WHEN NEW."action_type" = 'invite_email_sent' THEN 'invite_email_sent' WHEN NEW."action_type" = 'invite_sms_sent' THEN 'invite_sms_sent' WHEN NEW."action_type" = 'invite_opened' THEN 'invite_opened' WHEN NEW."action_type" = 'invite_verification_failed' THEN 'invite_verification_failed' WHEN NEW."action_type" = 'invite_verification_succeeded' THEN 'invite_verification_succeeded' WHEN NEW."action_type" = 'invite_completion_failed' THEN 'invite_completion_failed' WHEN NEW."action_type" = 'invite_completed' THEN 'invite_completed' WHEN NEW."action_type" = 'invite_expired' THEN 'invite_expired' WHEN NEW."action_type" = 'invite_revoked' THEN 'invite_revoked' WHEN NEW."action_type" = 'invite_locked' THEN 'invite_locked' WHEN NEW."action_type" = 'user_restored' THEN 'user_restored' ELSE NEW."action_type" END WHERE "id" = NEW."id";
END;
CREATE TRIGGER "eelkit_user_account_audit_enum_update" AFTER UPDATE ON "user_account_audit"
WHEN (NEW."action_type" IS NOT NULL AND NEW."action_type" COLLATE BINARY NOT IN ('user_created','user_enabled','user_disabled','password_set_admin','password_change_required_admin','password_changed_self','email_changed','display_name_changed','mobile_number_changed','otp_requirement_changed','otp_reset_admin','login_lockout_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed','invite_created','invite_link_copied','invite_email_sent','invite_sms_sent','invite_opened','invite_verification_failed','invite_verification_succeeded','invite_completion_failed','invite_completed','invite_expired','invite_revoked','invite_locked','user_restored'))
BEGIN
  UPDATE "user_account_audit" SET "action_type" = CASE WHEN NEW."action_type" = 'user_created' THEN 'user_created' WHEN NEW."action_type" = 'user_enabled' THEN 'user_enabled' WHEN NEW."action_type" = 'user_disabled' THEN 'user_disabled' WHEN NEW."action_type" = 'password_set_admin' THEN 'password_set_admin' WHEN NEW."action_type" = 'password_change_required_admin' THEN 'password_change_required_admin' WHEN NEW."action_type" = 'password_changed_self' THEN 'password_changed_self' WHEN NEW."action_type" = 'email_changed' THEN 'email_changed' WHEN NEW."action_type" = 'display_name_changed' THEN 'display_name_changed' WHEN NEW."action_type" = 'mobile_number_changed' THEN 'mobile_number_changed' WHEN NEW."action_type" = 'otp_requirement_changed' THEN 'otp_requirement_changed' WHEN NEW."action_type" = 'otp_reset_admin' THEN 'otp_reset_admin' WHEN NEW."action_type" = 'login_lockout_reset_admin' THEN 'login_lockout_reset_admin' WHEN NEW."action_type" = 'otp_rotation_started' THEN 'otp_rotation_started' WHEN NEW."action_type" = 'otp_rotation_completed' THEN 'otp_rotation_completed' WHEN NEW."action_type" = 'mfa_authenticated' THEN 'mfa_authenticated' WHEN NEW."action_type" = 'role_changed' THEN 'role_changed' WHEN NEW."action_type" = 'invite_created' THEN 'invite_created' WHEN NEW."action_type" = 'invite_link_copied' THEN 'invite_link_copied' WHEN NEW."action_type" = 'invite_email_sent' THEN 'invite_email_sent' WHEN NEW."action_type" = 'invite_sms_sent' THEN 'invite_sms_sent' WHEN NEW."action_type" = 'invite_opened' THEN 'invite_opened' WHEN NEW."action_type" = 'invite_verification_failed' THEN 'invite_verification_failed' WHEN NEW."action_type" = 'invite_verification_succeeded' THEN 'invite_verification_succeeded' WHEN NEW."action_type" = 'invite_completion_failed' THEN 'invite_completion_failed' WHEN NEW."action_type" = 'invite_completed' THEN 'invite_completed' WHEN NEW."action_type" = 'invite_expired' THEN 'invite_expired' WHEN NEW."action_type" = 'invite_revoked' THEN 'invite_revoked' WHEN NEW."action_type" = 'invite_locked' THEN 'invite_locked' WHEN NEW."action_type" = 'user_restored' THEN 'user_restored' ELSE NEW."action_type" END WHERE "id" = NEW."id";
END;

CREATE TABLE "user_logon_history" (
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

CREATE TABLE "user_totp" (
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

CREATE TABLE "application_activity_flash_history" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -9223372036854775808 AND 9223372036854775807),
  "user_id" INTEGER DEFAULT NULL CHECK ("user_id" IS NULL OR (typeof("user_id") = 'integer' AND "user_id" BETWEEN -2147483648 AND 2147483647)),
  "page_id" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("page_id" IS NULL OR eelkit_char_length("page_id") <= 255),
  "action_name" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("action_name" IS NULL OR eelkit_char_length("action_name") <= 255),
  "card_action_name" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("card_action_name" IS NULL OR eelkit_char_length("card_action_name") <= 255),
  "message_type" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("message_type" IS NULL OR "message_type" IN ('success','warning','error')),
  "message_text" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("message_text" IS NULL OR eelkit_valid_utf8("message_text")),
  "message_html_text" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("message_html_text" IS NULL OR eelkit_valid_utf8("message_html_text")),
  "request_method" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("request_method" IS NULL OR eelkit_char_length("request_method") <= 10),
  "is_ajax" INTEGER NOT NULL DEFAULT 0 CHECK ("is_ajax" IS NULL OR (typeof("is_ajax") = 'integer' AND "is_ajax" BETWEEN -128 AND 127)),
  "device_id" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("device_id" IS NULL OR eelkit_char_length("device_id") <= 64),
  "ip_address" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("ip_address" IS NULL OR eelkit_char_length("ip_address") <= 45),
  "user_agent" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("user_agent" IS NULL OR eelkit_char_length("user_agent") <= 1000),
  "request_uri" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("request_uri" IS NULL OR eelkit_char_length("request_uri") <= 2048),
  "occurred_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_application_activity_flash_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL ON UPDATE CASCADE
);
CREATE INDEX "idx_application_activity_flash_user_time" ON "application_activity_flash_history" (user_id, occurred_at);
CREATE INDEX "idx_application_activity_flash_page_time" ON "application_activity_flash_history" (page_id, occurred_at);
CREATE INDEX "idx_application_activity_flash_type_time" ON "application_activity_flash_history" (message_type, occurred_at);
CREATE TRIGGER "eelkit_application_activity_flash_history_enum_insert" AFTER INSERT ON "application_activity_flash_history"
WHEN (NEW."message_type" IS NOT NULL AND NEW."message_type" COLLATE BINARY NOT IN ('success','warning','error'))
BEGIN
  UPDATE "application_activity_flash_history" SET "message_type" = CASE WHEN NEW."message_type" = 'success' THEN 'success' WHEN NEW."message_type" = 'warning' THEN 'warning' WHEN NEW."message_type" = 'error' THEN 'error' ELSE NEW."message_type" END WHERE "id" = NEW."id";
END;
CREATE TRIGGER "eelkit_application_activity_flash_history_enum_update" AFTER UPDATE ON "application_activity_flash_history"
WHEN (NEW."message_type" IS NOT NULL AND NEW."message_type" COLLATE BINARY NOT IN ('success','warning','error'))
BEGIN
  UPDATE "application_activity_flash_history" SET "message_type" = CASE WHEN NEW."message_type" = 'success' THEN 'success' WHEN NEW."message_type" = 'warning' THEN 'warning' WHEN NEW."message_type" = 'error' THEN 'error' ELSE NEW."message_type" END WHERE "id" = NEW."id";
END;

CREATE TABLE "mobile_country_codes" (
  "country_code" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("country_code" IS NULL OR eelkit_char_length("country_code") <= 8),
  "display_name" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("display_name" IS NULL OR eelkit_char_length("display_name") <= 255),
  "is_default" INTEGER NOT NULL DEFAULT 0 CHECK ("is_default" IS NULL OR (typeof("is_default") = 'integer' AND "is_default" BETWEEN -128 AND 127)),
  "sort_order" INTEGER NOT NULL DEFAULT 0 CHECK ("sort_order" IS NULL OR (typeof("sort_order") = 'integer' AND "sort_order" BETWEEN -2147483648 AND 2147483647)),
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (country_code)
);
CREATE INDEX "idx_mobile_country_codes_default_sort" ON "mobile_country_codes" (is_default, display_name);
CREATE TRIGGER "eelkit_mobile_country_codes_updated_at" AFTER UPDATE ON "mobile_country_codes"
WHEN NEW.updated_at IS OLD.updated_at AND (NEW."country_code" COLLATE BINARY IS NOT OLD."country_code" COLLATE BINARY OR NEW."display_name" COLLATE BINARY IS NOT OLD."display_name" COLLATE BINARY OR NEW."is_default" COLLATE BINARY IS NOT OLD."is_default" COLLATE BINARY OR NEW."sort_order" COLLATE BINARY IS NOT OLD."sort_order" COLLATE BINARY OR NEW."created_at" COLLATE BINARY IS NOT OLD."created_at" COLLATE BINARY)
BEGIN
  UPDATE "mobile_country_codes" SET updated_at = CURRENT_TIMESTAMP WHERE "country_code" = NEW."country_code";
END;

CREATE TABLE "user_account_invites" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -2147483648 AND 2147483647),
  "user_id" INTEGER NOT NULL CHECK ("user_id" IS NULL OR (typeof("user_id") = 'integer' AND "user_id" BETWEEN -2147483648 AND 2147483647)),
  "token_hash" TEXT COLLATE BINARY NOT NULL CHECK ("token_hash" IS NULL OR eelkit_char_length("token_hash") <= 64 AND eelkit_ascii("token_hash")),
  "purpose" TEXT COLLATE eelkit_unicode_ci NOT NULL DEFAULT 'account_completion' CHECK ("purpose" IS NULL OR eelkit_char_length("purpose") <= 50),
  "status" TEXT COLLATE eelkit_unicode_ci NOT NULL DEFAULT 'pending' CHECK ("status" IS NULL OR eelkit_char_length("status") <= 30),
  "expires_at" TEXT NOT NULL,
  "used_at" TEXT DEFAULT NULL,
  "revoked_at" TEXT DEFAULT NULL,
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "created_by_user_id" INTEGER DEFAULT NULL CHECK ("created_by_user_id" IS NULL OR (typeof("created_by_user_id") = 'integer' AND "created_by_user_id" BETWEEN -2147483648 AND 2147483647)),
  "last_sent_at" TEXT DEFAULT NULL,
  "send_attempts" INTEGER NOT NULL DEFAULT 0 CHECK ("send_attempts" IS NULL OR (typeof("send_attempts") = 'integer' AND "send_attempts" BETWEEN -2147483648 AND 2147483647)),
  "failed_attempts" INTEGER NOT NULL DEFAULT 0 CHECK ("failed_attempts" IS NULL OR (typeof("failed_attempts") = 'integer' AND "failed_attempts" BETWEEN -2147483648 AND 2147483647)),
  "last_failed_at" TEXT DEFAULT NULL,
  "next_allowed_attempt_at" TEXT DEFAULT NULL,
  "locked_at" TEXT DEFAULT NULL,
  "lock_expires_at" TEXT DEFAULT NULL,
  "opened_at" TEXT DEFAULT NULL,
  "verified_at" TEXT DEFAULT NULL,
  "completed_at" TEXT DEFAULT NULL,
  "ip_created" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("ip_created" IS NULL OR eelkit_char_length("ip_created") <= 45),
  "ip_opened" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("ip_opened" IS NULL OR eelkit_char_length("ip_opened") <= 45),
  "ip_used" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("ip_used" IS NULL OR eelkit_char_length("ip_used") <= 45),
  "token_value" TEXT COLLATE BINARY DEFAULT NULL CHECK ("token_value" IS NULL OR eelkit_char_length("token_value") <= 64 AND eelkit_ascii("token_value")),
  CONSTRAINT fk_user_account_invites_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_user_account_invites_created_by FOREIGN KEY (created_by_user_id) REFERENCES users (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_user_account_invites_purpose_not_blank CHECK (purpose <> ''),
  CONSTRAINT chk_user_account_invites_status_not_blank CHECK (status <> '')
);
CREATE UNIQUE INDEX "uq_user_account_invites_token_hash" ON "user_account_invites" (token_hash);
CREATE INDEX "idx_user_account_invites_user_id" ON "user_account_invites" (user_id);
CREATE INDEX "idx_user_account_invites_status" ON "user_account_invites" (status);
CREATE INDEX "idx_user_account_invites_expires_at" ON "user_account_invites" (expires_at);

CREATE TABLE "user_account_invite_deliveries" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -2147483648 AND 2147483647),
  "invite_id" INTEGER NOT NULL CHECK ("invite_id" IS NULL OR (typeof("invite_id") = 'integer' AND "invite_id" BETWEEN -2147483648 AND 2147483647)),
  "contact_method" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("contact_method" IS NULL OR eelkit_char_length("contact_method") <= 20),
  "sent_to" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("sent_to" IS NULL OR eelkit_char_length("sent_to") <= 255),
  "status" TEXT COLLATE eelkit_unicode_ci NOT NULL DEFAULT 'created' CHECK ("status" IS NULL OR eelkit_char_length("status") <= 30),
  "sent_at" TEXT DEFAULT NULL,
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "created_by_user_id" INTEGER DEFAULT NULL CHECK ("created_by_user_id" IS NULL OR (typeof("created_by_user_id") = 'integer' AND "created_by_user_id" BETWEEN -2147483648 AND 2147483647)),
  "error_summary" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("error_summary" IS NULL OR eelkit_char_length("error_summary") <= 255),
  CONSTRAINT fk_user_account_invite_deliveries_invite FOREIGN KEY (invite_id) REFERENCES user_account_invites (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_user_account_invite_deliveries_created_by FOREIGN KEY (created_by_user_id) REFERENCES users (id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT chk_user_account_invite_deliveries_contact_method_not_blank CHECK (contact_method <> ''),
  CONSTRAINT chk_user_account_invite_deliveries_sent_to_not_blank CHECK (sent_to <> ''),
  CONSTRAINT chk_user_account_invite_deliveries_status_not_blank CHECK (status <> '')
);
CREATE INDEX "idx_user_account_invite_deliveries_invite_id" ON "user_account_invite_deliveries" (invite_id);
CREATE INDEX "idx_user_account_invite_deliveries_contact_method" ON "user_account_invite_deliveries" (contact_method);
CREATE INDEX "idx_user_account_invite_deliveries_sent_at" ON "user_account_invite_deliveries" (sent_at);
CREATE INDEX "idx_user_account_invite_deliveries_created_by" ON "user_account_invite_deliveries" (created_by_user_id);

CREATE TABLE "signup_token_rate_limits" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN 0 AND 4294967295),
  "client_ip" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("client_ip" IS NULL OR eelkit_char_length("client_ip") <= 45),
  "failed_attempts" INTEGER NOT NULL DEFAULT 0 CHECK ("failed_attempts" IS NULL OR (typeof("failed_attempts") = 'integer' AND "failed_attempts" BETWEEN 0 AND 4294967295)),
  "window_started_at" TEXT DEFAULT NULL,
  "last_failed_at" TEXT DEFAULT NULL,
  "blocked_at" TEXT DEFAULT NULL,
  "block_expires_at" TEXT DEFAULT NULL,
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_signup_token_rate_limits_client_ip_not_blank CHECK (client_ip <> '')
);
CREATE UNIQUE INDEX "uq_signup_token_rate_limits_client_ip" ON "signup_token_rate_limits" (client_ip);
CREATE INDEX "idx_signup_token_rate_limits_block_expires_at" ON "signup_token_rate_limits" (block_expires_at);
CREATE INDEX "idx_signup_token_rate_limits_last_failed_at" ON "signup_token_rate_limits" (last_failed_at);
CREATE TRIGGER "eelkit_signup_token_rate_limits_updated_at" AFTER UPDATE ON "signup_token_rate_limits"
WHEN NEW.updated_at IS OLD.updated_at AND (NEW."id" COLLATE BINARY IS NOT OLD."id" COLLATE BINARY OR NEW."client_ip" COLLATE BINARY IS NOT OLD."client_ip" COLLATE BINARY OR NEW."failed_attempts" COLLATE BINARY IS NOT OLD."failed_attempts" COLLATE BINARY OR NEW."window_started_at" COLLATE BINARY IS NOT OLD."window_started_at" COLLATE BINARY OR NEW."last_failed_at" COLLATE BINARY IS NOT OLD."last_failed_at" COLLATE BINARY OR NEW."blocked_at" COLLATE BINARY IS NOT OLD."blocked_at" COLLATE BINARY OR NEW."block_expires_at" COLLATE BINARY IS NOT OLD."block_expires_at" COLLATE BINARY OR NEW."created_at" COLLATE BINARY IS NOT OLD."created_at" COLLATE BINARY)
BEGIN
  UPDATE "signup_token_rate_limits" SET updated_at = CURRENT_TIMESTAMP WHERE "id" = NEW."id";
END;

CREATE TABLE "signup_verification_rate_limits" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN 0 AND 4294967295),
  "scope_type" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("scope_type" IS NULL OR eelkit_char_length("scope_type") <= 20),
  "scope_key" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("scope_key" IS NULL OR eelkit_char_length("scope_key") <= 80),
  "scope_label" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("scope_label" IS NULL OR eelkit_char_length("scope_label") <= 80),
  "failed_attempts" INTEGER NOT NULL DEFAULT 0 CHECK ("failed_attempts" IS NULL OR (typeof("failed_attempts") = 'integer' AND "failed_attempts" BETWEEN 0 AND 4294967295)),
  "window_started_at" TEXT DEFAULT NULL,
  "last_failed_at" TEXT DEFAULT NULL,
  "blocked_at" TEXT DEFAULT NULL,
  "block_expires_at" TEXT DEFAULT NULL,
  "created_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updated_at" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_signup_verification_rate_limits_scope_type_not_blank CHECK (scope_type <> ''),
  CONSTRAINT chk_signup_verification_rate_limits_scope_key_not_blank CHECK (scope_key <> '')
);
CREATE UNIQUE INDEX "uq_signup_verification_rate_limits_scope" ON "signup_verification_rate_limits" (scope_type, scope_key);
CREATE INDEX "idx_signup_verification_rate_limits_block_expires_at" ON "signup_verification_rate_limits" (block_expires_at);
CREATE INDEX "idx_signup_verification_rate_limits_last_failed_at" ON "signup_verification_rate_limits" (last_failed_at);
CREATE TRIGGER "eelkit_signup_verification_rate_limits_updated_at" AFTER UPDATE ON "signup_verification_rate_limits"
WHEN NEW.updated_at IS OLD.updated_at AND (NEW."id" COLLATE BINARY IS NOT OLD."id" COLLATE BINARY OR NEW."scope_type" COLLATE BINARY IS NOT OLD."scope_type" COLLATE BINARY OR NEW."scope_key" COLLATE BINARY IS NOT OLD."scope_key" COLLATE BINARY OR NEW."scope_label" COLLATE BINARY IS NOT OLD."scope_label" COLLATE BINARY OR NEW."failed_attempts" COLLATE BINARY IS NOT OLD."failed_attempts" COLLATE BINARY OR NEW."window_started_at" COLLATE BINARY IS NOT OLD."window_started_at" COLLATE BINARY OR NEW."last_failed_at" COLLATE BINARY IS NOT OLD."last_failed_at" COLLATE BINARY OR NEW."blocked_at" COLLATE BINARY IS NOT OLD."blocked_at" COLLATE BINARY OR NEW."block_expires_at" COLLATE BINARY IS NOT OLD."block_expires_at" COLLATE BINARY OR NEW."created_at" COLLATE BINARY IS NOT OLD."created_at" COLLATE BINARY)
BEGIN
  UPDATE "signup_verification_rate_limits" SET updated_at = CURRENT_TIMESTAMP WHERE "id" = NEW."id";
END;

INSERT INTO `mobile_country_codes` (`country_code`, `display_name`, `is_default`, `sort_order`) VALUES
  ('+1', 'NANP countries and territories', 0, 1),
  ('+7', 'Kazakhstan / Russian Federation', 0, 7),
  ('+20', 'Egypt', 0, 20),
  ('+27', 'South Africa', 0, 27),
  ('+30', 'Greece', 0, 30),
  ('+31', 'Netherlands', 0, 31),
  ('+32', 'Belgium', 0, 32),
  ('+33', 'France', 0, 33),
  ('+34', 'Spain', 0, 34),
  ('+36', 'Hungary', 0, 36),
  ('+39', 'Italy / Vatican City State', 0, 39),
  ('+40', 'Romania', 0, 40),
  ('+41', 'Switzerland', 0, 41),
  ('+43', 'Austria', 0, 43),
  ('+44', 'United Kingdom', 1, 44),
  ('+45', 'Denmark', 0, 45),
  ('+46', 'Sweden', 0, 46),
  ('+47', 'Norway', 0, 47),
  ('+48', 'Poland', 0, 48),
  ('+49', 'Germany', 0, 49),
  ('+51', 'Peru', 0, 51),
  ('+52', 'Mexico', 0, 52),
  ('+53', 'Cuba', 0, 53),
  ('+54', 'Argentina', 0, 54),
  ('+55', 'Brazil', 0, 55),
  ('+56', 'Chile', 0, 56),
  ('+57', 'Colombia', 0, 57),
  ('+58', 'Venezuela', 0, 58),
  ('+60', 'Malaysia', 0, 60),
  ('+61', 'Australia', 0, 61),
  ('+62', 'Indonesia', 0, 62),
  ('+63', 'Philippines', 0, 63),
  ('+64', 'New Zealand', 0, 64),
  ('+65', 'Singapore', 0, 65),
  ('+66', 'Thailand', 0, 66),
  ('+81', 'Japan', 0, 81),
  ('+82', 'Korea, Republic of', 0, 82),
  ('+84', 'Viet Nam', 0, 84),
  ('+86', 'China', 0, 86),
  ('+90', 'Turkey', 0, 90),
  ('+91', 'India', 0, 91),
  ('+92', 'Pakistan', 0, 92),
  ('+93', 'Afghanistan', 0, 93),
  ('+94', 'Sri Lanka', 0, 94),
  ('+95', 'Myanmar', 0, 95),
  ('+98', 'Iran', 0, 98),
  ('+211', 'South Sudan', 0, 211),
  ('+212', 'Morocco', 0, 212),
  ('+213', 'Algeria', 0, 213),
  ('+216', 'Tunisia', 0, 216),
  ('+218', 'Libya', 0, 218),
  ('+220', 'Gambia', 0, 220),
  ('+221', 'Senegal', 0, 221),
  ('+222', 'Mauritania', 0, 222),
  ('+223', 'Mali', 0, 223),
  ('+224', 'Guinea', 0, 224),
  ('+225', 'Cote d''Ivoire', 0, 225),
  ('+226', 'Burkina Faso', 0, 226),
  ('+227', 'Niger', 0, 227),
  ('+228', 'Togolese Republic', 0, 228),
  ('+229', 'Benin', 0, 229),
  ('+230', 'Mauritius', 0, 230),
  ('+231', 'Liberia', 0, 231),
  ('+232', 'Sierra Leone', 0, 232),
  ('+233', 'Ghana', 0, 233),
  ('+234', 'Nigeria', 0, 234),
  ('+235', 'Chad', 0, 235),
  ('+236', 'Central African Republic', 0, 236),
  ('+237', 'Cameroon', 0, 237),
  ('+238', 'Cabo Verde', 0, 238),
  ('+239', 'Sao Tome and Principe', 0, 239),
  ('+240', 'Equatorial Guinea', 0, 240),
  ('+241', 'Gabonese Republic', 0, 241),
  ('+242', 'Congo', 0, 242),
  ('+243', 'Democratic Republic of the Congo', 0, 243),
  ('+244', 'Angola', 0, 244),
  ('+245', 'Guinea-Bissau', 0, 245),
  ('+246', 'Diego Garcia', 0, 246),
  ('+247', 'Saint Helena, Ascension and Tristan da Cunha', 0, 247),
  ('+248', 'Seychelles', 0, 248),
  ('+249', 'Sudan', 0, 249),
  ('+250', 'Rwanda', 0, 250),
  ('+251', 'Ethiopia', 0, 251),
  ('+252', 'Somalia', 0, 252),
  ('+253', 'Djibouti', 0, 253),
  ('+254', 'Kenya', 0, 254),
  ('+255', 'Tanzania', 0, 255),
  ('+256', 'Uganda', 0, 256),
  ('+257', 'Burundi', 0, 257),
  ('+258', 'Mozambique', 0, 258),
  ('+260', 'Zambia', 0, 260),
  ('+261', 'Madagascar', 0, 261),
  ('+262', 'French Departments and Territories in the Indian Ocean', 0, 262),
  ('+263', 'Zimbabwe', 0, 263),
  ('+264', 'Namibia', 0, 264),
  ('+265', 'Malawi', 0, 265),
  ('+266', 'Lesotho', 0, 266),
  ('+267', 'Botswana', 0, 267),
  ('+268', 'Swaziland', 0, 268),
  ('+269', 'Comoros', 0, 269),
  ('+290', 'Saint Helena, Ascension and Tristan da Cunha', 0, 290),
  ('+291', 'Eritrea', 0, 291),
  ('+297', 'Aruba', 0, 297),
  ('+298', 'Faroe Islands', 0, 298),
  ('+299', 'Greenland', 0, 299),
  ('+350', 'Gibraltar', 0, 350),
  ('+351', 'Portugal', 0, 351),
  ('+352', 'Luxembourg', 0, 352),
  ('+353', 'Ireland', 0, 353),
  ('+354', 'Iceland', 0, 354),
  ('+355', 'Albania', 0, 355),
  ('+356', 'Malta', 0, 356),
  ('+357', 'Cyprus', 0, 357),
  ('+358', 'Finland', 0, 358),
  ('+359', 'Bulgaria', 0, 359),
  ('+370', 'Lithuania', 0, 370),
  ('+371', 'Latvia', 0, 371),
  ('+372', 'Estonia', 0, 372),
  ('+373', 'Moldova', 0, 373),
  ('+374', 'Armenia', 0, 374),
  ('+375', 'Belarus', 0, 375),
  ('+376', 'Andorra', 0, 376),
  ('+377', 'Monaco', 0, 377),
  ('+378', 'San Marino', 0, 378),
  ('+379', 'Vatican City State', 0, 379),
  ('+380', 'Ukraine', 0, 380),
  ('+381', 'Serbia', 0, 381),
  ('+382', 'Montenegro', 0, 382),
  ('+383', 'Kosovo', 0, 383),
  ('+385', 'Croatia', 0, 385),
  ('+386', 'Slovenia', 0, 386),
  ('+387', 'Bosnia and Herzegovina', 0, 387),
  ('+389', 'North Macedonia', 0, 389),
  ('+420', 'Czech Republic', 0, 420),
  ('+421', 'Slovak Republic', 0, 421),
  ('+423', 'Liechtenstein', 0, 423),
  ('+500', 'Falkland Islands', 0, 500),
  ('+501', 'Belize', 0, 501),
  ('+502', 'Guatemala', 0, 502),
  ('+503', 'El Salvador', 0, 503),
  ('+504', 'Honduras', 0, 504),
  ('+505', 'Nicaragua', 0, 505),
  ('+506', 'Costa Rica', 0, 506),
  ('+507', 'Panama', 0, 507),
  ('+508', 'Saint Pierre and Miquelon', 0, 508),
  ('+509', 'Haiti', 0, 509),
  ('+590', 'Guadeloupe', 0, 590),
  ('+591', 'Bolivia', 0, 591),
  ('+592', 'Guyana', 0, 592),
  ('+593', 'Ecuador', 0, 593),
  ('+594', 'French Guiana', 0, 594),
  ('+595', 'Paraguay', 0, 595),
  ('+596', 'Martinique', 0, 596),
  ('+597', 'Suriname', 0, 597),
  ('+598', 'Uruguay', 0, 598),
  ('+599', 'Bonaire, Sint Eustatius and Saba / Curacao', 0, 599),
  ('+670', 'Timor-Leste', 0, 670),
  ('+672', 'Australian External Territories', 0, 672),
  ('+673', 'Brunei Darussalam', 0, 673),
  ('+674', 'Nauru', 0, 674),
  ('+675', 'Papua New Guinea', 0, 675),
  ('+676', 'Tonga', 0, 676),
  ('+677', 'Solomon Islands', 0, 677),
  ('+678', 'Vanuatu', 0, 678),
  ('+679', 'Fiji', 0, 679),
  ('+680', 'Palau', 0, 680),
  ('+681', 'Wallis and Futuna', 0, 681),
  ('+682', 'Cook Islands', 0, 682),
  ('+683', 'Niue', 0, 683),
  ('+685', 'Samoa', 0, 685),
  ('+686', 'Kiribati', 0, 686),
  ('+687', 'New Caledonia', 0, 687),
  ('+688', 'Tuvalu', 0, 688),
  ('+689', 'French Polynesia', 0, 689),
  ('+690', 'Tokelau', 0, 690),
  ('+691', 'Micronesia', 0, 691),
  ('+692', 'Marshall Islands', 0, 692),
  ('+850', 'Democratic People''s Republic of Korea', 0, 850),
  ('+852', 'Hong Kong, China', 0, 852),
  ('+853', 'Macao, China', 0, 853),
  ('+855', 'Cambodia', 0, 855),
  ('+856', 'Lao People''s Democratic Republic', 0, 856),
  ('+880', 'Bangladesh', 0, 880),
  ('+886', 'Taiwan, China', 0, 886),
  ('+960', 'Maldives', 0, 960),
  ('+961', 'Lebanon', 0, 961),
  ('+962', 'Jordan', 0, 962),
  ('+963', 'Syrian Arab Republic', 0, 963),
  ('+964', 'Iraq', 0, 964),
  ('+965', 'Kuwait', 0, 965),
  ('+966', 'Saudi Arabia', 0, 966),
  ('+967', 'Yemen', 0, 967),
  ('+968', 'Oman', 0, 968),
  ('+971', 'United Arab Emirates', 0, 971),
  ('+972', 'Israel', 0, 972),
  ('+973', 'Bahrain', 0, 973),
  ('+974', 'Qatar', 0, 974),
  ('+975', 'Bhutan', 0, 975),
  ('+976', 'Mongolia', 0, 976),
  ('+977', 'Nepal', 0, 977),
  ('+992', 'Tajikistan', 0, 992),
  ('+993', 'Turkmenistan', 0, 993),
  ('+994', 'Azerbaijan', 0, 994),
  ('+995', 'Georgia', 0, 995),
  ('+996', 'Kyrgyz Republic', 0, 996),
  ('+998', 'Uzbekistan', 0, 998);
INSERT INTO schema_migrations (migration) VALUES
  ('2026_05_07_001_initial_schema.sql'),
  ('2026_05_08_001_schema_integrity.sql'),
  ('2026_05_08_002_force_password_change.sql'),
  ('2026_05_08_003_user_otp_optional.sql'),
  ('2026_05_09_001_login_lockout_reset_audit.sql'),
  ('2026_05_14_001_application_activity_flash_history.sql'),
  ('2026_06_01_001_user_mobile_number.sql'),
  ('2026_06_01_002_mobile_country_codes.sql'),
  ('2026_06_01_003_invited_account_completion.sql'),
  ('2026_06_15_001_invite_deliveries.sql'),
  ('2026_06_15_002_signup_token_rate_limits.sql'),
  ('2026_06_15_003_signup_verification_rate_limits.sql'),
  ('2026_06_30_001_warning_flash_messages.sql'),
  ('2026_10_12_001_user_restored_audit.sql');
