module API
  module Entities
    class Show < Grape::Entity
      expose :id, documentation: {type: "Integer",  desc: "ID"}
      expose :poster, documentation: { type: "String", desc: "Постер (http://image.tmdb.org/t/p/w500/...)" }
      expose :additional_field, documentation: { type: "String", desc: "Название" }
      expose :russian_name, documentation: { type: "String", desc: "Название на русском" }
      expose :in_production, documentation: { type: "Boolean", desc: "Выходит ли еще" }
      expose :episode_count, documentation: { type: "Integer", desc: "Количество серий" }
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
        desc "Список всех сериалов", entity: API::Entities::Show
        params do
          use :pagination
        end
        get do
          present Show.paginate(page: params[:page], per_page: params[:per_page]), with: API::Entities::Show
        end

        desc "Поиск сериала", entity: API::Entities::Show
        params do
          use :pagination
          requires :query, type: String, desc: 'Запрос'
        end
        get '/search' do
          present Show.search(params[:query]).paginate(page: params[:page], per_page: params[:per_page]), with: API::Entities::Show
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
