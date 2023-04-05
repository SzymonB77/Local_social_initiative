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

ActiveRecord::Schema.define(version: 20_230_405_115_546) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'attendees', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.bigint 'event_id', null: false
    t.string 'role', default: 'attendee'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['event_id'], name: 'index_attendees_on_event_id'
    t.index %w[user_id event_id], name: 'index_attendees_on_user_id_and_event_id', unique: true
    t.index ['user_id'], name: 'index_attendees_on_user_id'
  end

  create_table 'events', force: :cascade do |t|
    t.string 'name'
    t.datetime 'start_date'
    t.datetime 'end_date'
    t.string 'status', default: 'planned'
    t.string 'location'
    t.text 'description'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.bigint 'group_id'
    t.index ['group_id'], name: 'index_events_on_group_id'
  end

  create_table 'groups', force: :cascade do |t|
    t.string 'name', null: false
    t.text 'description'
    t.string 'avatar'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'members', force: :cascade do |t|
    t.bigint 'user_id', null: false
    t.bigint 'group_id', null: false
    t.string 'role', default: 'member'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['group_id'], name: 'index_members_on_group_id'
    t.index %w[user_id group_id], name: 'index_members_on_user_id_and_group_id', unique: true
    t.index ['user_id'], name: 'index_members_on_user_id'
  end

  create_table 'tags', force: :cascade do |t|
    t.string 'name', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  create_table 'users', force: :cascade do |t|
    t.string 'email'
    t.string 'password_digest'
    t.string 'name'
    t.string 'surname'
    t.string 'user_name'
    t.string 'role'
    t.text 'bio'
    t.string 'avatar'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
  end

  add_foreign_key 'attendees', 'events'
  add_foreign_key 'attendees', 'users'
  add_foreign_key 'events', 'groups'
  add_foreign_key 'members', 'groups'
  add_foreign_key 'members', 'users'
end
