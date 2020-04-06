
# Global variable of redis for use in project
$redis = Redis.new(host: "127.0.0.1", port: 6379)
$token_redis = Redis.new(host: "127.0.0.1", port: 6379, db: 3)
$buffer_token_redis = Redis.new(host: '127.0.0.1', port: 6379, db: 2)
