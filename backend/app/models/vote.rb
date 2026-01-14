class Vote < ApplicationRecord
  belongs_to :topic
  belongs_to :participant

  validates :level, presence: true, inclusion: { in: 1..7 }
  validates :vote_type, presence: true, inclusion: { in: %w[current_state desired_state] }
  validates :topic_id, uniqueness: { scope: %i[participant_id vote_type] }

  validate :topic_must_be_in_voting_phase

  private

  def topic_must_be_in_voting_phase
    return unless topic

    case vote_type
    when "current_state"
      errors.add(:topic, "は現状確認投票中でなければなりません") unless topic.status == "current_voting"
    when "desired_state"
      errors.add(:topic, "は理想投票中でなければなりません") unless topic.status == "desired_voting"
    end
  end
end
