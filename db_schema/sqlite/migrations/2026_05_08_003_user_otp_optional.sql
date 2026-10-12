-- Native SQLite equivalent of 2026_05_08_003_user_otp_optional.sql
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
  "must_change_password" INTEGER NOT NULL DEFAULT 0 CHECK ("must_change_password" IS NULL OR (typeof("must_change_password") = 'integer' AND "must_change_password" BETWEEN -128 AND 127)),
  "otp_required" INTEGER NOT NULL DEFAULT 1 CHECK ("otp_required" IS NULL OR (typeof("otp_required") = 'integer' AND "otp_required" BETWEEN -128 AND 127)),
  CONSTRAINT chk_users_email_address_not_blank
  CHECK (email_address <> ''),
  CONSTRAINT chk_users_role_id_reserved_or_positive
  CHECK (role_id = -1 OR role_id > 0)
);
INSERT INTO "__eelkit_users" ("id","display_name","email_address","password_hash","current_session_token_hash","current_session_started_at","current_session_last_seen_at","current_session_device_id","current_session_ip_address","current_session_user_agent","current_session_browser_label","last_login_at","password_changed_at","is_active","role_id","created_at","updated_at","must_change_password") SELECT "id","display_name","email_address","password_hash","current_session_token_hash","current_session_started_at","current_session_last_seen_at","current_session_device_id","current_session_ip_address","current_session_user_agent","current_session_browser_label","last_login_at","password_changed_at","is_active","role_id","created_at","updated_at","must_change_password" FROM "users";
DROP TABLE "users";
ALTER TABLE "__eelkit_users" RENAME TO "users";
CREATE UNIQUE INDEX "uq_users_email_address" ON "users" ("email_address");
CREATE UNIQUE INDEX "uq_users_current_session_token_hash" ON "users" ("current_session_token_hash");
CREATE INDEX "idx_users_role_id" ON "users" ("role_id");
CREATE TRIGGER "eelkit_users_updated_at" AFTER UPDATE ON "users"
WHEN NEW.updated_at IS OLD.updated_at AND (NEW."id" COLLATE BINARY IS NOT OLD."id" COLLATE BINARY OR NEW."display_name" COLLATE BINARY IS NOT OLD."display_name" COLLATE BINARY OR NEW."email_address" COLLATE BINARY IS NOT OLD."email_address" COLLATE BINARY OR NEW."password_hash" COLLATE BINARY IS NOT OLD."password_hash" COLLATE BINARY OR NEW."current_session_token_hash" COLLATE BINARY IS NOT OLD."current_session_token_hash" COLLATE BINARY OR NEW."current_session_started_at" COLLATE BINARY IS NOT OLD."current_session_started_at" COLLATE BINARY OR NEW."current_session_last_seen_at" COLLATE BINARY IS NOT OLD."current_session_last_seen_at" COLLATE BINARY OR NEW."current_session_device_id" COLLATE BINARY IS NOT OLD."current_session_device_id" COLLATE BINARY OR NEW."current_session_ip_address" COLLATE BINARY IS NOT OLD."current_session_ip_address" COLLATE BINARY OR NEW."current_session_user_agent" COLLATE BINARY IS NOT OLD."current_session_user_agent" COLLATE BINARY OR NEW."current_session_browser_label" COLLATE BINARY IS NOT OLD."current_session_browser_label" COLLATE BINARY OR NEW."last_login_at" COLLATE BINARY IS NOT OLD."last_login_at" COLLATE BINARY OR NEW."password_changed_at" COLLATE BINARY IS NOT OLD."password_changed_at" COLLATE BINARY OR NEW."is_active" COLLATE BINARY IS NOT OLD."is_active" COLLATE BINARY OR NEW."role_id" COLLATE BINARY IS NOT OLD."role_id" COLLATE BINARY OR NEW."created_at" COLLATE BINARY IS NOT OLD."created_at" COLLATE BINARY OR NEW."must_change_password" COLLATE BINARY IS NOT OLD."must_change_password" COLLATE BINARY OR NEW."otp_required" COLLATE BINARY IS NOT OLD."otp_required" COLLATE BINARY)
BEGIN
  UPDATE "users" SET updated_at = CURRENT_TIMESTAMP WHERE "id" = NEW."id";
