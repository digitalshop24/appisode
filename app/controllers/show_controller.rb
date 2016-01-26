class ShowController < ApplicationController
	def index
		if params[:name]
			@shows = Show.search(params[:name])
		else
			@shows= Show.all
		end
	end
end
