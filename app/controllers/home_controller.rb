class HomeController < ApplicationController

  def show
    if current_user
      if session[:flag] == "unsuccess"
        flash[:notice] = "No data"
      else
        @serial = Series.where(user_id: current_user.id).last
      end

    end
  end

  def create

  end
end
