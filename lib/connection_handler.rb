require_relative './command_executor.rb'

class ConnectionHandler
  
  def initialize(cache_store)
    @executor = CommandExecutor.new(cache_store)
  end
  
  def handle_client(socket, closing_callback)
    while line = socket.gets
      process_line(socket, line)
    end
  end

private

  def process_line(socket, line)
    return @executor.execute_command(line, method(:get_data))
  end

  def get_data(socket, length)
    return socket.recv(length)
  end
end
