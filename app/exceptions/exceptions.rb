module Exceptions
	class EmptyObjectError < StandardError;
	end
	class DuplicateEntry < StandardError;
	end
	class SavingError < StandardError;
		def initialize(object)
			e = ""
			object.each do |key, value|
				e += "#{key} #{value},"
			end
			e.chomp(',')
			super(e)
		end
	end
	class WrongIdCombination < StandardError;
	end
	class WrongParameterError < ActionController::ParameterMissing;
		def initialize(param_name)
			super("Missing #{param_name}")
		end
	end
	class WrongHeaderError < StandardError
		def initialize(header_name)
			super("Missing header #{header_name}")
		end
	end
  class InvalidParameterError < StandardError
		def initialize(param_name)
			super("invalid #{param_name}")
		end
	end
	class InvalidHeaderError < StandardError
		def initialize(header_name)
			super("invalid #{header_name}")
		end
	end

  class AuthenticationError < StandardError
		def initialize(error)
			super("#{error}")
		end
	end
	class AuthorizationError < StandardError
		def initialize(error)
			super("#{error}")
		end
	end

end