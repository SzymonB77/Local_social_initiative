# == Schema Information
#
# Table name: groups
#
#  id            :bigint           not null, primary key
#  name          :string           not null
#  description   :text
#  avatar        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  members_count :integer          default(0)
#
class Group < ApplicationRecord
  # Add validations
  validates :name, presence: true

  # associations
  has_many :events, dependent: :nullify
  has_many :members, dependent: :destroy, counter_cache: :members_count
  has_many :users, through: :members
end
