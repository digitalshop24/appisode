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
    class SubscriptionShort < Grape::Entity
      expose :id, documentation: {type: Integer,  desc: "ID подписки"}
      expose :subtype, documentation: {type: String, desc: 'Тип подписки' }
      expose :episodes_interval, documentation: { type: Integer, desc: "Кол-во серий для уведомления" }
      expose :next_notification_episode, documentation: { type: Episode, desc: "Следующая серия, о которой надо уведомить" }, using: API::Entities::Episode
    end
    class ShowShort < Grape::Entity
      expose :id, documentation: {type: Integer,  desc: "ID"}
      expose :poster_url, documentation: { type: String, desc: "Постер" }, as: :poster
      expose :name, documentation: { type: String, desc: "Название" } do |show, options|
        show.name(options[:language])
      end
      expose :name_original, documentation: { type: String, desc: "Оригинальное название" }
      expose :status, documentation: { type: String, desc: "Статус сериала" }
      expose :number_of_seasons, documentation: { type: Integer, desc: "Номер последнего сезона" }, as: :season_number
      expose :next_episode, documentation: { type: Episode, desc: "Следующая серия" }, using: API::Entities::Episode
      expose :current_season_episodes_number, documentation: {type: Integer, desc: "Количество серий в текущем сезоне" }, if: lambda{ |instance, options| instance.current_season } do |s|
        # s.current_season.episodes.order(number: :desc).limit(1).first.number
        s.current_season.number_of_episodes
      end
    end
    class ShowForSubscription < ShowShort
      expose :last_season_episode, documentation: { type: Episode, desc: "Последняя серия текущего сезона" }, using: API::Entities::Episode
      expose :subscription_image_url, documentation: { type: String, desc: "Картинка для подписки" }, as: :subscription_image
    end
    class ShowSearch < ShowShort
      expose :subscription_id, documentation: {type: Integer, desc: "Id подписки" },
      if: lambda{ |instance, options| options[:user] } do |instance, options|
        sub = options[:user].subscriptions.find_by(show_id: instance.id)
        sub.id if sub
      end
    end
    class ShowPreview < ShowShort
      expose :subscription, documentation: {type: SubscriptionShort, desc: "Id подписки" }, using: SubscriptionShort,
      if: lambda{ |instance, options| options[:user] } do |instance, options|
        options[:user].subscriptions.find_by(show_id: instance.id)
      end
      # expose :season_number, documentation: {type: Season, desc: "Номер последнего сезона" } do |s|
      #   s.last_season.number
      # end
      # expose :subscription_id, documentation: {type: Integer, desc: "Id подписки" },
      #   if: lambda{ |instance, options| instance.respond_to?(:subscription_id) && instance.subscription_id }
    end
    class Show < ShowPreview
      expose :episodes, documentation: { type: Episode, desc: "Серии последнего сезона" }, using: API::Entities::Episode do |s|
        s.last_season.episodes
      end
    end
  end
end

module API
  module V1
    class Shows < Grape::API
      helpers SharedParams
      helpers do
        include API::AuthHelper
        include API::ErrorMessagesHelper
      end

      resource :shows, desc: 'Cериалы' do
        desc "Список всех сериалов", entity: API::Entities::ShowPreview
        params do
          use :pagination
        end
        get do
          user = current_user if authenticated
          
          shows = Show.preload(:next_episode, :current_season).page(params[:page]).per(params[:per_page])
          present :total, shows.total_count
          present :shows, shows, with: API::Entities::ShowPreview, user: user, language: language
        end

        desc 'Популярные сериалы', entity: API::Entities::ShowPreview
        params do
          use :pagination
        end
        get '/popular' do
          user = current_user if authenticated

          shows = Show.popular.preload(:next_episode, :current_season)
          # shows = shows.get_user_subs(user) if user
          shows = shows.page(params[:page]).per(params[:per_page])

          present :total, shows.total_count
          present :shows, shows, with: API::Entities::ShowPreview, user: user, language: language
        end

        desc 'Новые сериалы', entity: API::Entities::ShowPreview
        params do
          use :pagination
        end
        get '/new' do
          user = current_user if authenticated

          shows = Show.new_shows.preload(:next_episode, :current_season)
          # shows = shows.get_user_subs(user) if user
          shows = shows.page(params[:page]).per(params[:per_page])

          present :total, shows.total_count
          present :shows, shows, with: API::Entities::ShowPreview, user: user, language: language
        end

        desc "Поиск сериала", entity: API::Entities::ShowPreview
        params do
          use :pagination
          requires :query, type: String, desc: 'Запрос'
        end
        get '/search' do
          user = current_user if authenticated

          shows = Show.search params[:query], order: { popularity: :asc }, page: params[:page], per_page: params[:per_page], match: :word_start, fields: Show.name_fields(:ru)

          present :total, shows.total_count
          present :shows, shows, with: API::Entities::ShowPreview, user: user, language: language
        end

        desc "Сериал по id", entity: API::Entities::Show
        params do
          requires :id, type: Integer, desc: 'Id'
        end
        get '/:id' do
          user = current_user if authenticated

          shows = Show.where(id: params[:id]).preload(:next_episode, :current_season).limit(1)
          # shows = shows.get_user_subs(user) if user

          present shows.first, with: API::Entities::Show, user: user, language: language
        end

        desc 'Страница сериала', entity: API::Entities::ShowPreview
        params do
          use :pagination
          requires :id, type: Integer, desc: 'Id'
        end
        get '/:id/page' do
          user = current_user if authenticated

          shows = Show.popular.preload(:next_episode, :current_season)
          # shows = shows.get_user_subs(user) if user
          shows = shows.page(params[:page]).per(params[:per_page])

          if(!params[:page] || params[:page] == 1)
            show = Show.where(id: params[:id]).preload(:next_episode, :current_season).limit(1)
            # show = show.get_user_subs(user) if user
          end
          res = show ? show + shows : shows
          present :total, shows.total_count
          present :shows, res, with: API::Entities::ShowPreview, user: user, language: language
        end
      end
    end
  end
end
