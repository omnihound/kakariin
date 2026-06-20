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

ActiveRecord::Schema[8.1].define(version: 2026_06_20_000005) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bouts", force: :cascade do |t|
    t.bigint "away_competitor_id"
    t.integer "away_score", default: 0, null: false
    t.datetime "created_at", null: false
    t.bigint "home_competitor_id", null: false
    t.integer "home_score", default: 0, null: false
    t.bigint "match_id", null: false
    t.integer "position", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "winner_id"
    t.index ["away_competitor_id"], name: "index_bouts_on_away_competitor_id"
    t.index ["home_competitor_id"], name: "index_bouts_on_home_competitor_id"
    t.index ["match_id", "position"], name: "index_bouts_on_match_id_and_position", unique: true
    t.index ["match_id"], name: "index_bouts_on_match_id"
    t.index ["winner_id"], name: "index_bouts_on_winner_id"
  end

  create_table "competitors", force: :cascade do |t|
    t.string "country", default: "AU", null: false
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "first_name", null: false
    t.string "gender"
    t.integer "grade_rank"
    t.string "grade_type"
    t.string "last_name", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["last_name", "first_name"], name: "index_competitors_on_last_name_and_first_name"
    t.index ["user_id"], name: "index_competitors_on_user_id", unique: true
  end

  create_table "divisions", force: :cascade do |t|
    t.string "competition_type", null: false
    t.datetime "created_at", null: false
    t.string "format", default: "single_elimination", null: false
    t.string "name", null: false
    t.string "status", default: "pending", null: false
    t.bigint "tournament_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tournament_id", "name"], name: "index_divisions_on_tournament_id_and_name", unique: true
    t.index ["tournament_id"], name: "index_divisions_on_tournament_id"
  end

  create_table "ippons", force: :cascade do |t|
    t.bigint "competitor_id", null: false
    t.datetime "created_at", null: false
    t.integer "elapsed_seconds"
    t.bigint "scoreable_id", null: false
    t.string "scoreable_type", null: false
    t.string "technique", null: false
    t.datetime "updated_at", null: false
    t.index ["competitor_id"], name: "index_ippons_on_competitor_id"
    t.index ["scoreable_id", "competitor_id"], name: "index_ippons_on_scoreable_id_and_competitor_id"
    t.index ["scoreable_id"], name: "index_ippons_on_scoreable_id"
    t.index ["scoreable_type", "scoreable_id"], name: "index_ippons_on_scoreable_type_and_scoreable_id"
  end

  create_table "matches", force: :cascade do |t|
    t.bigint "away_id"
    t.integer "away_score", default: 0, null: false
    t.string "away_type"
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.bigint "division_id", null: false
    t.bigint "home_id", null: false
    t.integer "home_score", default: 0, null: false
    t.string "home_type", null: false
    t.integer "mat_number"
    t.bigint "pool_id"
    t.integer "round", null: false
    t.datetime "scheduled_at"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "winner_id"
    t.string "winner_type"
    t.index ["away_type", "away_id"], name: "index_matches_on_away_type_and_away_id"
    t.index ["division_id", "round"], name: "index_matches_on_division_id_and_round"
    t.index ["division_id"], name: "index_matches_on_division_id"
    t.index ["home_type", "home_id"], name: "index_matches_on_home_type_and_home_id"
    t.index ["pool_id"], name: "index_matches_on_pool_id"
    t.index ["winner_type", "winner_id"], name: "index_matches_on_winner_type_and_winner_id"
  end

  create_table "pool_registrations", force: :cascade do |t|
    t.bigint "competitor_id", null: false
    t.datetime "created_at", null: false
    t.bigint "pool_id", null: false
    t.integer "seed"
    t.datetime "updated_at", null: false
    t.index ["competitor_id"], name: "index_pool_registrations_on_competitor_id"
    t.index ["pool_id", "competitor_id"], name: "index_pool_registrations_on_pool_id_and_competitor_id", unique: true
    t.index ["pool_id"], name: "index_pool_registrations_on_pool_id"
  end

  create_table "pools", force: :cascade do |t|
    t.integer "advancing_count", default: 1, null: false
    t.datetime "created_at", null: false
    t.bigint "division_id", null: false
    t.string "name", null: false
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["division_id", "name"], name: "index_pools_on_division_id_and_name", unique: true
    t.index ["division_id"], name: "index_pools_on_division_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "team_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "division_id", null: false
    t.string "name", null: false
    t.integer "seed"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["division_id", "name"], name: "index_team_entries_on_division_id_and_name", unique: true
    t.index ["division_id"], name: "index_team_entries_on_division_id"
  end

  create_table "team_memberships", force: :cascade do |t|
    t.bigint "competitor_id", null: false
    t.datetime "created_at", null: false
    t.bigint "team_entry_id", null: false
    t.datetime "updated_at", null: false
    t.index ["competitor_id"], name: "index_team_memberships_on_competitor_id"
    t.index ["team_entry_id", "competitor_id"], name: "index_team_memberships_on_entry_and_competitor", unique: true
    t.index ["team_entry_id"], name: "index_team_memberships_on_team_entry_id"
  end

  create_table "tournament_registrations", force: :cascade do |t|
    t.bigint "competitor_id", null: false
    t.datetime "created_at", null: false
    t.bigint "division_id", null: false
    t.integer "seed"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["competitor_id", "division_id"], name: "index_registrations_on_competitor_and_division", unique: true
    t.index ["competitor_id"], name: "index_tournament_registrations_on_competitor_id"
    t.index ["division_id"], name: "index_tournament_registrations_on_division_id"
  end

  create_table "tournaments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.date "end_date"
    t.string "location"
    t.string "name", null: false
    t.date "start_date", null: false
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.index ["start_date"], name: "index_tournaments_on_start_date"
    t.index ["status"], name: "index_tournaments_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "bouts", "competitors", column: "away_competitor_id"
  add_foreign_key "bouts", "competitors", column: "home_competitor_id"
  add_foreign_key "bouts", "competitors", column: "winner_id"
  add_foreign_key "bouts", "matches"
  add_foreign_key "competitors", "users"
  add_foreign_key "divisions", "tournaments"
  add_foreign_key "ippons", "competitors"
  add_foreign_key "matches", "divisions"
  add_foreign_key "matches", "pools"
  add_foreign_key "pool_registrations", "competitors"
  add_foreign_key "pool_registrations", "pools"
  add_foreign_key "pools", "divisions"
  add_foreign_key "sessions", "users"
  add_foreign_key "team_entries", "divisions"
  add_foreign_key "team_memberships", "competitors"
  add_foreign_key "team_memberships", "team_entries"
  add_foreign_key "tournament_registrations", "competitors"
  add_foreign_key "tournament_registrations", "divisions"
end
