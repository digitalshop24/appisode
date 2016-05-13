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
      # expose :season_number, documentation: { type: Integer, desc: "Номер последнего сезона" } do |s|
      #   s.seasons.last.try(:number)
      # end
      expose :season_number, documentation: { type: Integer, desc: "Номер последнего сезона" }
      # expose :next_episode, if: lambda { |object, options| object.next_episode },
      #    documentation: { type: String, desc: "Дата следующей серии" } do |show|
      #     show.next_episode.air_date
      # end
      # expose :next_episode, if: lambda { |object, options| object.next_episode },
      #   documentation: { type: Episode, desc: "Следующая серия" }, using: API::Entities::Episode
      expose :next_episode, documentation: { type: Episode, desc: "Следующая серия" }, using: API::Entities::Episode
    end
    class Show < ShowPreview
      expose :episodes, documentation: { type: Episode, desc: "Серии последнего сезона" }, using: API::Entities::Episode do |s|
        s.seasons.last.episodes.order(air_date: :asc)
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
          shows = Show.select('shows.*, MAX(seasons.number) AS season_number').
            joins("LEFT OUTER JOIN seasons ON shows.id = seasons.show_id").group('shows.id').
            preload(:one_next_episode).paginate(page: params[:page], per_page: params[:per_page])
          present :total, shows.total_entries
          present :shows, shows, with: API::Entities::ShowPreview
        end

        desc 'Популярные сериалы', entity: API::Entities::ShowPreview
        params do
          use :pagination
        end
        get '/popular' do
          shows = Show.popular
          present :total, shows.count.count
          present :shows, shows.paginate(page: params[:page], per_page: params[:per_page]), with: API::Entities::ShowPreview
        end

        desc 'Новые сериалы', entity: API::Entities::ShowPreview
        params do
          use :pagination
        end
        get '/new' do
          shows = Show.new_shows
          present :total, shows.count.count
          present :shows, shows.paginate(page: params[:page], per_page: params[:per_page]), with: API::Entities::ShowPreview
        end

        desc "Поиск сериала", entity: API::Entities::ShowPreview
        params do
          use :pagination
          requires :query, type: String, desc: 'Запрос'
        end
        get '/search' do
          shows = Show.search(params[:query])
          present :total, shows.count
          present :shows, shows.paginate(page: params[:page], per_page: params[:per_page]), with: API::Entities::ShowPreview
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
