module API
  module ErrorFormatter
    def self.call message, backtrace, options, env
    	puts backtrace
    	message = { en: message } if message.is_a?(String)
      { status: 'error', message: message[:ru], en_message: message[:en] }.to_json
    end
  end
end
