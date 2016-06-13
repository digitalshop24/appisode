module API
  module Entities
    class Notification < Grape::Entity
      expose :id, documentation: {type: Integer,  desc: "ID уведомления"}
      expose :message, documentation: {type: String,  desc: "Текст"}
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
        desc "Все уведомления", entity: API::Entities::Notifications
        params do
          use :pagination
        end
        get do
          nots = current_user.notifications.not_viewed.page(params[:page]).per(params[:per_page])
          present :total, nots.total_count
          present :shows, nots, with: API::Entities::Notification
        end

        desc "Прочитать оповещения"
        params do
          requires :notification_id, type: Integer, desc: 'Id оповещения (это и все предыдущие оповещения пользователя будут прочитаны)'
        end
        post do
          current_user.notifications.where('id <= ?', params[:notification_id]).update_all(viewed: true)
          present :status, 'ok'
        end
      end
    end
  end
end
