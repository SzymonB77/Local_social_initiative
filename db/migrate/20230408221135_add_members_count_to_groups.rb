class AddMembersCountToGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :groups, :members_count, :integer, default: 0
  end

  def down
    remove_column :groups, :members_count
  end
end
