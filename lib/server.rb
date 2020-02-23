require 'socket'
require 'concurrent-ruby'
require_relative 'connection_handler.rb'

class Server

  MAX_THREADS = 10

  def initialize(cache, port)
    @cache = cache
    @port = port
    @server_running = true
    @connections = []
    puts 'SERVER RUNNING'
  end

  def listen_to_requests()
    listener = TCPServer.new('localhost', @port)
    @cache.start_purge
    handler = ConnectionHandler.new(@cache)
    worker_pool = Concurrent::FixedThreadPool.new(10)
    
    puts 'LISTENING TO REQUESTS...' 
    
    while @server_running
      new_connection = listener.accept

      worker_pool.post do
        handler.handle_client(new_connection, method(:remove_connection))
      end

      @connections << new_connection
      puts @connections.length
    end
  end

  def remove_connection(socket)
    puts 'REMOVING SOCKET'
    socket.close
    @connections.delete(socket)
  end

  def close_all_connections()
    @connections.each do |c|
      c.close
    end
    @connections.clear
  end

end