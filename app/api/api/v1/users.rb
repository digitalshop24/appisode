module API
  module V1
    class Users < Grape::API
      version 'v1'
      format :json
      content_type :json, "application/json;charset=UTF-8"
      rescue_from :all

      resource :users, desc: 'Действия, связанные с регистрацией/авторизацией' do
        # desc "Проверить авторизацию"
        # params do
        #   requires :phone, type: String, desc: 'Телефон'
        #   requires :key, type: String, desc: 'Ключ'
        # end
        # get '/check_auth' do
        #   user = User.find_by(phone: params[:phone])
        #   if user
        #     if user.auth_token == params[:key]
        #       present user.subscriptions, with: API::Entities::Subscription
        #     else
        #       error!({ ru: "Неверный ключ авторизации", en: "Wrong auth auth_token" }, 401)
        #     end
        #   else
        #     error!({ ru: "Пользователь не найден", en: "User not found" }, 404)
        #   end
        # end

        desc "Регистриация"
        params do
          requires :phone, type: String, desc: 'Телефон'
          optional :show_id, type: Integer, desc: 'ID сериала'
          optional :episode_id, type: Integer, desc: 'ID эпизода'
          optional :subtype, type: String, desc: 'Тип подписки (episode, new_episodes, season)'
        end
        post '/register' do
          confirmation = rand(1000 .. 9999)
          user = User.where(phone: params[:phone]).first_or_create
          if params[:show_id]
            user.subscriptions.create(
              show_id: params[:show_id],
              episode_id: params[:episode_id],
              subtype: params[:subtype],
              active: false
            )
          end
          user.update(confirmation: confirmation)

          sms = SmsAssistent.new.send(params[:phone], confirmation)
          info = sms.info
          if sms.status == 'ok'
            present :status, 'ok'
            present :en_message, info[:en]
            present :message, info[:ru]
          else
            error!({ ru: info[:ru], en: info[:en] }, info[:code])
          end
        end

        desc "Проверка кода"
        params do
          requires :phone, type: String, desc: 'Телефон'
          requires :confirmation, type: Integer, desc: 'Код'
        end
        post '/check_confirmation' do
          user = User.find_by(phone: params[:phone])
          if user
            if user.confirmation == params[:confirmation]
              subscriptions = user.subscriptions.where(active: false)
              unless subscriptions.empty?
                subscriptions.last.update(active: true)
              end

              present :auth_token, user.auth_token
              present :subscriptions, user.subscriptions, with: API::Entities::Subscription
            else
              user.subscriptions.where(active: false).delete_all
              error!({ ru: "Неверный код подтверждения", en: "Wrong confirmation" }, 401)
            end
          else
            error!({ ru: "Пользователь не найден", en: "User not found" }, 404)
          end
        end

        desc "Сохранение PUSH токена"
        params do
          requires :token, type: String, desc: 'PUSH токен'
        end
        post '/device' do
          error!(error_message(:auth), 401) unless authenticated

          d = current_user.devices.where(token: params[:token]).first_or_create
          if d
            present :status, 'ok'
            present :en_message, 'PUSH token saved'
            present :message, 'Push токен сохранен'
          else
            error!({ ru: "Какая-то ошибка", en: "Smth go wrong" }, 500)
          end
        end

        desc "Удаление PUSH токена"
        params do
          requires :token, type: String, desc: 'PUSH токен'
        end
        delete '/device' do
          device_token = Device.find_by(token: params[:token])
          if device_token
            if device_token.destroy
              present :status, 'ok'
              present :en_message, 'PUSH token destroyed'
              present :message, 'Push токен удален'
            else
              error!({ ru: "Какая-то ошибка", en: "Smth go wrong" }, 500)
            end
          else
            error!({ ru: "Такой токен не найден", en: "Not found" }, 404)
          end
        end

        desc "Тестирование уведомления"
        params do
          requires :token, type: String, desc: 'PUSH токен'
          optional :message, type: String, desc: 'Текст уведомления'
        end
        get '/test_push' do
          gcm = GCM.new(ENV['GCM_API_KEY'])
          registration_ids = params[:token].split(',')
          options = { data: { message: (params[:message] || 'тестовое уведомление') }, collapse_key: "updated_score"}
          response = gcm.send(registration_ids, options)
          if JSON.parse(response[:body])['results'].map{ |a| a.first.first }.include?('message_id')
            present :status, 'ok'
            present :en_message, 'Push notification sended'
            present :message, 'Push уведомление отправлено'
          else
            errors = JSON.parse(response[:body])['results'].map{|a| a['error']}.compact
            error!({ ru: "Ошибки: #{errors}", en: "Errord: #{errors}" }, 401)
          end
        end
      end
    end
  end
end
