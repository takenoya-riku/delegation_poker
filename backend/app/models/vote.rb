class Vote < ApplicationRecord
  belongs_to :topic
  belongs_to :participant

  validates :level, presence: true, inclusion: { in: 1..7 }
  validates :vote_type, presence: true, inclusion: { in: %w[current_state desired_state] }
  validates :topic_id, uniqueness: { scope: [:participant_id, :vote_type] }

  validate :topic_must_be_in_voting_phase

  private

  def topic_must_be_in_voting_phase
    return unless topic

    case vote_type
    when 'current_state'
      unless topic.status == 'current_voting'
        errors.add(:topic, 'は現状確認投票中でなければなりません')
      end
    when 'desired_state'
      unless topic.status == 'desired_voting'
        errors.add(:topic, 'はありたい姿投票中でなければなりません')
      end
    end
  end
end

