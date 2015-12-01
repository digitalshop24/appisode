class HomeController < ApplicationController
  require 'pry'
  def show
    binding.pry
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
