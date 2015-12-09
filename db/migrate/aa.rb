class SeriesController < ApplicationController
  require 'pry'
  include SeriesHelper
  def create
    Tmdb::Api.key('15e545fda3d4598527fac7245a459571')
    current_film = Tmdb::TV.find(params[:name]).first
    if current_film
      user_id = current_user.id
      film_id = current_film.id
      title = current_film.original_name
      logo = current_film.poster_path
      show = Tmdb::TV.detail(film_id)
      number_of_seasons = show["number_of_seasons"]

      if on_air?(show["last_air_date"])
        last_season = Tmdb::Season.detail(film_id, number_of_seasons)
        number_of_episodes = last_season["episodes"].count - 1
        three_series = []
        i = 0
        while three_series.count < 3 && i <= number_of_episodes
          if last_season["episodes"][i]["air_date"] > Time.zone.now.to_s.slice(0..9)
            three_series << last_season["episodes"][i]["air_date"]
          end

          i+=1
        end

        full_season_release = last_season["episodes"][number_of_episodes]["air_date"]
        case three_series.count
          when 1
            first_episode = three_series[0]
          when 2
            first_episode = three_series[0]
            second_episode = three_series[1]
          when 3
            first_episode = three_series[0]
            second_episode = three_series[1]
            third_episode = three_series[2]
        end
        binding.pry
      else
        full_season_release = Tmdb::TV.detail(film_id)["last_air_date"]
      end





      series_params = {:user_id => user_id, :film_id => film_id, :title => title, :logo => logo, :date => first_episode, :full_date => full_season_release, :second => second_episode, :third => third_episode}
      binding.pry
      @serial = Series.new(series_params)
      @serial.save
      session[:flag] = "success"
      redirect_to :back
    else
      session[:flag] = "unsuccess"
      redirect_to :back
    end


  end
end