# == Schema Information
#
# Table name: photos
#
#  id         :bigint           not null, primary key
#  event_id   :bigint
#  user_id    :bigint
#  url        :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PhotoSerializer < ActiveModel::Serializer
  attributes :id, :url, :author

  def author
    object.user.user_name
  end
end
