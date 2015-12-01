class SeriesController < ApplicationController
  def create
    Tmdb::Api.key('15e545fda3d4598527fac7245a459571')
    current_film = Tmdb::TV.find(params[:name]).first
    if current_film
      user_id = current_user.id
      film_id = current_film.id
      title = current_film.original_name
      logo = current_film.poster_path
      date = Tmdb::TV.detail(film_id)["last_air_date"]
      series_params = {:user_id => user_id, :film_id => film_id, :title => title, :logo => logo, :date => date}

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