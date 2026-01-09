class CreateVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :votes, id: :uuid do |t|
      t.references :topic, null: false, foreign_key: true, type: :uuid
      t.references :participant, null: false, foreign_key: true, type: :uuid
      t.integer :level, null: false

      t.timestamps
    end
    add_index :votes, [:topic_id, :participant_id], unique: true
    add_index :votes, :level
  end
end
