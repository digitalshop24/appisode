class SeriesController < ApplicationController
  include SeriesHelper
  def create
    escaped_str =  params[:name].gsub(/[!%_]/) { |x| '!' + x }
    @current_films = Show.where("additional_field like ?", "%" + escaped_str + "%")
    render "home/show"
  end
end