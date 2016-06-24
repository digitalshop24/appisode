class Trakt
  def initialize
    @client = TraktApi::Client.new(api_key: ENV['TRAKT_CLIENT_ID'])
  end
  
  def lookup_show show
  	trakt_json = lookup('trakt-show', show.trakt_id) if show.trakt_id
    trakt_json ||= lookup('tvdb', show.tvdb_id) if show.tvdb_id
    trakt_json ||= lookup('imdb', show.imdb_id) if show.imdb_id
    trakt_json ||= lookup('tvrage', show.tvrage_id) if show.tvrage_id
    trakt_json
  end

  def lookup api, id
    res = @client.search.call(id_type: api, id: id).body.select{ |s| s['type'] == 'show' }.first
    res['show'] if res
  end
end
