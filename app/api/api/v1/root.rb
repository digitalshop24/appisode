module API
  module V1
    class Root < Grape::API
      mount API::V1::Shows
      mount API::V1::Users
      mount API::V1::Subscriptions
    end
  end
end
