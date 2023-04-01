class CreateEvents < ActiveRecord::Migration[6.1]
  def change
    create_table :events do |t|
      t.string :name
      t.datetime :start_date
      t.datetime :end_date
      t.string :status, default: "planned"
      t.string :location
      t.text :description

      t.timestamps
    end
  end
end
