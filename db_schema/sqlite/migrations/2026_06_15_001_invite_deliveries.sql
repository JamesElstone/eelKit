-- Native SQLite equivalent of 2026_06_15_001_invite_deliveries.sql
CREATE TABLE "__eelkit_user_account_invites" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -2147483648 AND 2147483647),
  "user_id" INTEGER NOT NULL CHECK ("user_id" IS NULL OR (typeof("user_id") = 'integer' AND "user_id" BETWEEN -2147483648 AND 2147483647)),
  "token_hash" TEXT COLLATE BINARY NOT NULL CHECK ("token_hash" IS NULL OR eelkit_char_length("token_hash") <= 64 AND eelkit_ascii("token_hash")),
  "purpose" TEXT COLLATE eelkit_unicode_ci NOT NULL DEFAULT 'account_completion' CHECK ("purpose" IS NULL OR eelkit_char_length("purpose") <= 50),
  "status" TEXT COLLATE eelkit_unicode_ci NOT NULL DEFAULT 'pending' CHECK ("status" IS NULL OR eelkit_char_length("status") <= 30),
  "contact_method" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("contact_method" IS NULL OR eelkit_char_length("contact_method") <= 20),
  "sent_to" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("sent_to" IS NULL OR eelkit_char_length("sent_to") <= 255),
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
  CONSTRAINT chk_user_account_invites_status_not_blank CHECK (status <> ''),
  CONSTRAINT chk_user_account_invites_contact_method_not_blank CHECK (contact_method <> ''),
  CONSTRAINT chk_user_account_invites_sent_to_not_blank CHECK (sent_to <> '')
);
INSERT INTO "__eelkit_user_account_invites" ("id","user_id","token_hash","purpose","status","contact_method","sent_to","expires_at","used_at","revoked_at","created_at","created_by_user_id","last_sent_at","send_attempts","failed_attempts","last_failed_at","next_allowed_attempt_at","locked_at","lock_expires_at","opened_at","verified_at","completed_at","ip_created","ip_opened","ip_used") SELECT "id","user_id","token_hash","purpose","status","contact_method","sent_to","expires_at","used_at","revoked_at","created_at","created_by_user_id","last_sent_at","send_attempts","failed_attempts","last_failed_at","next_allowed_attempt_at","locked_at","lock_expires_at","opened_at","verified_at","completed_at","ip_created","ip_opened","ip_used" FROM "user_account_invites";
DROP TABLE "user_account_invites";
ALTER TABLE "__eelkit_user_account_invites" RENAME TO "user_account_invites";
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
INSERT INTO user_account_invite_deliveries (
  invite_id,
  contact_method,
  sent_to,
  status,
  sent_at,
  created_at,
  created_by_user_id,
  error_summary
)
SELECT invites.id,
       invites.contact_method,
       invites.sent_to,
       CASE WHEN invites.last_sent_at IS NOT NULL THEN 'sent' ELSE 'created' END,
       invites.last_sent_at,
       invites.created_at,
       invites.created_by_user_id,
       NULL
FROM user_account_invites invites
WHERE invites.contact_method <> ''
  AND invites.sent_to <> ''
  AND NOT EXISTS (
    SELECT 1
    FROM user_account_invite_deliveries existing
    WHERE existing.invite_id = invites.id
      AND existing.contact_method = invites.contact_method
      AND existing.sent_to = invites.sent_to
  );
