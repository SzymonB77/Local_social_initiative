class SimpleGroupSerializer < ActiveModel::Serializer
  attributes :id, :short_name, :avatar

  def short_name
    object.name.truncate(50)
  end
end
