class User < ApplicationRecord

  has_secure_password

  # Add validations
  validates :user_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create
  validates :role, presence: true

end
