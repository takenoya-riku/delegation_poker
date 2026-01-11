class CreateVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :votes, id: :uuid do |t|
      t.references :topic, null: false, foreign_key: true, type: :uuid
      t.references :participant, null: false, foreign_key: true, type: :uuid
      t.integer :level, null: false
      t.string :vote_type, null: false, default: 'current_state'

      t.timestamps
    end
    add_index :votes, [:topic_id, :participant_id, :vote_type], unique: true, name: 'index_votes_on_topic_participant_vote_type'
    add_index :votes, :level
  end
end
