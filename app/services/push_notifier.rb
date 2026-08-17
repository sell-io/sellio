# Sends a Web Push notification to every device a user has subscribed on, and prunes
# subscriptions the browser has revoked (404/410 responses from the push service).
class PushNotifier
  def self.notify(user, title:, body:, path: "/")
    new(user).notify(title: title, body: body, path: path)
  end

  def initialize(user)
    @user = user
  end

  def notify(title:, body:, path: "/")
    return if @user.push_subscriptions.none?

    vapid = Rails.application.config.x.vapid
    payload = { title: title, options: { body: body, data: { path: path } } }.to_json

    @user.push_subscriptions.find_each do |subscription|
      WebPush.payload_send(
        message: payload,
        endpoint: subscription.endpoint,
        p256dh: subscription.p256dh,
        auth: subscription.auth,
        vapid: vapid
      )
    rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
      subscription.destroy
    rescue StandardError => e
      # Deliberately broad: a malformed subscription or any other push-delivery failure must
      # never take down the action that triggered the notification (e.g. sending a message).
      Rails.logger.warn "PushNotifier: push failed for subscription #{subscription.id}: #{e.class} #{e.message}"
    end
  end
end
