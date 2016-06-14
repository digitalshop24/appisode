module SharedParams
  extend Grape::API::Helpers

  params :pagination do
    optional :page, type: Integer
    optional :per_page, type: Integer
  end
end


module API
  module V1
    class Root < Grape::API
      version 'v1'
      rescue_from ActiveRecord::RecordNotFound do |e|
        error!({ ru: "Такая запись не найдена", en: "This record does not exists" }, 404)
      end
      error_formatter :json, ::API::ErrorFormatter

      mount API::V1::Shows
      mount API::V1::Users
      mount API::V1::Subscriptions
      mount API::V1::Notifications
      
      add_swagger_documentation(
        api_version: "v1",
        base_path: '/api',
        hide_documentation_path: true,
        info: {
          title: 'Appisode',
          description: 'API'
        }
      )
    end
  end
end
