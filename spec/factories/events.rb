FactoryBot.define do
  factory :event do
    sequence(:name) { |n| "event #{n}" }
    start_date { Faker::Time.between(from: DateTime.now, to: DateTime.now + 30.days) }
    end_date { Faker::Time.between(from: start_date, to: start_date + 30.days) }
    location { Faker::Address.full_address }
    description { Faker::Lorem.sentence }
    main_photo { Faker::LoremPixel.image(size: '600x600', is_gray: false) }
    association :group
  end
end
