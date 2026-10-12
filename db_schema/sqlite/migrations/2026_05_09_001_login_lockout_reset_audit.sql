-- Native SQLite equivalent of 2026_05_09_001_login_lockout_reset_audit.sql
CREATE TABLE "__eelkit_user_account_audit" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -9223372036854775808 AND 9223372036854775807),
  "affected_user_id" INTEGER NOT NULL CHECK ("affected_user_id" IS NULL OR (typeof("affected_user_id") = 'integer' AND "affected_user_id" BETWEEN -2147483648 AND 2147483647)),
  "actor_user_id" INTEGER DEFAULT NULL CHECK ("actor_user_id" IS NULL OR (typeof("actor_user_id") = 'integer' AND "actor_user_id" BETWEEN -2147483648 AND 2147483647)),
  "action_type" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("action_type" IS NULL OR "action_type" IN ('user_created','user_enabled','user_disabled','password_set_admin','password_change_required_admin','password_changed_self','email_changed','display_name_changed','otp_requirement_changed','otp_reset_admin','login_lockout_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed')),
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
WHEN (NEW."action_type" IS NOT NULL AND NEW."action_type" COLLATE BINARY NOT IN ('user_created','user_enabled','user_disabled','password_set_admin','password_change_required_admin','password_changed_self','email_changed','display_name_changed','otp_requirement_changed','otp_reset_admin','login_lockout_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed'))
BEGIN
  UPDATE "user_account_audit" SET "action_type" = CASE WHEN NEW."action_type" = 'user_created' THEN 'user_created' WHEN NEW."action_type" = 'user_enabled' THEN 'user_enabled' WHEN NEW."action_type" = 'user_disabled' THEN 'user_disabled' WHEN NEW."action_type" = 'password_set_admin' THEN 'password_set_admin' WHEN NEW."action_type" = 'password_change_required_admin' THEN 'password_change_required_admin' WHEN NEW."action_type" = 'password_changed_self' THEN 'password_changed_self' WHEN NEW."action_type" = 'email_changed' THEN 'email_changed' WHEN NEW."action_type" = 'display_name_changed' THEN 'display_name_changed' WHEN NEW."action_type" = 'otp_requirement_changed' THEN 'otp_requirement_changed' WHEN NEW."action_type" = 'otp_reset_admin' THEN 'otp_reset_admin' WHEN NEW."action_type" = 'login_lockout_reset_admin' THEN 'login_lockout_reset_admin' WHEN NEW."action_type" = 'otp_rotation_started' THEN 'otp_rotation_started' WHEN NEW."action_type" = 'otp_rotation_completed' THEN 'otp_rotation_completed' WHEN NEW."action_type" = 'mfa_authenticated' THEN 'mfa_authenticated' WHEN NEW."action_type" = 'role_changed' THEN 'role_changed' ELSE NEW."action_type" END WHERE "id" = NEW."id";
END;
CREATE TRIGGER "eelkit_user_account_audit_enum_update" AFTER UPDATE ON "user_account_audit"
WHEN (NEW."action_type" IS NOT NULL AND NEW."action_type" COLLATE BINARY NOT IN ('user_created','user_enabled','user_disabled','password_set_admin','password_change_required_admin','password_changed_self','email_changed','display_name_changed','otp_requirement_changed','otp_reset_admin','login_lockout_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed'))
BEGIN
  UPDATE "user_account_audit" SET "action_type" = CASE WHEN NEW."action_type" = 'user_created' THEN 'user_created' WHEN NEW."action_type" = 'user_enabled' THEN 'user_enabled' WHEN NEW."action_type" = 'user_disabled' THEN 'user_disabled' WHEN NEW."action_type" = 'password_set_admin' THEN 'password_set_admin' WHEN NEW."action_type" = 'password_change_required_admin' THEN 'password_change_required_admin' WHEN NEW."action_type" = 'password_changed_self' THEN 'password_changed_self' WHEN NEW."action_type" = 'email_changed' THEN 'email_changed' WHEN NEW."action_type" = 'display_name_changed' THEN 'display_name_changed' WHEN NEW."action_type" = 'otp_requirement_changed' THEN 'otp_requirement_changed' WHEN NEW."action_type" = 'otp_reset_admin' THEN 'otp_reset_admin' WHEN NEW."action_type" = 'login_lockout_reset_admin' THEN 'login_lockout_reset_admin' WHEN NEW."action_type" = 'otp_rotation_started' THEN 'otp_rotation_started' WHEN NEW."action_type" = 'otp_rotation_completed' THEN 'otp_rotation_completed' WHEN NEW."action_type" = 'mfa_authenticated' THEN 'mfa_authenticated' WHEN NEW."action_type" = 'role_changed' THEN 'role_changed' ELSE NEW."action_type" END WHERE "id" = NEW."id";
END;
