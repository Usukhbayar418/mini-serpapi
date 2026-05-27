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

ActiveRecord::Schema[8.1].define(version: 2026_05_27_050032) do
  create_table "search_histories", force: :cascade do |t|
    t.string "api_key"
    t.datetime "created_at", null: false
    t.integer "duration_ms"
    t.string "engine"
    t.string "ip"
    t.string "query"
    t.integer "results_count"
    t.datetime "updated_at", null: false
    t.string "user_agent"
  end
end
