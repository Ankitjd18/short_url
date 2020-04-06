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

  private
  def user_params
    params.permit(:username, :password)
  end
end
