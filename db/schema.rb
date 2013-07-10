# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130710131926) do

  create_table "church_users", :force => true do |t|
    t.integer "church_id"
    t.integer "user_id"
    t.boolean "admin"
  end

  add_index "church_users", ["church_id", "user_id"], :name => "index_church_users_on_church_id_and_user_id", :unique => true
  add_index "church_users", ["user_id"], :name => "index_church_users_on_user_id"

  create_table "churches", :force => true do |t|
    t.string "name"
    t.string "urn"
  end

  add_index "churches", ["urn"], :name => "index_churches_on_urn", :unique => true

  create_table "csv_upload_rows", :force => true do |t|
    t.integer "csv_upload_id"
    t.text    "rowtext"
    t.string  "status"
  end

  add_index "csv_upload_rows", ["csv_upload_id"], :name => "index_csv_upload_rows_on_csv_upload_id"

  create_table "csv_uploads", :force => true do |t|
    t.integer  "church_id"
    t.text     "header"
    t.integer  "num_rows"
    t.string   "status"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "csv_uploads", ["church_id"], :name => "index_csv_uploads_on_church_id"
  add_index "csv_uploads", ["status"], :name => "index_csv_uploads_on_status"

  create_table "geocode_caches", :force => true do |t|
    t.string "key"
    t.text   "value"
  end

  add_index "geocode_caches", ["key"], :name => "index_geocode_caches_on_key"

  create_table "people", :force => true do |t|
    t.integer  "church_id"
    t.string   "member_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "household_id"
    t.string   "email_address"
    t.string   "street_address"
    t.string   "city"
    t.string   "zip_code"
    t.string   "phone"
    t.string   "mobile"
    t.string   "member_type"
    t.string   "member_age_category_name"
    t.date     "membership_date"
    t.date     "date_of_birth"
    t.date     "anniversary_date"
    t.string   "gender_name"
    t.string   "marital_status_name"
    t.string   "state"
    t.string   "country_name"
    t.string   "notes"
    t.string   "sort_name"
    t.boolean  "is_head_of_household",           :default => false
    t.boolean  "is_spouse_of_head_of_household", :default => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.float    "longitude"
    t.float    "latitude"
  end

  add_index "people", ["household_id"], :name => "index_people_on_household_id"
  add_index "people", ["member_id"], :name => "index_people_on_member_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
