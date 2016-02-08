module API
  module V1
    class Users < Grape::API
      version 'v1'
      format :json
      content_type :json, "application/json;charset=UTF-8"
      rescue_from :all

      resource :users, desc: 'Действия, связанные с регистрацией/авторизацией' do
        desc "Проверить авторизацию"
        params do
          requires :phone, type: String, desc: 'Телефон'
          requires :key, type: String, desc: 'Ключ'
        end
        get '/check_auth' do
          user = User.find_by(phone: params[:phone])
          if user
            if user.key == params[:key]
              present user.subscriptions, with: API::Entities::Subscription
            else
              present :error, 'wrong key'
            end
          else
            present :eror, 'user not found'
          end
        end

        desc "Регистриация"
        params do
          requires :phone, type: String, desc: 'Телефон'
          optional :show_id, type: Integer, desc: 'ID сериала'
          optional :episode_id, type: Integer, desc: 'ID эпизода'
          optional :subtype, type: String, desc: 'Тип подписки (episode, new_episodes, season)'
        end
        get '/register' do
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
          u = URI.encode("https://userarea.sms-assistent.by/api/v1/send_sms/plain?user=Iksboks&password=cS6888b5&recipient=#{params[:phone]}&message=#{confirmation}&sender=APPISODE")
          Net::HTTP.get(URI(u))
          present :response, 'sms sended'
        end


        desc "Проверка кода"
        params do
          requires :phone, type: String, desc: 'Телефон'
          requires :confirmation, type: Integer, desc: 'Код'
        end
        get '/check_confirmation' do
          user = User.find_by(phone: params[:phone])
          puts params
          if user
            if user.confirmation == params[:confirmation]
              key = user.key
              unless key
                key = SecureRandom.hex(20)
                user.update(key: key)
              end
              
              subscriptions = user.subscriptions.where(active: false)
              unless subscriptions.empty?
                subscriptions.last.update(active: true)
              end

              present :key, key
              present :subscriptions, user.subscriptions, with: API::Entities::Subscription
            else
              user.subscriptions.where(active: false).delete_all
              present :error, 'wrong confirmation'
            end
          else
            present :error, 'user not found'
          end
        end
      end
    end
  end
end
