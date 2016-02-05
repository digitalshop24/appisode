module API
  module Entities
    class Subscription < Grape::Entity
      expose :id
    end
  end
end

module API
  module V1
    class Users < Grape::API
      version 'v1'
      format :json
      content_type :json, "application/json;charset=UTF-8"
      rescue_from :all

      resource :users, desc: 'Users action' do
        desc "Check authorization"
        params do
          requires :phone, type: String, desc: 'Phone'
          requires :key, type: String, desc: 'Key'
        end
        post '/check_auth' do
          user = User.find_by(phone: params[:phone])
          if user.key == params[:key]
            present user.subscriptions, with: API::Entities::Subscription
          else
            present
          end
        end

        desc "Registration"
        params do
          requires :phone, type: String, desc: 'Phone'
          optional :show_id, type: Integer, desc: 'Show id'
          optional :episode_id, type: Integer, desc: 'Episode id'
          optional :episode, type: Boolean, desc: 'Na episod li podpiska'
        end
        post '/register' do
          confirmation = rand(1000 .. 9999)
          # if params[:subscription]
          #   user.subscriptions.create(:show_id => params[:show_id], :episode => params[:episode], :three_episodes => params[:three_episodes])
          # end 
          
          user = User.where(phone: params[:phone]).first_or_create
          user.update(confirmation: confirmation)
          u = URI.enconfirmation("https://userarea.sms-assistent.by/api/v1/send_sms/plain?user=Iksboks&password=cS6888b5&recipient=#{params[:phone]}&message=#{confirmation}&sender=APPISODE")
          Net::HTTP.get(URI(u))
          present :response, 'sms sended'
        end


        desc "confirmation check"
        params do
          requires :phone, type: String, desc: 'Phone'
          requires :confirmation, type: Integer, desc: 'confirmation'
        end
        post '/check_confirmation' do
          user = User.find_by(phone: params[:phone])
          if user.confirmation == params[:confirmation]
            key = SecureRandom.hex(20)
            user.update(key: key)

            present :key, key
            present :subscriptions, user.subscriptions, with: API::Entities::Subscription
          else
            status 401
          end
        end
      end
    end
  end
end
