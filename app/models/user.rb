# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string
#  password_digest :string
#  name            :string
#  surname         :string
#  nickname        :string
#  role            :string
#  bio             :text
#  avatar          :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class User < ApplicationRecord
  has_secure_password

  # Add validations
  validates :nickname, presence: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create
  validates :role, presence: true

  # associations
  has_many :attendees, dependent: :destroy
  has_many :events, through: :attendees
  has_many :members, dependent: :destroy
  has_many :gropus, through: :members
  has_many :photos
end
