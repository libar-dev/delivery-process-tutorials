/** @libar-docs */

/**
 * @libar-docs-pattern NotificationService
 * @libar-docs-status roadmap
 * @libar-docs-infra
 * @libar-docs-arch-role service
 * @libar-docs-arch-context identity
 * @libar-docs-arch-layer infrastructure
 * @libar-docs-target src/sample-sources/notification-service.ts
 * @libar-docs-since design-session-1
 * @libar-docs-uses AuthHandler
 * @libar-docs-phase 2
 * @libar-docs-release vNEXT
 * @libar-docs-brief Notification service for auth lifecycle events
 * @libar-docs-usecase "Send welcome email after user registration"
 * @libar-docs-usecase "Send login alert for new device"
 * @libar-docs-quarter Q2-2026
 * @libar-docs-extract-shapes NotificationConfig, NotificationResult
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

/** @libar-docs-shape reference-sample */
export interface NotificationConfig {
  channel: "email" | "sms";
  template: string;
  recipientId: string;
}

/** @libar-docs-shape reference-sample */
export interface NotificationResult {
  sent: boolean;
  channel: string;
  timestamp: Date;
}
