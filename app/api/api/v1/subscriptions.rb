module API
  module Entities
    class Subscription < Grape::Entity
      expose :id, documentation: {type: Integer,  desc: "ID подписки"}
      expose :episode, if: lambda { |object, options| object.episode },
        documentation: { type: Episode, desc: "Серия" }, using: API::Entities::Episode
      expose :show, documentation: { type: ShowPreview, desc: "Сериал" }, using: API::Entities::ShowPreview
      expose :subtype, documentation: {type: String, desc: 'Тип подписки' }
    end
  end
end

module API
  module V1
    class Subscriptions < Grape::API
      helpers SharedParams

      resource :subscriptions, desc: 'Подписки' do
        desc "Список всех подписок пользователя", entity: API::Entities::Subscription
        params do
          requires :phone, type: String, desc: 'Телефон'
          requires :key, type: String, desc: 'Ключ'
          use :pagination
        end
        get do
          user = User.find_by(phone: params[:phone])
          if user
            if user.auth_token == params[:key]
              subs = user.subscriptions.where(active: true).preload(:episode, show: [:next_episode]).paginate(page: params[:page], per_page: params[:per_page])
              present :total, subs.total_entries
              present :items, subs, with: API::Entities::Subscription
            else
              error!({ ru: "Неверный ключ авторизации", en: "Wrong auth key" }, 401)
            end
          else
            error!({ ru: "Пользователь не найден", en: "User not found" }, 404)
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
            if user.auth_token == params[:key]
              show = Show.find_by_id(params[:show_id])
              episode = Episode.find_by_id(params[:episode_id]) if params[:episode_id]
              if ((show && episode) || (show && !params[:episode_id]))
                if (show.episodes.include?(episode) || !params[:episode_id])
                  subs = user.subscriptions.where(
                    show_id: params[:show_id]
                  )
                  if subs.empty?
                    sub = user.subscriptions.create(
                      show_id: params[:show_id],
                      episode_id: params[:episode_id],
                      subtype: params[:subtype],
                      active: true
                    )
                    present sub, with: API::Entities::Subscription
                  else
                    error!({ ru: "Такая подписка уже существует", en: "Subscription to this show already exists" }, 406)
                  end
                else
                  error!({ ru: "Серия не из этого сериала", en: "Episode not from this show" }, 406)
                end
              else
                error!({ ru: "Сериал или серия не найдены", en: "Episode or show not found" }, 404)
              end
            else
              error!({ ru: "Неверный ключ авторизации", en: "Wrong auth key" }, 401)
            end
          else
            error!({ ru: "Пользователь не найден", en: "User not found" }, 404)
          end
        end

        desc "Отписаться"
        params do
          requires :phone, type: String, desc: 'Телефон'
          requires :key, type: String, desc: 'Ключ'
          optional :subscription_id, type: Integer, desc: 'ID подписки'
          optional :show_id, type: Integer, desc: 'ID сериала'
        end
        get '/unsubscribe' do
          user = User.find_by(phone: params[:phone])
          if user
            if user.auth_token == params[:key]
              sub = Subscription.find_by_id(params[:subscription_id]) || Subscription.find_by_show_id(params[:show_id])
              if sub
                if sub.user_id == user.id
                  sub.destroy
                  present :status, 'ok'
                  present :en_message, 'Unsubscribed'
                  present :message, 'Отписка выполнена'
                else
                  error!({ ru: "Подписка не принадлежит этому пользователю", en: "Not user's subscription" }, 406)
                end
              else
                error!({ ru: "Подписка не найдена", en: "Subscription not found" }, 404)
              end
            else
              error!({ ru: "Неверный ключ авторизации", en: "Wrong auth key" }, 401)
            end
          else
            error!({ ru: "Пользователь не найден", en: "User not found" }, 404)
          end
        end

      end

    end
  end
end
