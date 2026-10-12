-- Native SQLite equivalent of 2026_06_15_002_signup_token_rate_limits.sql
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
