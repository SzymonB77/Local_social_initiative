class CreateAttendees < ActiveRecord::Migration[6.1]
  def change
    create_table :attendees do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.boolean :admin, default: false

      t.timestamps
    end
    add_index :attendees, [:user_id, :event_id], unique: true
  end
end
