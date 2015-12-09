class SeriesController < ApplicationController
  require 'pry'
  include SeriesHelper
  def create
    escaped_str =  params[:name].gsub(/[!%_]/) { |x| '!' + x }
    binding.pry
    @current_films = Show.where("additional_field like ?", "%" + escaped_str + "%")
    render "home/show"
  end
end