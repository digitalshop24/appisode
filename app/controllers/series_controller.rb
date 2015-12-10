class SeriesController < ApplicationController
  include SeriesHelper
  def create
    escaped_str =  params[:name].mb_chars.capitalize.to_s.gsub(/[!%_]/) { |x| '!' + x }
    @current_films = Show.where("additional_field ilike :search or russian_name ilike :search", search: "%" + escaped_str + "%")
    render "home/show"
  end
end