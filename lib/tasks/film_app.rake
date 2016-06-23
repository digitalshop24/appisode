require 'open-uri'
namespace :film_app do
  desc "Rake task to get events data"

  task :load, [:start_page, :end_page] => :environment do |t, args|
    start_page, end_page = (args[:start_page] ? args[:start_page].to_i : 1), (args[:end_page] ? args[:end_page].to_i : 1000)
    (start_page..end_page).each do |i|
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

  task :load_all, [:from, :to] => :environment do |t, args|
    from, to = (args[:from] ? args[:from].to_i : 1), (args[:to] ? args[:to].to_i : 66000)
    (from..to).each do |i|
      begin
        Show.load i
      rescue => error
        puts "ERROR #{error}"
      end
    end
  end

  task load_ids: :environment do
    tc = TraktApi::Client.new(api_key: ENV['TRAKT_CLIENT_ID'])
    shows = Show.where('shows.tvdb_id IS NULL OR shows.imdb_id IS NULL OR shows.trakt_id IS NULL OR shows.tvrage_id IS NULL OR shows.tvmaze_id IS NULL')
    count = shows.count
    j = 0
    errors = []
    shows.each_with_index do |show, i|
      if show.tmdb_id
        puts "show id=#{show.id}"
        tmdb_show_ids = Show.get_json("#{show.tmdb_id}/external_ids")
        if !tmdb_show_ids
          puts "Show with tmdb_id=#{show.tmdb_id} DOES NOT EXISTS"
          next
        end
        imdb_id = tmdb_show_ids['imdb_id'] if tmdb_show_ids['imdb_id'].present?
        tvdb_id = tmdb_show_ids['tvdb_id']
        tvrage_id = tmdb_show_ids['tvrage_id']

        begin
          trakt_show = tc.search.call(id_type: 'tmdb', id: show.tmdb_id).body.select{ |s| s['type'] == 'show' }.first
          trakt_show = tc.search.call(id_type: 'imdb', id: imdb_id).body.select{ |s| s['type'] == 'show' }.first if !trakt_show && imdb_id
          trakt_show = tc.search.call(id_type: 'tvdb', id: tvdb_id).body.select{ |s| s['type'] == 'show' }.first if !trakt_show && tvdb_id
          trakt_show = tc.search.call(id_type: 'tvrage', id: tvrage_id).body.select{ |s| s['type'] == 'show' }.first if !trakt_show && tvrage_id
        rescue => error
          puts "ERROR while getting info from TRAKT.TV show(id=#{show.id}): #{error.message}"
          errors << { show_id: show.id, error_type: 'trakt.tv', error_message: error.message }
        end

        if trakt_show
          show.status = 'closed' if trakt_show['show']['status'] == 'ended'
          show.trakt_id = trakt_show['show']['ids']['trakt']
          imdb_id ||= trakt_show['show']['ids']['imdb'] if trakt_show['show']['ids']['imdb'].present?
          tvdb_id ||= trakt_show['show']['ids']['tvdb']
          tvdb_id ||= trakt_show['show']['ids']['tvrage']
        end
        show.imdb_id ||= imdb_id
        show.tvdb_id ||= tvdb_id
        show.tvrage_id ||= tvrage_id

        tvmaze = Tvmaze.new
        tvmaze_show = tvmaze.get(show.tvmaze_id) if show.tvmaze_id
        tvmaze_show ||= tvmaze.lookup('tvdb', show.tvdb_id) if show.tvdb_id
        tvmaze_show ||= tvmaze.lookup('imdb', show.imdb_id) if show.imdb_id
        tvmaze_show ||= tvmaze.lookup('tvrage', show.tvrage_id) if show.tvrage_id
        if tvmaze_show
          show.status = 'closed' if tvmaze_show['status'] == 'Ended'
          show.tvmaze_id = tvmaze_show['id']
          show.imdb_id ||= tvmaze_show['externals']['imdb'] if tvmaze_show['externals']['imdb'].present?
          show.tvdb_id ||= tvmaze_show['externals']['thetvdb']
          show.tvrage_id ||= tvmaze_show['externals']['tvrage']
        end
        begin
          show.save if show.changed?
        rescue => error
          puts "ERROR while saving show(id=#{show.id}): #{error.message}"
          errors << { show_id: show.id, error_type: 'saving', error_message: error.message }
        end
        if !tvmaze_show && !trakt_show
          puts "Show with tmdb_id=#{show.tmdb_id} not found!"
          j += 1
        end
      else
        puts "No tmdb_id for show with id #{show.id}"
      end
      puts "#{i+1}/#{count} done. #{j} shows not found."
    end
    puts errors
  end

  task check_subscriptions: :environment do
    Subscription.active.each{ |sub| sub.check }
  end

  task check_numbers: :environment do
    Show.order(popularity: :asc).each do |show|
      seasons = show.seasons
      if seasons.present?
        number_of_seasons = seasons.reorder(number: :desc).limit(1).first.number
        show.update(number_of_seasons: number_of_seasons)
        seasons.each do |season|
          episodes = season.episodes
          if episodes.present?
            number_of_episodes = episodes.reorder(number: :desc).limit(1).first.number
            season.update(number_of_episodes: number_of_episodes)
          end
        end
      end
    end
  end

  task check_show_statuses: :environment do
    Show.where(status: %w(airing hiatus)).each do |show|
      show.check_status
    end
  end


  task :load_name_translation, [:lang] => :environment do |t, args|
    column_name = "name_#{args[:lang]}"
    raise Exception.new("no column for this lang in db") unless Show.column_names.include?(column_name)
    shows = Show.where("shows.#{column_name}" => nil)
    shows_count = shows.count
    shows.each_with_index do |show, i|
      loaded_show = Show.get_json(show.tmdb_id, { language: args[:lang] })
      if loaded_show
        if (loaded_show['name'] != show.name_original || loaded_show['original_language'] == args[:lang] || loaded_show['name'] =~ /^[\d]+$/) && (loaded_show['name'] != show.name_en || (loaded_show['original_language'] == 'en' && args[:lang] == 'en'))
          puts("#{column_name}=\"#{show[column_name.to_sym]}\" updated to \"#{loaded_show['name']}\" for show #{i+1}/#{shows_count}(id=#{show.id};name_original=\"#{show.name_original}\")")
          show[column_name.to_sym] = loaded_show['name']
        else
          puts("#{column_name}=\"#{show[column_name.to_sym]}\" NOT updated to \"#{loaded_show['name']}\" for show #{i+1}/#{shows_count}(id=#{show.id};name_original=\"#{show.name_original}\")")
        end
        show.save
      else
        puts("Can't load show #{i+1}/#{shows_count}(id=#{show.id};name_original=\"#{show.name_original}\")")
      end
    end
  end

  task update: :environment do
    in_prod_shows = Show.where(status: %w(airing hiatus))
    in_prod_shows.each_with_index do |show, i|
      puts "#{i}/#{in_prod_shows.count}"
      json = Show.get_json(show.tmdb_id, { language: 'ru' })
      if json
        show.closed! if json['in_production'] == false
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
          if json['seasons'].last
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
        end
        puts "--- #{Time.now} - show \"#{show.name}\" updated. #{new_seasons} seasons added"
      end
    end
  end

  task tvmaze_check_updates: :environment do |t, args|
    tvmaze = Tvmaze.new
    tvmaze_ids = tvmaze.updates(1).keys
    tvmaze_ids.each_with_index do |tvmaze_id|
      show = Show.find_by(tvmaze_id: tvmaze_id)
      if show
        episodes_updated = 0
        episodes = tvmaze.episodes(tvmaze_id).select do |e|
          time = Time.parse(e['airstamp']) if e['airstamp'].present?
          time ||= Date.parse(e['airsdate']) if e['airsdate'].present?
          (time >= Time.now if time) || !time
        end
        episodes.each do |ep|
          season = show.seasons.where(number: ep['season']).first_or_create
          episode = season.episodes.where(number: ep['number']).first_or_initialize do
            air_date = Date.parse(ep['airdate']) if ep['airdate'].present?
            air_stamp = Time.parse(ep['airstamp']) if ep['airstamp'].present?
          end
          if episode.changed?
            episode.save
            episodes_updated += 1
          end
        end
        puts "Show \"#{show.name}\"(id=#{show.id}): #{episodes_updated} episodes updated" 
      else
        puts "Show with tvmaze_id=#{tvmaze_id} not found"
      end
    end
  end

  task :update_popularity, [:pages] => :environment do |t, args|
    pages = args[:pages] ? args[:pages].to_i : 100
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

  task inform: :environment do
    subscriptions = Subscription.joins(:next_notification_episode).where('episodes.air_date' => Date.today)
    subscriptions.each_with_index do |sub, i|
      res = sub.notify if sub.check
      puts "#{i+1}/#{subscriptions.count}(id=#{sub.id}) #{res}"
    end

    # # episode subscriptions
    # subscriptions = Subscription.episode.
    #   select('subscriptions.*, episodes.number AS episode_number, seasons.number AS season_number, shows.name_original AS show_name, shows.name_ru AS show_ru_name').
    #   joins(episode: [season: [:show]]).where('episodes.air_date' => Date.today)
    # subscriptions_count = subscriptions.count('subscriptions.id')
    # successful = 0
    # subscriptions.each_with_index do |sub, i|
    #   nt = Notification.create(
    #     subscription: sub,
    #     message: I18n.t('notifications.episode.today', season: sub.season_number, episode: sub.episode_number, show: sub.show_ru_name)
    #   )
    #   if nt.perform
    #     nt.update(performed: true)
    #     success = true
    #     puts "success == INFORM_LOG EPISODE #{i+1}/#{subscriptions_count} (id=#{sub.id})"
    #     successful += 1
    #   else
    #     puts "error == INFORM_LOG EPISODE #{i+1}/#{subscriptions_count} (id=#{sub.id})"
    #   end
    # end
    # puts "RESULT INFORM_LOG EPISODE #{successful}/#{subscriptions_count} successful"

    # # all new episodes subscriptions
    # subscriptions = Subscription.new_episodes.
    #   select('subscriptions.*, episodes.number AS episode_number, seasons.number AS season_number, shows.name_original AS show_name, shows.name_ru AS show_ru_name').
    #   joins(show: [seasons: [:episodes]]).where('episodes.air_date' => Date.today)
    # subscriptions_count = subscriptions.count('subscriptions.id')
    # successful = 0
    # subscriptions.each_with_index do |sub, i|
    #   nt = Notification.create(
    #     subscription: sub,
    #     message: I18n.t('notifications.new_episodes.today', season: sub.season_number, episode: sub.episode_number, show: sub.show_ru_name)
    #   )
    #   if nt.perform
    #     nt.update(performed: true)
    #     success = true
    #     puts "success == INFORM_LOG NEW_EPISODES #{i+1}/#{subscriptions_count} (id=#{sub.id})"
    #     successful += 1
    #   else
    #     puts "error == INFORM_LOG NEW_EPISODES #{i+1}/#{subscriptions_count} (id=#{sub.id})"
    #   end
    # end
    # puts "RESULT INFORM_LOG NEW_EPISODES #{successful}/#{subscriptions_count} successful"

    # # season subscriptions
    # subscriptions = Subscription.season.
    #   select('subscriptions.*, seasons.number_of_episodes as number_of_episodes, episodes.number AS current_episode_number, seasons.number AS season_number, shows.name_original AS show_name, shows.name_ru AS show_ru_name').
    #   joins(show: [seasons: [:episodes]]).where('episodes.air_date' => Date.today)
    # subscriptions_count = subscriptions.count('subscriptions.id')
    # i = 0
    # successful = 0
    # subscriptions.each do |sub|
    #   if sub.current_episode_number == sub.number_of_episodes
    #     i += 1
    #     nt = Notification.create(
    #       subscription: sub,
    #       message: I18n.t('notifications.season.today', season: sub.season_number, episode: sub.current_episode_number, show: sub.show_ru_name)
    #     )
    #     if nt.perform
    #       nt.update(performed: true)
    #       success = true
    #       puts "success == INFORM_LOG SEASON #{i+1} (id=#{sub.id})"
    #       successful += 1
    #     else
    #       puts "error == INFORM_LOG SEASON #{i+1} (id=#{sub.id})"
    #     end
    #   end
    # end
    # puts "RESULT INFORM_LOG SEASON #{successful}/#{i} successful"
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
