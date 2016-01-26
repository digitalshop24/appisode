class SubscriptionController < ApplicationController
	def show
		@user = User.where(:phone => params[:phone]).first
		@subscriptions = @user.subscriptions
		render :json => @subscriptions
	end
	def add
		@user = User.where(:phone => params[:phone]).first
		if @user.subscriptions.create(:show_id => params[:show_id], :episode => params[:episode], :three_episodes => params[:three_episodes])
			render :json => 'success'	
		end
	end
end
