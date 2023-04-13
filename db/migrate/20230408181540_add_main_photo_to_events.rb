class AddMainPhotoToEvents < ActiveRecord::Migration[6.1]
  def change
    add_column :events, :main_photo, :string
  end

  def down
    remove_column :events, :main_photo
  end
end
