require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module MyWebsite
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    
    # Increase max file upload size to handle multiple images (50MB total)
    config.action_dispatch.parameter_size_limit = 50.megabytes

    # Route 404/422/500 through our own branded error pages (ErrorsController) instead of
    # the static public/*.html files, so nav/footer/search stay visible when something goes wrong.
    # The public/*.html files remain as the final fallback for when the app can't boot at all.
    config.exceptions_app = routes
  end
end
