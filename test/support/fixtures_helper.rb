class FixturesHelper
  class << self
    def read_public_key(user)
      filepath = "users/#{user}/public.key"
      read_file(filepath)
    end

    def read_private_key(user)
      filepath = "users/#{user}/private.key"
      read_file(filepath)
    end

    def read_team_password(user, team)
      filepath = "users/#{user}/#{team}_password.crypt"
      read_file(filepath)
    end

    def read_account_username(team, account)
      filepath = "teams/#{team}/#{account}/username.crypt"
      read_file(filepath)
    end

    def read_account_password(team, account)
      filepath = "teams/#{team}/#{account}/password.crypt"
      read_file(filepath)
    end

    private
    def read_file(filepath)
      path = "#{Rails.root}/test/fixtures/files/#{filepath}"
      Base64.strict_encode64(File.open(path, 'rb') { |f| f.read })
    end
  end
end