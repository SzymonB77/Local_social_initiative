class AddGroupToEvents < ActiveRecord::Migration[6.1]
  def up
    add_reference :events, :group, foreign_key: true
  end

  def down
    remove_reference :events, :group, foreign_key: true
  end
end
