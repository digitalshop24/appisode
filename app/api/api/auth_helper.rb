module API
  module AuthHelper

    def authenticated
      !headers['Auth-Token'].to_s.empty? && @user = User.find_by_auth_token(headers['Auth-Token'])
    end

    def current_user
      @user
    end

    def sign_out
      current_user.update_column(:auth_token, nil)
      !!current_user
    end

    def language
      headers['Accept-Language'].split(/[\;\-]/).first || (@user.language if @user)
    end

  end
end
