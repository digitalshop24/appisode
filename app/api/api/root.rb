require 'grape-swagger'
module API
  class Root < Grape::API
    format :json
    content_type :json, "application/json;charset=UTF-8"
    rescue_from :all, backtrace: true
    prefix 'api'
    mount API::V1::Root
  end
end
