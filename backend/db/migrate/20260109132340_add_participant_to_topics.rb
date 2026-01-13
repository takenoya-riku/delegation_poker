class AddParticipantToTopics < ActiveRecord::Migration[8.0]
  def change
    add_reference :topics, :participant, null: true, foreign_key: true, type: :uuid
  end
end
