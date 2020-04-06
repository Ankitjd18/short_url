class Api::V1::SessionsController < ApplicationController

  def login
    # check if username and password present in request
    QueryHelper::ParameterValidationChecker.new(params, 'username', 'password').check_null
    user_password = params[:password]
    username = params[:username]
    # checks username and password to authenticate user
    if (user = User.find_by(username: username).try(:authenticate, user_password))
      res = user.generate_auth_token
      render json: res, status: 200
    else
      raise Exceptions::AuthenticationError.new("Invalid uid or password")
    end
  rescue Exceptions::WrongParameterError => e
    render json: {error: e}, status: 400
  rescue Exceptions::AuthenticationError => e
    render json: {error: e}, status: 401
  end

  # method to refresh token expiry
  # generate new tokens with extended expiry_time
  def refresh_token
    QueryHelper::HeaderValidationChecker.new(request.headers, 'RefreshToken', 'Authorization').check_null_headers
    TokenHelper.check_blacklist(request.headers['RefreshToken'])
    # access token validation check
    payload = TokenHelper.jwt_decode(request.headers['Authorization'])
    unless payload && !payload['refresh']
      raise Exceptions::AuthenticationError.new("invalid access_token")
    end
    # refresh_token validation and expiry check
    payload = TokenHelper.jwt_decode(request.headers['RefreshToken'])
    unless payload && payload['refresh'] && payload['expiry_time'] > Time.now
      raise Exceptions::AuthenticationError.new("invalid refresh_token")
    end
    # user validation
    user = User.find(payload['user_id'])
    unless user
      Rails.logger.error "no user found with the given user_id -- #{payload['user_id']}"
      raise Exceptions::AuthenticationError.new("invalid token")
    end
    res = user.generate_auth_token
    # Adding both the tokens to blacklist in redis, disabling its use again
    TokenHelper.add_blacklist(request.headers['Authorization'],"access")
    TokenHelper.add_blacklist(request.headers['RefreshToken'],"refresh")
    render json: res, status: 200, scope: nil
  rescue Exceptions::AuthenticationError, Exceptions::InvalidHeaderError, Exceptions::WrongHeaderError, JWT::DecodeError, JWT::VerificationError => e
    render json: {error: e}, status: 401, scope: nil
  end

  def destroy
    # Check if both tokens present in request
    QueryHelper::HeaderValidationChecker.new(request.headers, 'Authorization', 'RefreshToken').check_null_headers
    # Add both the token to blacklist, disabling its use again
    TokenHelper.add_blacklist(request.headers['Authorization'],"access")
    TokenHelper.add_blacklist(request.headers['RefreshToken'],"refresh")
    render json: {message: "Successfully logged out!!"}, status: 200, scope: nil
  rescue Exceptions::AuthenticationError, Exceptions::WrongHeaderError => e
    render json: {error: e}, status: 400, scope: nil
  rescue JWT::DecodeError, JWT::VerificationError => e
    render json:{error: e}, status: 401, scope: nil
  end
end
