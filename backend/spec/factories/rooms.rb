FactoryBot.define do
  factory :room do
    name { "Test Room" }
    code { SecureRandom.alphanumeric(6).upcase }
  end
end
