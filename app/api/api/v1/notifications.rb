module API
  module Entities
    class Notification < Grape::Entity
      expose :id, documentation: {type: Integer,  desc: "ID уведомления"}
      expose :message, documentation: {type: String,  desc: "Текст"}
      expose :image, documentation: {type: String, desc: "Картинка" } do |_|
        "http://cdn01.cdn.justjared.com/wp-content/uploads/headlines/2014/01/breaking-bad-sag-awards-2014.jpg"
      end
      expose :show_id, documentation: { type: Integer, desc: 'ID сериала' } do |n|
        n.subscription&.show_id
      end
    end
  end
end

module API
  module V1
    class Notifications < Grape::API
      helpers SharedParams
      helpers do
        include API::AuthHelper
        include API::ErrorMessagesHelper
      end

      before do
        error!(error_message(:auth), 401) unless authenticated
      end

      resource :notifications, desc: 'Уведомления' do
        desc "Все уведомления", entity: API::Entities::Notification
        params do
          optional :skip, type: Integer, desc: 'Пропустить'
          optional :take, type: Integer, desc: 'Взять'
        end
        get do
          nots = current_user.notifications.not_viewed.includes(:subscription)
          present :total, nots.count
          present :shows, nots.offset(params[:skip] || 0).limit(params[:take] || 6), with: API::Entities::Notification
        end

        desc "Прочитать оповещения"
        params do
          requires :notification_id, type: Integer, desc: 'Id оповещения (это и все предыдущие оповещения пользователя будут прочитаны)'
        end
        post do
          current_user.notifications.where('notifications.id <= ?', params[:notification_id]).update_all(viewed: true)
          present :status, 'ok'
        end
      end
    end
  end
end
