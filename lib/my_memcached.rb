require_relative 'cache_imp.rb'
require_relative 'server.rb'

require 'dotenv'
Dotenv.load

class MyMemcached

  def initialize(args)
    @cache = CacheImp.new()
    @server = Server.new(@cache, args[:port])
  end
  
  def run()
    @server.listen_to_requests()
  end

end

port = ENV["PORT"].to_i || 5000
my_cache = MyMemcached.new(port: port)
my_cache.run()

