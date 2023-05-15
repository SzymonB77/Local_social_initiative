class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.string :name, null: false
      t.datetime :start_date, null: false
      t.datetime :end_date
      t.string :location
      t.text :description

      t.timestamps
    end
  end
end
