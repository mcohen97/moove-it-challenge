require_relative 'cache_imp.rb'
require_relative 'server.rb'

class MyMemcached

  def initialize(args)
    @cache = CacheImp.new()
    @server = Server.new(@cache, args[:port])
  end
  
  def run()
    @server.listen_to_requests()
  end

end

my_cache = MyMemcached.new(port: 5001)
my_cache.run()

