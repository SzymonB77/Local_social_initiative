class CreatePhotos < ActiveRecord::Migration[6.1]
  def change
    create_table :photos do |t|
      t.references :event, foreign_key: true
      t.references :user, foreign_key: true
      t.string :url, null: false

      t.timestamps
    end
  end
end
