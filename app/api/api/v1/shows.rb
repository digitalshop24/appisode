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
      expose :season_number, documentation: { type: Integer, desc: "Номер последнего сезона" } do |s|
        s.seasons.last.number
      end
      # expose :next_episode, if: lambda { |object, options| object.next_episode },
      #    documentation: { type: String, desc: "Дата следующей серии" } do |show|
      #     show.next_episode.air_date
      # end
      expose :next_episode, if: lambda { |object, options| object.next_episode },
        documentation: { type: Episode, desc: "Следующая серия" }, using: API::Entities::Episode
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
      version 'v1'
      format :json
      content_type :json, "application/json;charset=UTF-8"
      rescue_from :all

      helpers do
        params :pagination do
          optional :page, type: Integer, desc: 'Номер страницы'
          optional :per_page, type: Integer, desc: 'На странице'
        end
      end

      resource :shows, desc: 'Cериалы' do
        desc "Список всех сериалов", entity: API::Entities::ShowPreview
        params do
          use :pagination
        end
        get do
          present Show.paginate(page: params[:page], per_page: params[:per_page]), with: API::Entities::ShowPreview
        end

        desc 'Популярные сериалы', entity: API::Entities::ShowPreview
        get '/popular' do
          present Show.popular, with: API::Entities::ShowPreview
        end

        desc 'Новые сериалы', entity: API::Entities::ShowPreview
        get '/new' do
          present Show.new_shows, with: API::Entities::ShowPreview
        end

        desc "Поиск сериала", entity: API::Entities::ShowPreview
        params do
          use :pagination
          requires :query, type: String, desc: 'Запрос'
        end
        get '/search' do
          present Show.search(params[:query]).paginate(page: params[:page], per_page: params[:per_page]), with: API::Entities::ShowPreview
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
