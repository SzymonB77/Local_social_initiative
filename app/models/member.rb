# == Schema Information
#
# Table name: members
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  group_id   :bigint           not null
#  role       :string           default("member")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Member < ApplicationRecord
  MEMBER_ROLES = %w[organizer co-organizer member].freeze
  # Add validations
  validates :role, inclusion: { in: MEMBER_ROLES }
  validates :user, uniqueness: { scope: %i[user_id group_id] }

  # associations
  belongs_to :user
  belongs_to :group, counter_cache: :members_count
end
