FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "group #{n}" }
    description { Faker::Lorem.paragraph }
    avatar { Faker::Avatar.image }
  end
end
