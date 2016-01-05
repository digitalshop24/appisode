require 'grape-swagger'
module API
  class Root < Grape::API
    prefix 'api'
    mount API::V1::Root
    add_swagger_documentation(
      base_path: "",
      api_version: "v1",
      hide_documentation_path: true
    )
  end
end
