class Tvmaze
  def initialize
    @api_path = "http://api.tvmaze.com/"
    @conn = Faraday.new(url: @api_path)
  end

  def get tvmaze_id
    raise Exception.new("tvmaze_id cant be nil") unless tvmaze_id
    res = @conn.get do |req|
      req.url "shows/#{tvmaze_id}"
    end
    JSON.parse(res.body)
  end

  def episodes tvmaze_id
    res = @conn.get do |req|
      req.url "shows/#{tvmaze_id}/episodes"
    end
    JSON.parse(res.body)
  end

  def updates days = nil
    res = @conn.get do |req|
      req.url "updates/shows"
    end
    json = JSON.parse(res.body)
    if days
      json = json.select { |k,v| Time.at(v) > Date.today - days.day }
    end
    json
  end

  def lookup api, id
    tvapi = { tvrage: 'tvrage', tvdb: 'thetvdb', imdb: 'imdb' }[api.to_sym]
    if tvapi
      raise Exception.new("Id cant be nil") unless id
      path = '/lookup/shows'
      res = @conn.get do |req|
        req.url path
        req.params[tvapi] = id
      end
      if res.status == 301
        get res.headers['location'].split('/').last
      end
    else
      raise Exception.new("Unsupported tvapi: #{api}. Allowed: [tvrage, tvdb, imdb]")
    end
  end
end
