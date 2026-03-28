/** @architect */

/**
 * @architect-pattern NotificationService
 * @architect-status roadmap
 * @architect-infra
 * @architect-arch-role service
 * @architect-arch-context identity
 * @architect-arch-layer infrastructure
 * @architect-target src/sample-sources/notification-service.ts
 * @architect-since design-session-1
 * @architect-uses AuthHandler
 * @architect-phase 2
 * @architect-release vNEXT
 * @architect-brief Notification service for auth lifecycle events
 * @architect-usecase "Send welcome email after user registration"
 * @architect-usecase "Send login alert for new device"
 * @architect-quarter Q2-2026
 * @architect-extract-shapes NotificationConfig, NotificationResult
 *
 * ## NotificationService - Auth Event Notifications
 *
 * Sends notifications (email, SMS) when authentication lifecycle
 * events occur. Stub — target implementation does not exist yet.
 *
 * ### Design Decisions
 *
 * AD-1: Use event-driven notifications (not inline calls)
 * AD-2: Support multiple channels via strategy pattern
 *
 * ### When to Use
 *
 * - When sending post-registration welcome emails
 * - When alerting users about new device logins
 */

/** @architect-shape reference-sample */
export interface NotificationConfig {
  channel: "email" | "sms";
  template: string;
  recipientId: string;
}

/** @architect-shape reference-sample */
export interface NotificationResult {
  sent: boolean;
  channel: string;
  timestamp: Date;
}
