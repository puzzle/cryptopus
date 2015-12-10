module SearchesHelper
  def username
    username = current_user.givenname
    " " +  username if username.present?
  end
end
