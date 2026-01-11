require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Eager-load in production for performance.
  config.eager_load = true
end
