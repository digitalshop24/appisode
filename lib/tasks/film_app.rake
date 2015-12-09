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
    (1399..64598).each do |i|
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
          if last_season["episodes"][i]["air_date"] > Time.zone.now.to_s.slice(0..9)
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

        show_params = {:season_date => full_season_release, :episode_date => three_series[0], :three_episode => three_episode, :additional_field => show['original_name'], :poster => show['poster_path'], :in_production => on_air?(show["last_air_date"]), :episode_count => show['number_of_seasons']}
      else
        full_season_release = Tmdb::TV.detail(i)["last_air_date"]
        show_params = {:season_date => full_season_release, :additional_field => show['original_name'], :poster => show['poster_path'], :in_production => on_air?(show["last_air_date"]), :episode_count => show['number_of_seasons']}
      end
      a = Show.new(show_params)
      a.save
      puts "#{Time.now} - #{i}Success!"
      sleep 0.4
    end
    puts "#{Time.now} - FINISH!!!"
  end

  desc "for updates for subscriptions"
  task :update => :environment do
    User.all.each do |i|
      i.subscriptions.each do |j|
        if j.options['season']
          #TODO send email with serial name and season released text
          puts "#{i.email} recieved season announce about #{Show.find(j.serial_id).additional_field}"
        end
        if j.options['episode']
          #TODO send email with serial name and episode released text
          puts "#{i.email} recieved episode announce about #{Show.find(j.serial_id).additional_field}"
        end
        if j.options['three_episodes']
          #TODO send email with serial name and three_episodes released text
          puts "#{i.email} recieved three_episodes announce about #{Show.find(j.serial_id).additional_field}"
        end
      end
    end
  end
end