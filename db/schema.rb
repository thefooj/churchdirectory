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

ActiveRecord::Schema.define(:version => 20121103032537) do

  create_table "churches", :force => true do |t|
    t.string "name"
    t.string "urn"
  end

  add_index "churches", ["urn"], :name => "index_churches_on_urn", :unique => true

  create_table "people", :force => true do |t|
    t.integer "church_id"
    t.string  "member_id"
    t.string  "first_name"
    t.string  "last_name"
    t.string  "household_id"
    t.string  "email_address"
    t.string  "street_address"
    t.string  "city"
    t.string  "zip_code"
    t.string  "phone"
    t.string  "mobile"
    t.string  "member_type"
    t.string  "member_age_category_name"
    t.date    "membership_date"
    t.date    "date_of_birth"
    t.date    "anniversary_date"
    t.string  "gender_name"
    t.string  "marital_status_name"
    t.string  "state"
    t.string  "country_name"
    t.string  "notes"
  end

  add_index "people", ["household_id"], :name => "index_people_on_household_id"
  add_index "people", ["member_id"], :name => "index_people_on_member_id", :unique => true

end
