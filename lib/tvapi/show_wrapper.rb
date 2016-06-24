class ShowWrapper
  attr_reader :show

  def initialize show = nil
    @show = show || Show.new
  end
end

module ShowWrapper::Tvmaze
  def wrap_show json
    @show.name_en ||= json['name'] if json['name'].present?
    @show.name_original ||= json['name'] if json['name'].present? && json['language'] == 'English'
    @show.tvmaze_id ||= json['id']
    @show.tvrage_id ||= json['externals']['tvrage'] if json['externals']['tvrage'].present?
    @show.tvdb_id ||= json['externals']['thetvdb'] if json['externals']['thetvdb'].present?
    @show.imdb_id ||= json['externals']['imdb'] if json['externals']['imdb'].present?
    @show.status ||= 'closed' if json['status'] == 'Ended'
    @show.status ||= 'airing' if json['status'] == 'Running'
    @show
  end
end

module ShowWrapper::Trakt
  def wrap_show json
    @show.name_en ||= json['title'] if json['title'].present?
    @show.poster ||= json['poster']['medium'] if json['poster']['medium'].present?
    @show.trakt_id ||= json['ids']['trakt']
    @show.tvrage_id ||= json['ids']['tvrage'] if json['ids']['tvrage'].present?
    @show.tvdb_id ||= json['ids']['tvdb'] if json['ids']['tvdb'].present?
    @show.imdb_id ||= json['ids']['imdb'] if json['ids']['imdb'].present?
    @show.tmdb_id ||= json['ids']['tmdb'] if json['ids']['tmdb'].present?
    @show.status ||= 'closed' if json['status'] == 'ended'
    @show.status ||= 'airing' if json['status'] == 'returning series'
    @show
  end
end

module ShowWrapper::Tmdb
  def wrap_show json
    @show.name_original ||= json['original_name'] if json['original_name'].present?
    @show.name_en ||= json['original_name'] if json['original_name'].present? && json['original_language'] == 'en'
    @show.poster ||= Show.image_url(json['poster_path']) if json['poster_path'].present?
    @show.tvrage_id ||= json['tvrage_id'] if json['tvrage_id'].present?
    @show.tvdb_id ||= json['tvdb_id'] if json['tvdb_id'].present?
    @show.imdb_id ||= json['imdb_id'] if json['imdb_id'].present?
    @show.tmdb_id ||= json['show']['id']
    @show.status ||= 'closed' if json['status'] == 'Ended'
    @show.status ||= 'airing' if json['status'] == 'Returning Series'
    @show
  end
end
