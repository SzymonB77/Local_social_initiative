class CreateGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.text :description
      t.string :avatar

      t.timestamps
    end
  end
end
