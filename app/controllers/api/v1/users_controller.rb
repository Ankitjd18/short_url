class Api::V1::UsersController < ApplicationController

  def create
    user = User.new(user_params.to_h)
    if user.save
      render json: user, status: 201
    else
      raise Exceptions::SavingError.new(user.errors)
    end
  rescue Exceptions::SavingError => e
    render json: {error: e}, status: 400
  end

  def login
    QueryHelper::ParameterValidationChecker.new(params, 'username', 'password').check_null
    user_password = params[:password]
    username = params[:username]
    # checks email and password to authenticate user
    if (user = User.find_by(username: username).try(:authenticate, user_password))
      res = Hash.new
      res['user_id'] = user.id
      res['token'] = user.generate_auth_token
      render json: res, status: 200
    else
      raise Exceptions::AuthenticationError.new("Invalid uid or password")
    end
  rescue Exceptions::WrongParameterError => e
    render json: {error: e}, status: 400
  rescue Exceptions::AuthenticationError => e
    render json: {error: e}, status: 401
  end

  private
  def user_params
    params.permit(:username, :password)
  end
end
