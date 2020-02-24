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

  trap "SIGINT" do
    puts 'Closing all connections'
    close_all_connections()
    exit 130
  end

  def listen_to_requests()
    listener = TCPServer.new('localhost', @port)
    @cache.start_purge
    handler = ConnectionHandler.new(@cache)
    worker_pool = Concurrent::FixedThreadPool.new(MAX_THREADS)
    
    puts 'LISTENING TO REQUESTS...' 
    
    while @server_running
      begin
        accept_next_connection(listener, worker_pool, handler)
      rescue Errno=> e
        # couln't connect with a client, continue.
        next
      end
    end
  end

  def accept_next_connection(listener, worker_pool, handler)
    new_connection = listener.accept

    worker_pool.post do
      handler.handle_client(new_connection, method(:remove_connection))
    end

    @connections << new_connection
    puts @connections.length
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