
class ConnectionHandler

  def initialize(cache_store)
    @cache = cache_store
  end
  
  def handle_client(socket, closing_callback)
    socket.write('MESSAGE')
  end
end
