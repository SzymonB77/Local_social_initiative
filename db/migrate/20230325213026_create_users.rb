class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :name
      t.string :surname
      t.string :user_name
      t.string :role
      t.text :bio
      t.string :avatar

      t.timestamps
    end
  end
end
