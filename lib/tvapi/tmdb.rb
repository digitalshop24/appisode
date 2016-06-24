class Tmdb
  def initialize
    @api_key = '15e545fda3d4598527fac7245a459571'
    @api_url = 'http://api.themoviedb.org/3'
  end

  def get_json(path, params = {})
    get_params = params.merge({ api_key: @api_key})
    uri = URI.escape("#{@api_url}/#{path}?#{get_params.to_query}")
    tries = 0
    begin
      resp = open(uri).read
    rescue => error
      puts("ERROR ===>> #{error.class} and #{error.message}")
      sleep(2)
      tries += 1
      retry if tries < 5
    end
    JSON.parse(resp) if resp
  end

  def get_show tmdb_id
    get_json("tv/#{tmdb_id}")
  end

  def lookup_show show
    tmdb_json = get_show(show.tmdb_id) if show.tmdb_id
    tmdb_json ||= lookup('tvdb', show.tvdb_id) if show.tvdb_id
    tmdb_json ||= lookup('imdb', show.imdb_id) if show.imdb_id
    tmdb_json ||= lookup('tvrage', show.tvrage_id) if show.tvrage_id
    tmdb_json
  end

  def lookup api, id
    tvapi = { tvrage: 'tvrage_id', tvdb: 'tvdb_id', imdb: 'imdb_id' }[api.to_sym]
    get_json("find/#{id}", { external_sorce: tvapi })['tv_results'].first
  end
end
