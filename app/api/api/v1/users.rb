module API
  module V1
    class Users < Grape::API
      version 'v1'
      format :json
      content_type :json, "application/json;charset=UTF-8"
      rescue_from :all

      helpers do
        include API::AuthHelper
        include API::ErrorMessagesHelper
      end

      resource :users, desc: 'Действия, связанные с регистрацией/авторизацией' do
        desc "Проверить авторизацию"
        get '/check_auth' do
          error!(error_message(:auth), 401) unless authenticated

          present :status, 'ok'
        end

        desc "Регистриация"
        params do
          requires :phone, type: String, desc: 'Телефон'
          optional :show_id, type: Integer, desc: 'ID сериала'
          optional :episode_id, type: Integer, desc: 'ID эпизода'
          optional :subtype, type: String, desc: 'Тип подписки', values: Subscription.subtypes.keys
        end
        post '/register' do
          confirmation = rand(1000 .. 9999)
          phone = ::Phone.new(params[:phone])
          error!({ ru: 'Неверный номер', en: 'Invalid phone' }, 406) unless phone.valid?

          user = User.where(phone: phone.formatted_phone).first_or_create
          user.update(confirmation: confirmation)

          sub_info = begin
            Subscription.subscribe(user, params[:show_id], params[:subtype], params[:episode_id], false) if params[:show_id]
            '. Подписка сохранена'
          rescue => error
            '. Подписка не сохранена'
          end
          sms = SmsTwilio.new.send(phone.formatted_phone, confirmation)
          info = sms.info
          if sms.status == 'ok'
            present :phone, user.phone
            present :status, 'ok'
            present :en_message, info[:en]
            present :message, info[:ru] + sub_info
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
              subscriptions = user.subscriptions.inactive
              unless subscriptions.empty?
                subscriptions.last.update(active: true)
              end

              present :auth_token, user.auth_token
              present :subscriptions, user.subscriptions.active, with: API::Entities::Subscription
            else
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
          optional :push_type, type: String, desc: 'Тип: data или notification (по умолчанию - data)', values: %w(data notification)
          optional :icon, type: String, desc: 'Иконка (по умолчанию: http://icons.iconarchive.com/icons/graphicloads/colorful-long-shadow/256/Home-icon.png)'
          optional :collapse_key, type: String, desc: 'Хз что это (по умолчанию updated_score), только у data'
        end
        get '/test_push' do
          gcm = GCM.new(ENV['GCM_API_KEY'])
          registration_ids = params[:token].split(',')
          icon = params[:icon] || 'http://icons.iconarchive.com/icons/graphicloads/colorful-long-shadow/256/Home-icon.png'
          message = params[:message] || 'тестовое уведомление'
          options = if params[:push_type] == 'notification'
            { notification: { body: message, title: 'Appisode', icon: icon } }
          else
            # message, title, notId, msgcnt
            { data: { title: 'hi', message: message }}
          end
          response = gcm.send(registration_ids, options)
          if JSON.parse(response[:body])['results'].map{ |a| a.first.first }.include?('message_id')
            present :status, 'ok'
            present :en_message, 'Push notification sended'
            present :message, 'Push уведомление отправлено'
            present :sended_data, options.to_s
          else
            errors = JSON.parse(response[:body])['results'].map{|a| a['error']}.compact
            error!({ ru: "Ошибки: #{errors}", en: "Errors: #{errors}" }, 401)
          end
        end
      end
    end
  end
end
