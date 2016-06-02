class ShowController < ApplicationController
	def index
		if params[:name]
			@shows = Show.search(params[:name])
		else
			@shows= Show.all
		end
	end

	def tags
		@tags = Show.where('tag like ?', "#{params[:q]}%").all_tags
		render json: @tags
	end
end
