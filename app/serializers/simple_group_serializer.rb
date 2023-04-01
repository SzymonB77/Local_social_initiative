class SimpleGroupSerializer < ActiveModel::Serializer
  attributes :id, :name, :avatar

  # def short_name
  #   object.name.truncate(50)
  # end
end
