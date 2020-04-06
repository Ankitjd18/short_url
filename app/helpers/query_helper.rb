module QueryHelper

	# check if parameters in a query are valid or not
	# else raise wrong parameter exception
	class ParameterValidationChecker
		def initialize(params, *parameters)
			@params = params
			@parameters = parameters
		end

		def check_null
			@parameters.each do |p|
				unless @params.has_key?(p) && !@params[p].nil?
					Rails.logger.error "#{p} param missing in request."
					raise Exceptions::WrongParameterError.new(p)
				end
				# empty check in case param is string
				if (@params[p].kind_of?(String) || @params[p].kind_of?(Array)) && @params[p].empty?
					Rails.logger.error "Missing value for param #{p}"
					raise Exceptions::WrongParameterError.new(p)
				end
			end
			true
		end
	end

end
