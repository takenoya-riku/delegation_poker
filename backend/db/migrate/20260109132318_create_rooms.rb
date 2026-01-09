class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    create_table :rooms, id: :uuid do |t|
      t.string :name, null: false
      t.string :code, null: false, limit: 6

      t.timestamps
    end
    add_index :rooms, :code, unique: true
  end
end
