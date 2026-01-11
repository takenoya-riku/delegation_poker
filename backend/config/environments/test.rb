require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Keep tests fast by not eager-loading.
  config.eager_load = false
end
