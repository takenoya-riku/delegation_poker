class CreateTopics < ActiveRecord::Migration[8.0]
  def change
    create_table :topics, id: :uuid do |t|
      t.references :room, null: false, foreign_key: true, type: :uuid
      t.string :title, null: false
      t.text :description
      t.string :status, null: false, default: 'draft'

      t.timestamps
    end
    add_index :topics, :status
  end
end
