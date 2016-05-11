module API
  module ErrorFormatter
    def self.call message, backtrace, options, env
      { status: 'error', message: message[:ru], en_message: message[:en] }.to_json
    end
  end
end
