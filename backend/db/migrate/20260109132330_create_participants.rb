class CreateParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :participants, id: :uuid do |t|
      t.references :room, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false

      t.timestamps
    end

    add_foreign_key :rooms, :participants, column: :room_master_id
  end
end
