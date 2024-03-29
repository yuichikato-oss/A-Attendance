# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20220803082332) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.time "scheduled_end_time"
    t.string "work_description"
    t.string "next_day"
    t.integer "over_request_superior"
    t.string "over_request_status"
    t.boolean "change", default: false
    t.datetime "edit_day_started_at"
    t.datetime "edit_day_finished_at"
    t.datetime "last_edit_day_started_at"
    t.datetime "last_edit_day_finished_at"
    t.integer "edit_day_request_superior"
    t.string "edit_day_request_status"
    t.boolean "edit_day_check_confirm"
    t.string "edit_one_month_request_status"
    t.integer "edit_one_month_request_superior"
    t.boolean "edit_one_month_check_confirm"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.integer "base_no"
    t.string "base_name"
    t.string "attendance_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "department"
    t.datetime "basic_work_time", default: "2022-08-06 22:30:00"
    t.datetime "designated_work_start_time", default: "2022-08-07 00:00:00"
    t.datetime "designated_work_end_time", default: "2022-08-07 08:30:00"
    t.integer "employee_number"
    t.string "uid"
    t.boolean "superior", default: false
    t.datetime "work_time", default: "2022-08-06 22:30:00"
    t.datetime "basic_time", default: "2022-08-06 23:00:00"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