END;
CREATE TABLE "__eelkit_user_account_audit" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -9223372036854775808 AND 9223372036854775807),
  "affected_user_id" INTEGER NOT NULL CHECK ("affected_user_id" IS NULL OR (typeof("affected_user_id") = 'integer' AND "affected_user_id" BETWEEN -2147483648 AND 2147483647)),
  "actor_user_id" INTEGER DEFAULT NULL CHECK ("actor_user_id" IS NULL OR (typeof("actor_user_id") = 'integer' AND "actor_user_id" BETWEEN -2147483648 AND 2147483647)),
  "action_type" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("action_type" IS NULL OR "action_type" IN ('user_created','user_enabled','user_disabled','password_set_admin','password_change_required_admin','password_changed_self','email_changed','display_name_changed','otp_requirement_changed','otp_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed')),
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
WHEN (NEW."action_type" IS NOT NULL AND NEW."action_type" COLLATE BINARY NOT IN ('user_created','user_enabled','user_disabled','password_set_admin','password_change_required_admin','password_changed_self','email_changed','display_name_changed','otp_requirement_changed','otp_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed'))
BEGIN
  UPDATE "user_account_audit" SET "action_type" = CASE WHEN NEW."action_type" = 'user_created' THEN 'user_created' WHEN NEW."action_type" = 'user_enabled' THEN 'user_enabled' WHEN NEW."action_type" = 'user_disabled' THEN 'user_disabled' WHEN NEW."action_type" = 'password_set_admin' THEN 'password_set_admin' WHEN NEW."action_type" = 'password_change_required_admin' THEN 'password_change_required_admin' WHEN NEW."action_type" = 'password_changed_self' THEN 'password_changed_self' WHEN NEW."action_type" = 'email_changed' THEN 'email_changed' WHEN NEW."action_type" = 'display_name_changed' THEN 'display_name_changed' WHEN NEW."action_type" = 'otp_requirement_changed' THEN 'otp_requirement_changed' WHEN NEW."action_type" = 'otp_reset_admin' THEN 'otp_reset_admin' WHEN NEW."action_type" = 'otp_rotation_started' THEN 'otp_rotation_started' WHEN NEW."action_type" = 'otp_rotation_completed' THEN 'otp_rotation_completed' WHEN NEW."action_type" = 'mfa_authenticated' THEN 'mfa_authenticated' WHEN NEW."action_type" = 'role_changed' THEN 'role_changed' ELSE NEW."action_type" END WHERE "id" = NEW."id";
END;
CREATE TRIGGER "eelkit_user_account_audit_enum_update" AFTER UPDATE ON "user_account_audit"
WHEN (NEW."action_type" IS NOT NULL AND NEW."action_type" COLLATE BINARY NOT IN ('user_created','user_enabled','user_disabled','password_set_admin','password_change_required_admin','password_changed_self','email_changed','display_name_changed','otp_requirement_changed','otp_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed'))
BEGIN
  UPDATE "user_account_audit" SET "action_type" = CASE WHEN NEW."action_type" = 'user_created' THEN 'user_created' WHEN NEW."action_type" = 'user_enabled' THEN 'user_enabled' WHEN NEW."action_type" = 'user_disabled' THEN 'user_disabled' WHEN NEW."action_type" = 'password_set_admin' THEN 'password_set_admin' WHEN NEW."action_type" = 'password_change_required_admin' THEN 'password_change_required_admin' WHEN NEW."action_type" = 'password_changed_self' THEN 'password_changed_self' WHEN NEW."action_type" = 'email_changed' THEN 'email_changed' WHEN NEW."action_type" = 'display_name_changed' THEN 'display_name_changed' WHEN NEW."action_type" = 'otp_requirement_changed' THEN 'otp_requirement_changed' WHEN NEW."action_type" = 'otp_reset_admin' THEN 'otp_reset_admin' WHEN NEW."action_type" = 'otp_rotation_started' THEN 'otp_rotation_started' WHEN NEW."action_type" = 'otp_rotation_completed' THEN 'otp_rotation_completed' WHEN NEW."action_type" = 'mfa_authenticated' THEN 'mfa_authenticated' WHEN NEW."action_type" = 'role_changed' THEN 'role_changed' ELSE NEW."action_type" END WHERE "id" = NEW."id";
END;
