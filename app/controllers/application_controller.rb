class ApplicationController < ActionController::API
  rescue_from Exceptions::AuthorizationError, with: :unauthorized_error
  rescue_from Exceptions::InvalidHeaderError, Exceptions::EmptyObjectError, Exceptions::WrongHeaderError, with: :invalid_exceptions
  rescue_from Exceptions::AuthenticationError, with: :authenticated_exception

  after_action :set_access_control_headers

  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
  end

  protected
  # user authentication for actions
  def authenticate_user
    if current_user
      true
    else
      raise Exceptions::AuthorizationError.new('invalid user authorization')
    end
  end

  def current_user
    if request.headers['Authorization'].present?
      # decode access_token
      payload = TokenHelper.jwt_decode(request.headers['Authorization'])
      # checks for payload
      unless payload
        raise Exceptions::InvalidHeaderError.new("Authorization")
      end
      @user = User.find(payload['user_id']) unless @user
      # return user if it is present
      if @user
        @user
      else
        raise Exceptions::EmptyObjectError.new("user cannot be found")
      end
    end
  end

  # catches AuthenticationError
  def authenticated_exception(exception)
    logger.error "IAuthentication failed - #{request.headers['Authorization']}"
    render json: {error: exception}, status: 307, scope: nil
  end

  # catches InvalidHeaderError, EmptyObjectError, WrongHeaderError
  def invalid_exceptions(exception)
    render json: {error: exception}, status: 401, scope: nil
  end

  def unauthorized_error(exception)
    logger.error "Invalid authorization - #{request.headers['Authorization']}"
    render json: {error: exception}, status: 403, scope: nil
  end

end
