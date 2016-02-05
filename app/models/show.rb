require 'open-uri'
class Show < ActiveRecord::Base
  has_many :seasons
  default_scope { order('created_at DESC') }	
	def self.search(query)
		where('lower(name) like lower(:query) or lower(russian_name) like lower(:query)', { query: "%#{query}%" })
  end
	def self.get_json(path, params = {})
	  api_key = '15e545fda3d4598527fac7245a459571'
	  url = 'http://api.themoviedb.org/3/tv'
	  get_params = params
	  get_params[:api_key] = api_key
	  uri = URI.escape("#{url}/#{path}?#{get_params.to_query}")
	  resp = open(uri).read
	  JSON.parse(resp)
	end

	def self.image_url(image, format = 'w500')
	  "http://image.tmdb.org/t/p/#{format}#{image}"
	end
  def self.popular
  	ids = get_json('popular')['results'].map{|s| s['id']}
  	where(tmdb_id: ids)
  end
  def episodes
  	ids = seasons.pluck(:id)
  	Episode.where(season_id: ids)
  end
  def next_episode
  	episodes.where('air_date > ?', Time.now).order(air_date: :asc).first
  end
end
