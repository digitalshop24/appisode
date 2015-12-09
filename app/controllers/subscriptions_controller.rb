class SubscriptionsController < ApplicationController
  require 'pry'
  def create

    @user = User.find(params[:user_id])
    binding.pry
    options = {:season => params[:season], :episode => params[:episode], :three_episodes => params[:three_episodes]}
    if @user.subscriptions.find_by_serial_id(params[:show_id]).nil?
      @subscription = @user.subscriptions.new(:serial_id => params[:show_id], :options => options)
      @subscription.save

    else
      #TODO
      binding.pry
      @subscription = @user.subscriptions.find_by_serial_id(params[:show_id])
      if options.values.compact.empty?
        @subscription.destroy
      else

        @subscription.update(:options => options)

      end
    end
  if params[:place] == "search"
    render "home/show"
  else
    redirect_to :back
  end
  end
end