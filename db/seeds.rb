# puts 'loading shows...'
# Rake::Task['film_app:load'].invoke('1')

# puts 'updating popularity...'
# Rake::Task['film_app:update_popularity'].invoke('1')

puts 'destroying users...'
User.destroy_all

puts 'creating users with devices & subscriptions...'
40.times do |i|
  u = User.create(
    name: Faker::Name.name,
    confirmation: rand(1000..9999),
    phone: Faker::PhoneNumber.cell_phone,
  )
  rand(1..2).times do
    u.devices.create(token: Faker::Lorem.characters(10))
  end
  rand(0..20).times do
    subtype = Subscription.subtypes.keys.sample
    if subtype == 'episode'
      episode = Episode.where('air_date > ?', Time.now).order('RANDOM()').limit(1).first
      u.subscriptions.create(
        show: episode.show,
        episode: episode,
        subtype: subtype,
        active: true
      )
    else
      show = Show.where(status: 'airing').order('RANDOM()').limit(1).first
      u.subscriptions.create(
        show: show,
        subtype: subtype,
        active: true
      )
    end
  end
end
