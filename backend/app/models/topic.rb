class Topic < ApplicationRecord
  belongs_to :room
  has_many :votes, dependent: :destroy

  validates :title, presence: true
  validates :status, presence: true, inclusion: {
    in: %w[draft organizing current_voting current_revealed desired_voting desired_revealed completed],
  }

  scope :draft, -> { where(status: "draft") }
  scope :organizing, -> { where(status: "organizing") }
  scope :current_voting, -> { where(status: "current_voting") }
  scope :current_revealed, -> { where(status: "current_revealed") }
  scope :desired_voting, -> { where(status: "desired_voting") }
  scope :desired_revealed, -> { where(status: "desired_revealed") }
  scope :completed, -> { where(status: "completed") }

  # 後方互換性のためのスコープ
  scope :voting, -> { where(status: %w[current_voting desired_voting]) }
  scope :revealed, -> { where(status: %w[current_revealed desired_revealed completed]) }

  def start_organizing!
    update!(status: "organizing")
  end

  def start_current_voting!
    update!(status: "current_voting")
  end

  def reveal_current_state!
    update!(status: "current_revealed")
  end

  def start_desired_voting!
    update!(status: "desired_voting")
  end

  def reveal_desired_state!
    update!(status: "desired_revealed")
  end

  def complete!
    update!(status: "completed")
  end

  def all_participants_voted_current_state?
    room.participants.count == votes.where(vote_type: "current_state").count
  end

  def all_participants_voted_desired_state?
    room.participants.count == votes.where(vote_type: "desired_state").count
  end

  # 後方互換性のためのメソッド
  def reveal!
    if status == "current_voting"
      reveal_current_state!
    elsif status == "desired_voting"
      reveal_desired_state!
    else
      raise "Cannot reveal topic with status: #{status}"
    end
  end

  def all_participants_voted?
    case status
    when "current_voting"
      all_participants_voted_current_state?
    when "desired_voting"
      all_participants_voted_desired_state?
    else
      false
    end
  end
end
