FactoryBot.define do
  factory :vote do
    association :topic
    association :participant
    level { rand(1..7) }
    vote_type { "current_state" }
  end
end
