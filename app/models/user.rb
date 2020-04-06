class User
  include Mongoid::Document
  include ActiveModel::SecurePassword

  field :username, type: String
  field :password_digest
  field :url_limit, type: Integer, default: DEFAULT_URL_LIMIT

  has_many :mini_urls

  validates :username, uniqueness: true, presence: true

  index({username: 1}, {name: 'username_index'})

  has_secure_password

  # generates access_token and refresh token
  def generate_auth_token
    # expiry of access token is 60 minutes
    # expiry of refresh token is 24 hrs
    access_expiry_timestamp = DateTime.now + 60.minute
    refresh_expiry_timestamp = DateTime.now + 1.day
    # generates JWT with user_id and expiry_time as payload
    # true is for refresh field
    tokens = Hash.new
    tokens['access'] = Hash.new
    tokens['access']['token'] = TokenHelper.jwt_encode(self._id, access_expiry_timestamp, false)
    tokens['access']['expiry_time'] = access_expiry_timestamp
    tokens['refresh'] = Hash.new
    tokens['refresh']['token'] = TokenHelper.jwt_encode(self._id, refresh_expiry_timestamp, true)
    tokens['refresh']['expiry_time'] = refresh_expiry_timestamp
    tokens
  end
end
