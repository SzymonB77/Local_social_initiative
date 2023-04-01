class User < ApplicationRecord

  has_secure_password

  # Add validations
  validates :user_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create
  validates :role, presence: true

  # associations
  has_many :attendees, dependent: :destroy
  has_many :events, through: :attendees
end
