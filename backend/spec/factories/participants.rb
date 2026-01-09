FactoryBot.define do
  factory :participant do
    association :room
    name { "Test Participant" }
  end
end
