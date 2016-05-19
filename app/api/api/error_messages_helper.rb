module API
  module ErrorMessagesHelper
    def error_message sym
      hash = {
        auth: { ru: "Вы не авторизированы", en: "You are not authorized" },
        wrong_params: { ru: "Неверные параметры", en: "Wrong params" }
        # invalid_change_password: { ru: "Неверный текущий пароль", en: "Invalid password" },
        # email_not_found: { ru: "Пользователь с таким email не найден", en: "User with this email not found" },
        # invalid_password: { ru: "Неверный пароль", en: "Invalid password" },
        # something_wrong: { ru: "Что-то пошло не так :(", en: "Something went wrong :(" },
        # wrong_permissions: { ru: "У вас недостаточно прав для данного действия", en: "Permission denied for this action" }
      }
      hash[sym]
    end

    def eng_format_errors hash
      res = []
      hash.each{ |key, value| res << "#{key}: #{value}" }
      res = res.join('; ')
      { ru: res, en: res }
    end
  end
end
