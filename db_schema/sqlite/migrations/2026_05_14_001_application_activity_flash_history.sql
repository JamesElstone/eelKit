-- Native SQLite equivalent of 2026_05_14_001_application_activity_flash_history.sql
CREATE TABLE "application_activity_flash_history" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -9223372036854775808 AND 9223372036854775807),
  "user_id" INTEGER DEFAULT NULL CHECK ("user_id" IS NULL OR (typeof("user_id") = 'integer' AND "user_id" BETWEEN -2147483648 AND 2147483647)),
  "page_id" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("page_id" IS NULL OR eelkit_char_length("page_id") <= 255),
  "action_name" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("action_name" IS NULL OR eelkit_char_length("action_name") <= 255),
  "card_action_name" TEXT COLLATE eelkit_unicode_ci DEFAULT NULL CHECK ("card_action_name" IS NULL OR eelkit_char_length("card_action_name") <= 255),
  "message_type" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("message_type" IS NULL OR "message_type" IN ('success','error')),
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
WHEN (NEW."message_type" IS NOT NULL AND NEW."message_type" COLLATE BINARY NOT IN ('success','error'))
BEGIN
  UPDATE "application_activity_flash_history" SET "message_type" = CASE WHEN NEW."message_type" = 'success' THEN 'success' WHEN NEW."message_type" = 'error' THEN 'error' ELSE NEW."message_type" END WHERE "id" = NEW."id";
END;
CREATE TRIGGER "eelkit_application_activity_flash_history_enum_update" AFTER UPDATE ON "application_activity_flash_history"
WHEN (NEW."message_type" IS NOT NULL AND NEW."message_type" COLLATE BINARY NOT IN ('success','error'))
BEGIN
  UPDATE "application_activity_flash_history" SET "message_type" = CASE WHEN NEW."message_type" = 'success' THEN 'success' WHEN NEW."message_type" = 'error' THEN 'error' ELSE NEW."message_type" END WHERE "id" = NEW."id";
END;
