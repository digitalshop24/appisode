class UserController < ApplicationController
	def index
	end

	def registration
		#registration /user/registration?phone=375XXXXXXXXX
		#registration on subscription registration?phone=375XXXXXXXXX&show_id=113&episode=true&three_episodes=true&season=false&subscription=true	
		if User.where(:phone => params[:phone]).empty?
			@check = rand(1000 .. 9999)
			@user = User.create(:phone => params[:phone], :confirmation => @check)
			if params[:subscription]
				@user.subscriptions.create(:show_id => params[:show_id], :episode => params[:episode], :three_episodes => params[:three_episodes])
			end	
			u = URI.encode("https://userarea.sms-assistent.by/api/v1/send_sms/plain?user=Iksboks&password=cS6888b5&recipient=#{params[:phone]}&message=#{@check}&sender=APPISODE")
			uri = URI(u)
			a = Net::HTTP.get(uri)
			render :json => @check
		else
			render :json => 'already registered'
		end
  end

	def recovery
		#send new code if forgot last one
		@user = User.where(:phone => params[:phone]).first
		@check = rand(1000 .. 9999)
		u = URI.encode("https://userarea.sms-assistent.by/api/v1/send_sms/plain?user=Iksboks&password=cS6888b5&recipient=#{params[:phone]}&message=#{@check}&sender=APPISODE")
		uri = URI(u)
		a = Net::HTTP.get(uri)
		@user.update_column(:confirmation, @check)
		render :json => @check
	end	
end
