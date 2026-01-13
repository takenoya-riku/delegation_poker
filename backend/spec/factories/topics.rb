FactoryBot.define do
  factory :topic do
    association :room
    participant { association :participant, room: room }
    title { "Test Topic" }
    description { "Test Description" }
    status { "current_voting" }
  end
end
