FactoryBot.define do
  factory :user do
    email { "user#{SecureRandom.hex(4)}@example.com" }
    name { "Test User" }
    google_uid { SecureRandom.hex(16) }
    avatar_url { "https://example.com/avatar.jpg" }
  end
end