CREATE TABLE "__eelkit_user_account_invites" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -2147483648 AND 2147483647),
  "user_id" INTEGER NOT NULL CHECK ("user_id" IS NULL OR (typeof("user_id") = 'integer' AND "user_id" BETWEEN -2147483648 AND 2147483647)),
  "token_hash" TEXT COLLATE BINARY NOT NULL CHECK ("token_hash" IS NULL OR eelkit_char_length("token_hash") <= 64 AND eelkit_ascii("token_hash")),
  "purpose" TEXT COLLATE eelkit_unicode_ci NOT NULL DEFAULT 'account_completion' CHECK ("purpose" IS NULL OR eelkit_char_length("purpose") <= 50),
  "status" TEXT COLLATE eelkit_unicode_ci NOT NULL DEFAULT 'pending' CHECK ("status" IS NULL OR eelkit_char_length("status") <= 30),
  "contact_method" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("contact_method" IS NULL OR eelkit_char_length("contact_method") <= 20),
  "sent_to" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("sent_to" IS NULL OR eelkit_char_length("sent_to") <= 255),
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
  CONSTRAINT chk_user_account_invites_status_not_blank CHECK (status <> ''),
  CONSTRAINT chk_user_account_invites_sent_to_not_blank CHECK (sent_to <> '')
);
INSERT INTO "__eelkit_user_account_invites" ("id","user_id","token_hash","purpose","status","contact_method","sent_to","expires_at","used_at","revoked_at","created_at","created_by_user_id","last_sent_at","send_attempts","failed_attempts","last_failed_at","next_allowed_attempt_at","locked_at","lock_expires_at","opened_at","verified_at","completed_at","ip_created","ip_opened","ip_used","token_value") SELECT "id","user_id","token_hash","purpose","status","contact_method","sent_to","expires_at","used_at","revoked_at","created_at","created_by_user_id","last_sent_at","send_attempts","failed_attempts","last_failed_at","next_allowed_attempt_at","locked_at","lock_expires_at","opened_at","verified_at","completed_at","ip_created","ip_opened","ip_used","token_value" FROM "user_account_invites";
DROP TABLE "user_account_invites";
ALTER TABLE "__eelkit_user_account_invites" RENAME TO "user_account_invites";
CREATE UNIQUE INDEX "uq_user_account_invites_token_hash" ON "user_account_invites" (token_hash);
CREATE INDEX "idx_user_account_invites_user_id" ON "user_account_invites" (user_id);
CREATE INDEX "idx_user_account_invites_status" ON "user_account_invites" (status);
CREATE INDEX "idx_user_account_invites_expires_at" ON "user_account_invites" (expires_at);
CREATE TABLE "__eelkit_user_account_invites" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT CHECK ("id" BETWEEN -2147483648 AND 2147483647),
  "user_id" INTEGER NOT NULL CHECK ("user_id" IS NULL OR (typeof("user_id") = 'integer' AND "user_id" BETWEEN -2147483648 AND 2147483647)),
  "token_hash" TEXT COLLATE BINARY NOT NULL CHECK ("token_hash" IS NULL OR eelkit_char_length("token_hash") <= 64 AND eelkit_ascii("token_hash")),
  "purpose" TEXT COLLATE eelkit_unicode_ci NOT NULL DEFAULT 'account_completion' CHECK ("purpose" IS NULL OR eelkit_char_length("purpose") <= 50),
  "status" TEXT COLLATE eelkit_unicode_ci NOT NULL DEFAULT 'pending' CHECK ("status" IS NULL OR eelkit_char_length("status") <= 30),
  "contact_method" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("contact_method" IS NULL OR eelkit_char_length("contact_method") <= 20),
  "sent_to" TEXT COLLATE eelkit_unicode_ci NOT NULL CHECK ("sent_to" IS NULL OR eelkit_char_length("sent_to") <= 255),
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
INSERT INTO "__eelkit_user_account_invites" ("id","user_id","token_hash","purpose","status","contact_method","sent_to","expires_at","used_at","revoked_at","created_at","created_by_user_id","last_sent_at","send_attempts","failed_attempts","last_failed_at","next_allowed_attempt_at","locked_at","lock_expires_at","opened_at","verified_at","completed_at","ip_created","ip_opened","ip_used","token_value") SELECT "id","user_id","token_hash","purpose","status","contact_method","sent_to","expires_at","used_at","revoked_at","created_at","created_by_user_id","last_sent_at","send_attempts","failed_attempts","last_failed_at","next_allowed_attempt_at","locked_at","lock_expires_at","opened_at","verified_at","completed_at","ip_created","ip_opened","ip_used","token_value" FROM "user_account_invites";
DROP TABLE "user_account_invites";
ALTER TABLE "__eelkit_user_account_invites" RENAME TO "user_account_invites";
CREATE UNIQUE INDEX "uq_user_account_invites_token_hash" ON "user_account_invites" (token_hash);
CREATE INDEX "idx_user_account_invites_user_id" ON "user_account_invites" (user_id);
CREATE INDEX "idx_user_account_invites_status" ON "user_account_invites" (status);
CREATE INDEX "idx_user_account_invites_expires_at" ON "user_account_invites" (expires_at);
CREATE TABLE "__eelkit_user_account_invites" (
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
INSERT INTO "__eelkit_user_account_invites" ("id","user_id","token_hash","purpose","status","expires_at","used_at","revoked_at","created_at","created_by_user_id","last_sent_at","send_attempts","failed_attempts","last_failed_at","next_allowed_attempt_at","locked_at","lock_expires_at","opened_at","verified_at","completed_at","ip_created","ip_opened","ip_used","token_value") SELECT "id","user_id","token_hash","purpose","status","expires_at","used_at","revoked_at","created_at","created_by_user_id","last_sent_at","send_attempts","failed_attempts","last_failed_at","next_allowed_attempt_at","locked_at","lock_expires_at","opened_at","verified_at","completed_at","ip_created","ip_opened","ip_used","token_value" FROM "user_account_invites";
DROP TABLE "user_account_invites";
ALTER TABLE "__eelkit_user_account_invites" RENAME TO "user_account_invites";
CREATE UNIQUE INDEX "uq_user_account_invites_token_hash" ON "user_account_invites" (token_hash);
CREATE INDEX "idx_user_account_invites_user_id" ON "user_account_invites" (user_id);
CREATE INDEX "idx_user_account_invites_status" ON "user_account_invites" (status);
CREATE INDEX "idx_user_account_invites_expires_at" ON "user_account_invites" (expires_at);
