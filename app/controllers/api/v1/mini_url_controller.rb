class Api::V1::MiniUrlController < ApplicationController

  require 'uri'

  # to create new entry into mini url data base
  def create
    # decode url to remove duplicacy for url encoded and decoded values
    url = URI.decode(params[:url])
    # check if url already exists in db
    mini_url = MiniUrlHelper.check_existing_url(url, current_user)
    unless mini_url
      mini_url = MiniUrl.new
      mini_url.url = url
      mini_url.expiry = params[:expiry]
      mini_url.user = current_user if current_user
      # call method to generate unique code and save into db
      # raise exception in case of some error
      unless mini_url.generate_unique_code
        raise Exceptions::SavingError.new(mini_url.errors)
      end
    end
    render json: {mini_url: mini_url.url_code}, status: 201
  rescue Exceptions::SavingError => e
    render json: {error: e}, status: 400
  end

  # get full url from mini url
  def full_url
    mini_url = MiniUrl.find_by(url_code: params[:url_code])
    # raise not found exception for url code not present in db
    unless mini_url
      raise Exceptions::EmptyObjectError.new('Unable to find url for redirection.')
    end
    render location: mini_url.url, status: 307
    # increase redirect count and update after responding with actual url
    mini_url.redirect_count += 1
    unless mini_url.update
      logger.error "Some error in updating redirect count for mini url - #{mini_url.url_code}"
    end
  rescue Exceptions::EmptyObjectError => e
    render json: {error: e}, status: 404
  end

end
