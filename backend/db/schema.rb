# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2026_01_11_120000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "participants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "room_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_participants_on_room_id"
  end

  create_table "rooms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "code", limit: 6, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "room_master_id"
    t.index ["code"], name: "index_rooms_on_code", unique: true
    t.index ["room_master_id"], name: "index_rooms_on_room_master_id"
  end

  create_table "topics", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "room_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "status", default: "draft", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "participant_id"
    t.index ["participant_id"], name: "index_topics_on_participant_id"
    t.index ["room_id"], name: "index_topics_on_room_id"
    t.index ["status"], name: "index_topics_on_status"
  end

  create_table "votes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "topic_id", null: false
    t.uuid "participant_id", null: false
    t.integer "level", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "vote_type", default: "current_state", null: false
    t.index ["level"], name: "index_votes_on_level"
    t.index ["participant_id"], name: "index_votes_on_participant_id"
    t.index ["topic_id", "participant_id", "vote_type"], name: "index_votes_on_topic_participant_vote_type", unique: true
    t.index ["topic_id"], name: "index_votes_on_topic_id"
  end

  add_foreign_key "participants", "rooms"
  add_foreign_key "rooms", "participants", column: "room_master_id"
  add_foreign_key "topics", "participants"
  add_foreign_key "topics", "rooms"
  add_foreign_key "votes", "participants"
  add_foreign_key "votes", "topics"
end
