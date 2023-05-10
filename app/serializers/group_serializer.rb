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
class GroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :avatar, :organized_by, :members_count

  has_many :members, serializer: SimpleMemberSerializer, limit: 4
  has_many :events, key: :events_planned, scope: lambda {
                                                   where(status: 'planned')
                                                 }, serializer: SimpleEventSerializer, limit: 2
  has_many :events, key: :events_in_progress, scope: lambda {
                                                       where(status: 'in progress')
                                                     }, serializer: SimpleEventSerializer
  has_many :events, key: :events_finished, scope: lambda {
                                                    where(status: 'finished')
                                                  }, serializer: SimpleEventSerializer, limit: 2

  def organized_by
    organizer = object.members.find_by(role: 'organizer')
    SimpleMemberSerializer.new(organizer).attributes if organizer
  end
end
