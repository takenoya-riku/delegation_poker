class Room < ApplicationRecord
  has_many :participants, dependent: :destroy
  has_many :topics, dependent: :destroy
  belongs_to :room_master, class_name: "Participant", optional: true

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true, length: { is: 6 }

  before_validation :generate_code, on: :create

  private

  def generate_code
    return if code.present?

    loop do
      self.code = SecureRandom.alphanumeric(6).upcase
      break unless Room.exists?(code: code)
    end
  end
end
