require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module DelegationPoker
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = true

    config.time_zone = "Tokyo"
    config.i18n.default_locale = :ja
  end
end
