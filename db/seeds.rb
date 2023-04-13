# Users
admin = User.create!(nickname: 'admin',
                     email: 'admin@example.com',
                     password: 'password',
                     role: 'admin',
                     name: 'Admin',
                     surname: 'User',
                     bio: Faker::Lorem.paragraph(sentence_count: 5),
                     avatar: Faker::Avatar.image)
users = []
10.times do
  user = User.create!(nickname: Faker::Internet.username,
                      email: Faker::Internet.email,
                      password: 'password',
                      role: 'user',
                      name: Faker::Name.first_name,
                      surname: Faker::Name.last_name,
                      bio: Faker::Lorem.paragraph(sentence_count: 5),
                      avatar: Faker::Avatar.image)
  users << user
end

# Groups
groups = []
5.times do
  group = Group.create!(
    name: Faker::Team.name,
    description: Faker::Lorem.paragraph,
    avatar: Faker::Avatar.image
  )
  groups << group
end

# Members
groups.each do |group|
  organizer_user = users.sample
  regular_users = users.reject { |user| user == organizer_user }

  organizer_user = Member.find_or_create_by!(
    user_id: organizer_user.id,
    group_id: group.id,
    role: 'organizer'
  )
  5.times do
    user = regular_users.sample
    member = Member.find_or_create_by!(
      user_id: user.id,
      group_id: group.id,
      role: 'member'
    )
  end
end

# Tags
tags = []
10.times do
  tag = Tag.create!(name: Faker::Lorem.word)
  tags << tag
end

# Events
events = []
groups = Group.all

5.times do
  event = Event.find_or_create_by!(
    name: Faker::Lorem.sentence,
    start_date: Faker::Time.between(from: DateTime.now + 1, to: DateTime.now + 30),
    end_date: Faker::Time.between(from: DateTime.now + 31, to: DateTime.now + 60),
    location: Faker::Address.full_address,
    description: Faker::Lorem.paragraph(sentence_count: 5),
    main_photo: 'https://picsum.photos/800/600',
    group_id: groups.sample.id
  )
  events << event
end

5.times do
  event = Event.find_or_create_by!(
    name: Faker::Lorem.sentence,
    start_date: Faker::Time.between(from: DateTime.now + 1, to: DateTime.now + 30),
    end_date: Faker::Time.between(from: DateTime.now + 31, to: DateTime.now + 60),
    location: Faker::Address.full_address,
    description: Faker::Lorem.paragraph(sentence_count: 5),
    main_photo: 'https://picsum.photos/800/600'
  )

  events << event
end

# Attendees
events.each do |event|
  host_user = users.sample
  regular_users = users.reject { |user| user == host_user }

  host_user = Attendee.find_or_create_by!(
    user_id: host_user.id,
    event_id: event.id,
    role: 'host'
  )

  5.times do
    user = regular_users.sample
    member = Attendee.find_or_create_by!(
      user_id: user.id,
      event_id: event.id,
      role: 'attendee'
    )
  end
end

# Event tags
events.each do |event|
  7.times do
    event_tag = EventTag.find_or_create_by!(
      event_id: event.id,
      tag_id: tags.sample.id
    )
  end
end

# Photos
photos = []

20.times do
  photo = Photo.create!(
    event_id: events.sample.id,
    user_id: users.sample.id,
    url: Faker::LoremPixel.image(size: '800x600', is_gray: false, category: 'nature')
  )
  photos << photo
end
