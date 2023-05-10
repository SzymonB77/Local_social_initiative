FactoryBot.define do
  factory :event do
    sequence(:name) { |n| "event #{n}" }
    # name { Faker::Lorem.unique.sentence }
    start_date { Faker::Time.between(from: DateTime.now, to: DateTime.now + 30.days) }
    end_date { Faker::Time.between(from: start_date, to: start_date + 30.days) }
    status { Event::VALID_STATUSES.sample }
    location { Faker::Address.full_address }
    description { Faker::Lorem.sentence }
    main_photo { Faker::LoremPixel.image(size: '600x600', is_gray: false) }
    association :group

    # Definiowanie powiązań z Tags
    transient do
      tags_count { 5 }
      photos_count { 5 }
      attendees_count { 3 } # Liczba powiązanych członków do utworzenia
    end

    # after(:build) do |event, evaluator|
    #   event.tags ||= FactoryBot.create(:tag, name: Faker::Lorem.unique.word)
    #   event.photos = build_list(:photo, evaluator.photos_count, event: event)
    #   event.attendees = build_list(:attendee, evaluator.attendees_count, event: event)
    #   event.users = event.attendees.map(&:user)
    # end

    after(:create) do |event, evaluator|
      evaluator.tags_count.times do
        event.tags ||= FactoryBot.create(:tag, name: Faker::Lorem.unique.word)
      end
    end

    after(:create) do |event, evaluator|
      create_list(:photo, evaluator.photos_count, event: event)
    end

    # after(:create) do |event, evaluator|
    #   create_list(:attendee, evaluator.attendees_count, event: event)
    # end

    # Definiowanie powiązań z Users
    after(:create) do |event|
      event.users = event.attendees.map(&:user)
    end
  end
end
