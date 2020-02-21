require_relative './command_executor.rb'

class ConnectionHandler
  
  def initialize(cache_store)
    @executor = CommandExecutor.new(cache_store)
  end
  
  def handle_client(socket, closing_callback)
    puts 'HANDLING CLIENT'
    while line = socket.gets
      puts "the line: #{line}"
      response = process_line(socket, line)
      puts "RESPONSE: #{response}"
      socket.puts(response)
      puts 'WAITING FOR NEXT MESSAGE'
    end
  end

private

  def process_line(socket, line)
    parsed_command = @executor.split_arguments(line)
    command_args = parsed_command.command_args
    if @executor.is_storage?(command_args[:command])
      puts 'Storage command, we need to fetch data'
      socket.puts('SEND DATA')
      data = get_data(socket, command_args[:bytes])
      return @executor.execute_storage(command_args, data)
    end
    return @executor.execute_retrieval(command_args)
  end

  def get_data(socket, length)
    puts length
    data =  socket.recv(length + 2)
    puts 'DATA RECEIVED'
    return data
  end
end
