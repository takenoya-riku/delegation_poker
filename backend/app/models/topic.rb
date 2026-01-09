class Topic < ApplicationRecord
  belongs_to :room
  has_many :votes, dependent: :destroy

  validates :title, presence: true
  validates :status, presence: true, inclusion: { in: %w[voting revealed] }

  scope :voting, -> { where(status: 'voting') }
  scope :revealed, -> { where(status: 'revealed') }

  def reveal!
    update!(status: 'revealed')
  end

  def all_participants_voted?
    room.participants.count == votes.count
  end
end
