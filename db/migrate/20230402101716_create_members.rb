class CreateMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :members do |t|
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.string :role, default: 'member'

      t.timestamps
    end
    add_index :members, %i[user_id group_id], unique: true
  end
end
