class Api::V1::MiniUrlController < ApplicationController

  require 'uri'
  before_action :authenticate_user, only: [:url_list, :remove]

  # to create new entry into mini url data base
  def create
    # decode url to remove duplicacy in case of same url encoded and decoded
    url = URI.decode(params[:url])
    # check if url already exists in db
    mini_url = MiniUrlHelper.check_existing_url(url, current_user)
    unless mini_url
      mini_url = MiniUrl.new
      mini_url.url = url
      # a check to handle invalid expiry time
      begin
        mini_url.expiry = DateTime.parse(params[:expiry])
      rescue ArgumentError => e
        logger.error "Invalid expiry time."
      end
      mini_url.user = current_user if current_user
      # call method to generate unique code and save into db
      # raise exception in case of some error
      unless mini_url.generate_unique_code
        raise Exceptions::SavingError.new(mini_url.errors)
      end
    end
    short_url = "#{BASE_URL}/#{mini_url.url_code}"
    render json: {short_url: short_url}, status: 201
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

  # return all the urls for the user
  def url_list
    urls = current_user.mini_urls
    if urls.count > 0
      render json: {urls: urls}, status: 200
    else
      raise Exceptions::EmptyObjectError.new('No URL found.')
    end
  rescue Exceptions::EmptyObjectError => e
    render json: {error: e}, status: 404
  end

  def remove
    # find mini url using either id or url code.
    # raise exception if none of the above present in request
    if params[:id]
      mini_url = current_user.mini_urls.find_by(id: params[:id])
    elsif params[:url_code]
      mini_url = current_user.mini_urls.find_by(url_code: params[:url_code])
    else
      raise Exceptions::WrongParameterError.new('id or url_code')
    end
    # remove the url from db
    if mini_url.remove
      render json: {msg: 'Successfully expired.'}, status: 200
    else
      raise Exceptions::SavingError.new(mini_url.errors)
    end
  rescue Exceptions::WrongParameterError, Exceptions::SavingError => e
    render json: {error: e}, status: 400
  end

end
