module MiniUrlHelper
  class << self

    def check_existing_url(url, user)
      if user
        mini_url = MiniUrl.find_by(url: url, user_id: user.id)
      else
        mini_url = MiniUrl.find_by(url: url)
      end
      mini_url
    end
  end
end