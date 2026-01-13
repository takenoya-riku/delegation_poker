class Participant < ApplicationRecord
  belongs_to :room
  has_many :votes, dependent: :destroy
  has_many :topics, dependent: :nullify

  validates :name, presence: true
end
