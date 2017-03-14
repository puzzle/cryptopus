module User::Authentication

  def authenticate(username, cleartext_password)
    return false if locked?
    if ldap?
      return authenticate_ldap(username, cleartext_password)
    else
      return authenticate_db(cleartext_password)
    end
    false
  end

  private
  def authenticate_ldap(username, cleartext_password)
    LdapTools.ldap_login(username, cleartext_password)
  end

  def authenticate_db(cleartext_password)
    salt = password.split('$')[1]
    password.split('$')[2] == Digest::SHA512.hexdigest(salt+cleartext_password)
  end
end
