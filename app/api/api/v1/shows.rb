module API
  module Entities
    class Episode < Grape::Entity
      expose :id, documentation: {type: Integer,  desc: "ID серии"}
      expose :number, documentation: {type: Integer,  desc: "Номер серии"}
      expose :air_date, documentation: {type: Integer,  desc: "Дата выхода серии"}
      expose :aired, documentation: {type: 'Boolean', desc: 'Вышел ли уже'} do |e|
        e.air_date < Time.now
      end
      expose :days_left, documentation: {type: Integer, desc: 'Дней до выхода серии'}
    end
    class ShowShort < Grape::Entity
      expose :id, documentation: {type: Integer,  desc: "ID"}
      expose :poster, documentation: { type: String, desc: "Постер" }
      expose :name, documentation: { type: String, desc: "Название" }
      expose :russian_name, documentation: { type: String, desc: "Название на русском" }
      expose :in_production, documentation: { type: "Boolean", desc: "Выходит ли еще" }
    end
    class ShowPreview < ShowShort
      expose :number_of_seasons, documentation: { type: Integer, desc: "Номер последнего сезона" }, as: :season_number
      # expose :season_number, documentation: {type: Season, desc: "Номер последнего сезона" } do |s|
      #   s.last_season.number
      # end
      expose :current_season_episodes_number, documentation: {type: Season, desc: "Текущий сезон" }, if: lambda{ |instance, options| instance.current_season } do |s|
        # s.current_season.episodes.order(number: :desc).limit(1).first.number
        s.current_season.number_of_episodes
      end
      expose :next_episode, documentation: { type: Episode, desc: "Следующая серия" }, using: API::Entities::Episode
    end
    class Show < ShowPreview
      expose :episodes, documentation: { type: Episode, desc: "Серии последнего сезона" }, using: API::Entities::Episode do |s|
        s.last_season.episodes.order(air_date: :asc)
      end
    end
  end
end

module API
  module V1
    class Shows < Grape::API
      helpers SharedParams

      resource :shows, desc: 'Cериалы' do
        desc "Список всех сериалов", entity: API::Entities::ShowPreview
        params do
          use :pagination
        end
        get do
          shows = Show.preload(:next_episode, :current_season).paginate(page: params[:page], per_page: params[:per_page])
          present :total, shows.total_entries
          present :shows, shows, with: API::Entities::ShowPreview
        end

        desc 'Популярные сериалы', entity: API::Entities::ShowPreview
        params do
          use :pagination
        end
        get '/popular' do
          shows = Show.popular.preload(:next_episode, :current_season).paginate(page: params[:page], per_page: params[:per_page])
          present :total, shows.total_entries
          present :shows, shows, with: API::Entities::ShowPreview
        end

        desc 'Новые сериалы', entity: API::Entities::ShowPreview
        params do
          use :pagination
        end
        get '/new' do
          shows = Show.new_shows.preload(:next_episode, :current_season).paginate(page: params[:page], per_page: params[:per_page])
          present :total, shows.total_entries
          present :shows, shows, with: API::Entities::ShowPreview
        end

        desc "Поиск сериала", entity: API::Entities::ShowPreview
        params do
          use :pagination
          requires :query, type: String, desc: 'Запрос'
        end
        get '/search' do
          shows = Show.search(params[:query]).joins("LEFT OUTER JOIN seasons ON shows.id = seasons.show_id").
            select('shows.*, MAX(seasons.number) AS season_number').group('shows.id').
            preload(:next_episode, :current_season).paginate(page: params[:page], per_page: params[:per_page])
          present :total, shows.total_entries
          present :shows, shows, with: API::Entities::ShowPreview
        end

        desc "Сериал по id", entity: API::Entities::Show
        params do
          requires :id, type: Integer, desc: 'Id'
        end
        get '/:id' do
          present Show.find(params[:id]), with: API::Entities::Show
        end
      end
    end
  end
end
