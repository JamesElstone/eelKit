-- Representative pre-migration MySQL/MariaDB schema for upgrade regression tests.
CREATE TABLE schema_migrations (
  `migration` varchar(255) NOT NULL,
  `applied_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`migration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE roles (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_name` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_roles_role_name` (`role_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE users (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `display_name` varchar(255) NOT NULL,
  `email_address` varchar(255) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `current_session_token_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `current_session_started_at` datetime DEFAULT NULL,
  `current_session_last_seen_at` datetime DEFAULT NULL,
  `current_session_device_id` varchar(64) DEFAULT NULL,
  `current_session_ip_address` varchar(45) DEFAULT NULL,
  `current_session_user_agent` varchar(1000) DEFAULT NULL,
  `current_session_browser_label` varchar(255) DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `password_changed_at` datetime DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `role_id` int(11) NOT NULL DEFAULT -1,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email_address` (`email_address`),
  UNIQUE KEY `uq_users_current_session_token_hash` (`current_session_token_hash`),
  KEY `idx_users_role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE role_card_permissions (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) NOT NULL,
  `card_key` varchar(255) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_role_card_permissions_role_card` (`role_id`,`card_key`),
  KEY `idx_role_card_permissions_card_key` (`card_key`),
  CONSTRAINT `fk_role_card_permissions_role` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE user_login_rate_limits (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `email_address` varchar(255) NOT NULL,
  `scope_type` varchar(20) NOT NULL DEFAULT 'email',
  `scope_key` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `consecutive_failed_password_attempts` int(10) unsigned NOT NULL DEFAULT 0,
  `failed_attempt_window_started_at` datetime DEFAULT NULL,
  `last_failed_password_attempt_at` datetime DEFAULT NULL,
  `next_allowed_login_at` datetime DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `lock_reason` varchar(100) DEFAULT NULL,
  `lock_expires_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_login_rate_limits_scope` (`scope_type`,`scope_key`),
  KEY `idx_user_login_rate_limits_email_address` (`email_address`),
  KEY `idx_user_login_rate_limits_user_id` (`user_id`),
  KEY `idx_user_login_rate_limits_next_allowed_login_at` (`next_allowed_login_at`),
  KEY `idx_user_login_rate_limits_locked_at` (`locked_at`),
  KEY `idx_user_login_rate_limits_lock_expires_at` (`lock_expires_at`),
  CONSTRAINT `fk_user_login_rate_limits_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE user_account_audit (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `affected_user_id` int(11) NOT NULL,
  `actor_user_id` int(11) DEFAULT NULL,
  action_type enum('user_created','user_enabled','user_disabled','password_set_admin','password_changed_self','email_changed','display_name_changed','otp_reset_admin','otp_rotation_started','otp_rotation_completed','mfa_authenticated','role_changed') NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `details_json` longtext DEFAULT NULL,
  `device_id` varchar(64) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(1000) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_account_audit_affected_time` (`affected_user_id`,`created_at`),
  KEY `idx_user_account_audit_actor_time` (`actor_user_id`,`created_at`),
  KEY `idx_user_account_audit_action_time` (`action_type`,`created_at`),
  CONSTRAINT `fk_user_account_audit_actor_user` FOREIGN KEY (`actor_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_user_account_audit_affected_user` FOREIGN KEY (`affected_user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE user_logon_history (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `attempted_email_address` varchar(255) DEFAULT NULL,
  `event_type` enum('login_succeeded','login_failed','logout','forced_logout','session_replaced','otp_challenge_passed','otp_challenge_failed','otp_setup_started','otp_setup_completed') NOT NULL,
  `success` tinyint(1) NOT NULL DEFAULT 1,
  `reason` varchar(255) DEFAULT NULL,
  `session_token_hash` char(64) CHARACTER SET ascii COLLATE ascii_bin DEFAULT NULL,
  `device_id` varchar(64) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` varchar(1000) DEFAULT NULL,
  `browser_label` varchar(255) DEFAULT NULL,
  `occurred_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_user_logon_history_user_time` (`user_id`,`occurred_at`),
  KEY `idx_user_logon_history_email_time` (`attempted_email_address`,`occurred_at`),
  KEY `idx_user_logon_history_token` (`session_token_hash`),
  KEY `idx_user_logon_history_event_time` (`event_type`,`occurred_at`),
  CONSTRAINT `fk_user_logon_history_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE TABLE user_totp (
  `user_id` int(11) NOT NULL,
  `otp_secret` varchar(128) DEFAULT NULL,
  `pending_otp_secret` varchar(128) DEFAULT NULL,
  `pending_otp_algorithm` enum('SHA1','SHA256','SHA512') DEFAULT NULL,
  `pending_otp_digits` tinyint(2) DEFAULT NULL,
  `pending_otp_period` int(11) DEFAULT NULL,
  `pending_otp_requested_at` datetime DEFAULT NULL,
  `otp_algorithm` enum('SHA1','SHA256','SHA512') NOT NULL DEFAULT 'SHA1',
  `otp_digits` tinyint(2) NOT NULL DEFAULT 6,
  `otp_period` int(11) NOT NULL DEFAULT 30,
  `otp_enabled` tinyint(1) NOT NULL DEFAULT 0,
  `otp_confirmed_at` datetime DEFAULT NULL,
  `otp_last_used_timestep` bigint(20) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `updated_at` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_user_totp_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
INSERT INTO schema_migrations (migration) VALUES ('2026_05_07_001_initial_schema.sql');
