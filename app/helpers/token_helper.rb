module TokenHelper
  require 'jwt'
  class << self

    # wrapper for JWT.encode
    # generates JWT with user_id and expiry_time as payload
    def jwt_encode(user_id, expiry_time, refresh = false)
      payload = Hash.new
      payload['user_id'] = user_id.to_s
      payload['expiry_time'] = expiry_time
      # only in case of refresh_token
      payload['refresh'] = refresh
      # encodes takes payload, secret_key, and signing algorithm as args
      JWT.encode(payload, Rails.application.credentials.dig(:secret_key_base), Rails.application.credentials.dig(:jwt_algorithm))
    end

    # method to decode a JWT
    def jwt_decode(token)
      # sample payload response
      # [{"user_id"=> < user_id >, "expiry_time"=> < timestamp >, "refresh"=> false}, {"alg"=> < algorithm >}]
      # payload is first element of the returned object
      JWT.decode(token, Rails.application.credentials.dig(:secret_key_base), Rails.application.credentials.dig(:jwt_algorithm)).first
    rescue JWT::DecodeError => e
      Rails.logger.error "JWT Error - #{e}"
      false
    end

    # method to check for a blacklisted token
    def check_blacklist(token)
      if $token_redis.get(token)
        Rails.logger.error "Blacklisted token received -- #{token}"
        raise Exceptions::AuthorizationError.new("token expired")
      end
    rescue Redis::CannotConnectError, Redis::ConnectionError, Redis::TimeoutError => e
      Rails.logger.error "Redis Error - #{e.as_json}"
    end

    # method to add unexpired token to a blacklist
    def add_blacklist(token, type)
      ttl = 86400
      $token_redis.set(token, type, options = {:ex => ttl})
    rescue Redis::CannotConnectError, Redis::ConnectionError, Redis::TimeoutError => e
      Rails.logger.error "Redis Error - #{e.as_json}"
    end
  end
end