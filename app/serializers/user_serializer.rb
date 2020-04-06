class UserSerializer < ActiveModel::Serializer
	attributes :id, :username, :url_limit
end
