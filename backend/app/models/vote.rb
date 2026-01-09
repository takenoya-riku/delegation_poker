class Vote < ApplicationRecord
  belongs_to :topic
  belongs_to :participant

  validates :level, presence: true, inclusion: { in: 1..7 }
  validates :topic_id, uniqueness: { scope: :participant_id }

  validate :topic_must_be_voting

  private

  def topic_must_be_voting
    return unless topic

    errors.add(:topic, 'は投票中でなければなりません') unless topic.status == 'voting'
  end
end
