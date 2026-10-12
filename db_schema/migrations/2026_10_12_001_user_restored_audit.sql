-- The restore-user service already emits this audit event. Enforce the same domain on every backend.
-- Align upgraded databases with the canonical nullable invited-account email column.
ALTER TABLE users DROP CONSTRAINT IF EXISTS chk_users_email_address_not_blank;

ALTER TABLE user_account_audit
  MODIFY action_type enum('user_created','user_enabled','user_disabled','password_set_admin','password_change_required_admin','password_changed_self','email_changed','display_name_changed','mobile_number_changed','otp_requirement_changed','otp_reset_admin','login_lockout_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed','invite_created','invite_link_copied','invite_email_sent','invite_sms_sent','invite_opened','invite_verification_failed','invite_verification_succeeded','invite_completion_failed','invite_completed','invite_expired','invite_revoked','invite_locked','user_restored') NOT NULL;
