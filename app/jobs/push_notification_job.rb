# Runs off the request/response cycle (see Message#push_notify_recipient) so that a slow or
# failing push delivery can never delay or break the action that triggered it (e.g. sending
# a message). Uses the :async adapter (config.active_job.queue_adapter) - fine for this app's
# single-process Puma deployment; ActiveJob's own exception handling keeps a failing job from
# affecting anything else.
class PushNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, title:, body:, path:)
    user = User.find_by(id: user_id)
    return unless user

    PushNotifier.notify(user, title: title, body: body, path: path)
  end
end
