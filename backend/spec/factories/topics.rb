FactoryBot.define do
  factory :topic do
    association :room
    title { "Test Topic" }
    description { "Test Description" }
    status { "voting" }
  end
end
