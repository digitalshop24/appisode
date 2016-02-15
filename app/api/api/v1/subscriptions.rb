module API
  module Entities
    class Subscription < Grape::Entity
      expose :id, documentation: {type: Integer,  desc: "ID подписки"}
      expose :show_id, documentation: {type: Integer, desc: 'ID сериала'}
      expose :name, documentation: {type: String, desc: 'Название сериала' } do |sub|
        sub.show.name
      end
      expose :poster, documentation: {type: String, desc: 'URL постера' } do |sub|
        sub.show.poster
      end
      expose :subtype, documentation: {type: String, desc: 'Тип подписки' }
      # expose :episode_date, if: lambda { |instance, options| options[:episode] }, documentation: {type: String, desc: 'Дата выхода серии'} do |sub|
      #   sub.episode.air_date
      # end
      # expose :season_date, if: lambda { |instance, options| !options[:episode] }, documentation: {type: String, desc: 'Дата выхода сезона'} do |sub|
      #   sub.show.seasons.last.episodes.last.air_date
      # end
    end
  end
end

module API
  module V1
    class Subscriptions < Grape::API
      version 'v1'
      format :json
      content_type :json, "application/json;charset=UTF-8"
      rescue_from :all

      resource :subscriptions, desc: 'Подписки' do
        desc "Список всех подписок пользователя", entity: API::Entities::Subscription
        params do
          requires :phone, type: String, desc: 'Телефон'
          requires :key, type: String, desc: 'Ключ'
        end
        get do
          user = User.find_by(phone: params[:phone])
          if user
            if user.key == params[:key]
              present user.subscriptions.where(active: true), with: API::Entities::Subscription
            else
              present :error, 'wrong key'
            end
          else
            present :error, 'not found'
          end
        end

        desc "Подписаться"
        params do
          requires :phone, type: String, desc: 'Телефон'
          requires :key, type: String, desc: 'Ключ'
          requires :show_id, type: Integer, desc: 'ID сериала'
          optional :episode_id, type: Integer, desc: 'ID эпизода'
          requires :subtype, type: String, desc: 'Тип подписки (episode, new_episodes, season)'
        end
        get '/subscribe' do
          user = User.find_by(phone: params[:phone])
          if user
            if user.key == params[:key]
              show = Show.find_by_id(params[:show_id])
              episode = Episode.find_by_id(params[:episode_id]) if params[:episode_id]
              if ((show && episode) || (show && !params[:episode_id]))
                if (show.episodes.include?(episode) || !params[:episode_id])
                  sub = user.subscriptions.create(
                    show_id: params[:show_id],
                    episode_id: params[:episode_id],
                    subtype: params[:subtype],
                    active: true
                  )
                  present sub, with: API::Entities::Subscription
                else
                  present :error, 'episode not from this show'
                end
              else
                present :error, 'episode or show not found'
              end
            else
              present :error, 'wrong key'
            end
          else
            present :error, 'user not found'
          end
        end

        desc "Отписаться"
        params do
          requires :phone, type: String, desc: 'Телефон'
          requires :key, type: String, desc: 'Ключ'
          requires :subscription_id, type: Integer, desc: 'ID подписки'
        end
        get '/unsubscribe' do
          user = User.find_by(phone: params[:phone])
          if user
            if user.key == params[:key]
              sub = Subscription.find_by_id(params[:subscription_id])
              if sub
                if sub.user_id == user.id
                  sub.destroy
                  present :response, 'unsubscribed'
                else
                  present :error, "not user's subscription"
                end
              else
                present :error, 'subscription not found'
              end
            else
              present :error, 'wrong auth key'
            end
          else
            present :error, 'user not found'
          end
        end

      end

    end
  end
end
