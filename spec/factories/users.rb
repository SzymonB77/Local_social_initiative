FactoryBot.define do
  factory :user do
    name { Faker::Name.first_name }
    surname { Faker::Name.last_name }
    nickname { Faker::Internet.username(specifier: name) }
    email { Faker::Internet.email }
    password { Faker::Internet.password(min_length: 8) }
    role { 'user' }
    bio { Faker::Lorem.paragraph }
    avatar { Faker::Avatar.image }

    trait :admin do
      role { 'admin' }
    end
  end
end
