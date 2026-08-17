# Web Push (VAPID) keys, used to send browser push notifications (see PushSubscription,
# app/services/push_notifier.rb). Generate a production key pair once with:
#   bundle exec ruby -e 'require "web-push"; k = WebPush.generate_key; puts k.public_key; puts k.private_key'
# then set VAPID_PUBLIC_KEY / VAPID_PRIVATE_KEY in the production environment (Kamal secrets).
# The fallback pair below is for local development only - do not rely on it in production.
Rails.application.config.x.vapid = {
  subject: ENV.fetch("VAPID_SUBJECT", "mailto:support@dealo.ie"),
  public_key: ENV.fetch("VAPID_PUBLIC_KEY", "BIkhBsv_7bT2y80ySipVsYMhFvfTf5rfc6B7OPFWl8zEoWqoBplDUbvhFNIIRdc48IBlABXQvhHSuufGGlzOIaw="),
  private_key: ENV.fetch("VAPID_PRIVATE_KEY", "6s92J-U9Hd-uRrTDlpwfQ6NCKz0y9uyxSU3CkzP2ZYA=")
}
