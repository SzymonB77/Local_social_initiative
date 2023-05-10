FactoryBot.define do
  factory :photo do
    event
    user
    url { Faker::Internet.url }
  end
end
