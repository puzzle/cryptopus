module Flash

  class LastLoginMessage

    delegate :t, :l, to: I18n

    def initialize(session)
      @session = session
    end

    def message
      return unless last_login_at

      @translation_key = :last_login_date
      @date_ip_country_values = { last_login_at: format_last_login_at }

      add_last_login_from

      t(translation_key, date_ip_country_values)
    end

    private

    attr_reader :session, :translation_key, :date_ip_country_values

    def add_last_login_from
      if last_login_from
        date_ip_country_values[:last_login_from] = last_login_from
        @translation_key = :last_login_date_and_from
      end
    end

    def format_last_login_at
      l(last_login_at, format: :long) if last_login_at
    end

    def last_login_at
      session[:last_login_at]
    end

    def last_login_from
      session[:last_login_from]
    end
  end
end
