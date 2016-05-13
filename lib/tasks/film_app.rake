require 'open-uri'
namespace :film_app do
  desc "Rake task to get events data"

  task :load, [:pages] => :environment do |t, args|
    pages = args[:pages] ? args[:pages].to_i : 1000
    (1..pages).each do |i|
      shows = Show.get_json('popular', { page: i })
      if shows
        shows = shows['results']
        shows.each do |show|
          Show.load show['id']
        end
      end
      puts "#{Time.now} - page #{i} done"
    end
  end

  task load_all: :environment do
    (1..64598).each do |i|
      begin
        Show.load i
      rescue => error
        puts "ERROR #{error}"
      end
    end
  end

  task update: :environment do
    in_prod_shows = Show.where(in_production: true)
    in_prod_shows.each_with_index do |show, i|
      puts "#{i}/#{in_prod_shows.count}"
      json = Show.get_json(show.tmdb_id, { language: 'ru' })
      if json
        new_seasons = json['seasons'].count - show.seasons.count
        if new_seasons > 0
          (json['seasons'].map{|s| s['season_number']} - show.seasons.pluck(:number)).each do |season_number|
            season = Show.get_json("#{show.tmdb_id}/season/#{season_number}", { language: 'ru' })
            if season
              new_season = show.create_or_update_season(season)
              season['episodes'].each do |episode|
                new_episode = new_season.create_or_update_episode(episode)
              end
              puts "------ #{Time.now} - season #{new_season.number} for \"#{show.name}\" loaded with #{season['episodes'].count} episodes !!!!"
            end
          end
        else
          season = Show.get_json("#{show.tmdb_id}/season/#{json['seasons'].last['season_number']}", { language: 'ru' })
          if season
            new_season = show.create_or_update_season(season)
            new_episodes = season['episodes'].count - new_season.episodes.count
            if new_episodes > 0
              old_episodes = new_season.episodes.where('air_date < ?', Date.today).pluck(:number)
              season['episodes'].each do |episode|
                unless episode['episode_number'].in? old_episodes
                  new_episode = new_season.create_or_update_episode(episode)
                end
              end
            end
            puts "------ #{Time.now} - season #{new_season.number} for \"#{show.name}\" updated. #{new_episodes} episodes added"
          end
        end
        puts "--- #{Time.now} - show \"#{show.name}\" updated. #{new_seasons} seasons added"
      end
    end
  end

  task :update_popularity, [:pages] => :environment do |t, args|
    pages = args[:pages] ? args[:pages].to_i : 100
    pages = 100
    per_page = 20
    arr = []
    (1..pages).each do |i|
      Show.get_json('popular', { page: i })['results'].each_with_index do |s, j|
        # popularity = (per_page * pages - (per_page * (i - 1) + j)) * 20
        popularity = per_page * (i - 1) + (j + 1)
        show = Show.find_by(tmdb_id: s['id']) || Show.create_or_update(s)
        show.update(popularity: popularity )
      end
      puts "#{i} pages done"
    end
  end

  task inform_old: :environment do
    begin
      Notification.where(date: Date.today).each do |n|
        n.perform
      end
      puts "#{Time.now} === notifications sended"
    rescue => error
      puts("ERROR ===>> #{error.class} and #{error.message}")
    end
  end

  task inform: :enviroment do
    # current episode subscriptions
    Subscription.episode.select('*, episodes.number AS episode_number, shows.name AS show_name, shows.russian_name AS show_ru_name').joins(:episode).where('episodes.air_date' => Date.today) do |sub|
      nt = Notification.create(
        subscription: sub,
        message: I18n.t('notifications.episode.today', number: sub.episode_number, show: sub.show_ru_name)
      )
      nt.update(performed: true) if nt.perform
    end
    # all new episodes subscriptions
    Subscription.new_episodes.select('*, shows.name AS show_name, shows.russian_name AS show_ru_name').joins(show: [seasons: [:episodes]]).where('episodes.air_date' => Date.today) do |sub|
      nt = Notification.create(
        subscription: sub,
        message: I18n.t('notifications.new_episodes.today', show: sub.show_ru_name)
      )
      nt.update(performed: true) if nt.perform
    end
    # season subscriptions
    # Subscription.season.joins(show: [seasons: [:episodes]]).where('episodes.air_date' => Date.today) do |sub|
    #   nt = Notification.create(
    #     subscription: sub,
    #     message: I18n.t('notifications.new_episodes.today')
    #   )
    #   nt.update(performed: true) if nt.perform
    # end
  end

  task :test => :environment do
    Show.create(name: 'test-test')
    puts 'blalba'
  end

  task :download => :environment do
    Tmdb::Api.key('15e545fda3d4598527fac7245a459571')
    def on_air?(date)
      if date
        if date >= Time.zone.now.to_s.slice(0..9)
          true
        else
          false
        end
      else
        false
      end
    end
    (1..64598).each do |i|
      begin
        Tmdb::Api.language("ru")
        russian_name = Tmdb::TV.detail(i)["name"]
        show = Tmdb::TV.detail(i)
        number_of_seasons = show["number_of_seasons"]
        if on_air?(show["last_air_date"])
          last_season = Tmdb::Season.detail(i, number_of_seasons)
          number_of_episodes = last_season["episodes"].count - 1
          if number_of_episodes <= 0
            last_season = Tmdb::Season.detail(i, number_of_seasons-1)
            number_of_episodes = last_season["episodes"].count - 1
          end
          three_series = []
          i = 0
          while three_series.count < 3 && i <= number_of_episodes
            if last_season["episodes"][i]["air_date"] >= Time.zone.now.to_s.slice(0..9)
              three_series << last_season["episodes"][i]["air_date"]
            end

            i+=1
          end

          full_season_release = last_season["episodes"][number_of_episodes]["air_date"]
          if three_series.count == 3
            three_episode = three_series[2]
          else
            three_episode = nil
          end

          show_params = {:season_date => full_season_release, :episode_date => three_series[0], :three_episode => three_episode, :russian_name => russian_name, :name => show['original_name'], :poster => show['poster_path'], :in_production => on_air?(show["last_air_date"]), :episode_count => show['number_of_seasons']}
        else
          full_season_release = Tmdb::TV.detail(i)["last_air_date"]
          show_params = {:season_date => full_season_release, :name => show['original_name'], :poster => show['poster_path'], :russian_name => russian_name, :in_production => on_air?(show["last_air_date"]), :episode_count => show['number_of_seasons']}
        end
        c = Show.find_by_name(show['original_name'])
        if c.nil?
          a = Show.new(show_params)
          a.save
        else
          c.update(show_params)
        end
        puts "#{Time.now} - #{i}Success!"
      rescue
        puts "bad"
        next
      end
    end
    puts "#{Time.now} - FINISH!!!"
  end

  # desc "for updates for subscriptions"
  # task :update => :environment do
  #   current_date = Date.parse(Time.now.to_s.slice(0..9))
  #   User.all.each do |i|
  #     if i.updated.nil? || i.updated != current_date
  #       i.subscriptions.each do |j|
  #         if Show.find(j.serial_id).season_date
  #           season_release_date = Date.parse(Show.find(j.serial_id).season_date)
  #           if season_release_date >= current_date
  #             if j.options['season']
  #               if Show.find(j.serial_id).season_date
  #                 if season_release_date == current_date
  #                   #TODO send email with serial name and season released text
  #                   u = URI.encode("https://userarea.sms-assistent.by/api/v1/send_sms/plain?user=Iksboks&password=cS6888b5&recipient=#{i.number}&message=новый сезон сериала #{Show.find(j.serial_id).russian_name} вышел&sender=APPISODE")
  #                   uri = URI(u)
  #                   a = Net::HTTP.get(uri)
  #                   puts "#{i.email}"
  #                 end
  #               end
  #             end
  #             if j.options['episode']
  #               if Show.find(j.serial_id).episode_date
  #                 episode_release_date = Date.parse(Show.find(j.serial_id).episode_date)
  #                 if episode_release_date == current_date
  #                   #TODO send email with serial name and episode released text
  #                   u = URI.encode("https://userarea.sms-assistent.by/api/v1/send_sms/plain?user=Iksboks&password=cS6888b5&recipient=#{i.number}&message=новая серия сериала #{Show.find(j.serial_id).russian_name} вышла&sender=APPISODE")
  #                   uri = URI(u)
  #                   a = Net::HTTP.get(uri)
  #                   puts "#{i.email} recieved episode announce about #{Show.find(j.serial_id).additional_field} #{a}"
  #                 end
  #               end
  #             end
  #             if j.options['three_episode']
  #               if Show.find(j.serial_id).three_episode
  #                 three_episode_release_date = Date.parse(Show.find(j.serial_id).three_episode)
  #                 if three_episode_release_date == current_date
  #                   #TODO send email with serial name and three_episodes released text
  #                   u = URI.encode("https://userarea.sms-assistent.by/api/v1/send_sms/plain?user=Iksboks&password=cS6888b5&recipient=#{i.number}&message=три серии сериала #{Show.find(j.serial_id).russian_name} вышли&sender=APPISODE")
  #                   uri = URI(u)
  #                   a = Net::HTTP.get(uri)
  #                   puts "#{i.email} recieved three_episodes announce about #{Show.find(j.serial_id).additional_field} #{a}"
  #                 end
  #               end
  #             end
  #           end
  #         end
  #       end
  #       i.updated = current_date
  #       i.save
  #     end
  #   end
  # end
end
