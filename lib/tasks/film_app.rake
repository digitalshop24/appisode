namespace :film_app do
  desc "Rake task to get events data"
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

          show_params = {:season_date => full_season_release, :episode_date => three_series[0], :three_episode => three_episode, :russian_name => russian_name, :additional_field => show['original_name'], :poster => show['poster_path'], :in_production => on_air?(show["last_air_date"]), :episode_count => show['number_of_seasons']}
        else
          full_season_release = Tmdb::TV.detail(i)["last_air_date"]
          show_params = {:season_date => full_season_release, :additional_field => show['original_name'], :poster => show['poster_path'], :russian_name => russian_name, :in_production => on_air?(show["last_air_date"]), :episode_count => show['number_of_seasons']}
        end
        c = Show.find_by_additional_field(show['original_name'])
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

  desc "for updates for subscriptions"
  task :update => :environment do
    current_date = Date.parse(Time.now.to_s.slice(0..9))
    User.all.each do |i|
      if i.updated.nil? || i.updated != current_date
        puts "a"
        puts i.email
        i.subscriptions.each do |j|
          puts "b"
          puts j.serial_id
          puts "b"
        season_release_date = Date.parse(Show.find(j.serial_id).season_date)
        if season_release_date >= current_date
          if j.options['season']
            if Show.find(j.serial_id).season_date
              if season_release_date == current_date
                #TODO send email with serial name and season released text
                u = URI.encode("https://userarea.sms-assistent.by/api/v1/send_sms/plain?user=Iksboks&password=cS6888b5&recipient=#{i.number}&message=новый сезон сериала #{Show.find(j.serial_id).russian_name} вышел&sender=APPISODE")
                uri = URI(u)
                a = Net::HTTP.get(uri)
                puts "#{i.email}"
              end
            end
          end
          if j.options['episode']
            if Show.find(j.serial_id).episode_date
              episode_release_date = Date.parse(Show.find(j.serial_id).episode_date)
              if episode_release_date == current_date
                #TODO send email with serial name and episode released text
                u = URI.encode("https://userarea.sms-assistent.by/api/v1/send_sms/plain?user=Iksboks&password=cS6888b5&recipient=#{i.number}&message=новая серия сериала #{Show.find(j.serial_id).russian_name} вышла&sender=APPISODE")
                uri = URI(u)
                a = Net::HTTP.get(uri)
                puts "#{i.email} recieved episode announce about #{Show.find(j.serial_id).additional_field} #{a}"
              end
            end
          end
          if j.options['three_episode']
            if Show.find(j.serial_id).three_episode
              three_episode_release_date = Date.parse(Show.find(j.serial_id).three_episode)
              if three_episode_release_date == current_date
                #TODO send email with serial name and three_episodes released text
                u = URI.encode("https://userarea.sms-assistent.by/api/v1/send_sms/plain?user=Iksboks&password=cS6888b5&recipient=#{i.number}&message=три серии сериала #{Show.find(j.serial_id).russian_name} вышли&sender=APPISODE")
                uri = URI(u)
                a = Net::HTTP.get(uri)
                puts "#{i.email} recieved three_episodes announce about #{Show.find(j.serial_id).additional_field} #{a}"
              end
            end
          end
        end
        end
        i.updated = current_date
        i.save
      end
    end
  end

  desc "TODO"
  task :test => :environment do
    puts "sadsd"
  end
end