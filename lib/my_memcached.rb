require_relative 'cache_implementation.rb'
require_relative 'server.rb'

class MyMemcached

  def initialize(args)
    @cache = CacheImplementation.new()
    @server = Server.new(@cache, args[:port])
  end
  
  def run()
    @server.listen_to_requests()
  end

end

my_cache = MyMemcached.new(port: 5000)
my_cache.run()

