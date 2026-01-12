class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :rooms, id: :uuid do |t|
      t.string :name, null: false
      t.string :code, null: false, limit: 6
      t.uuid :room_master_id

      t.timestamps
    end
    add_index :rooms, :code, unique: true
    add_index :rooms, :room_master_id
  end
end
