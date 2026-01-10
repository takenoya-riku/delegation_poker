require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module DelegationPoker
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = true

    config.time_zone = "Tokyo"
    config.i18n.default_locale = :ja

    # OmniAuth用にセッションミドルウェアを追加
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore, key: '_delegation_poker_session'
  end
end
