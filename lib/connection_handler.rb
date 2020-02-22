require_relative './command_executor.rb'

class ConnectionHandler
  
  def initialize(cache_store)
    @executor = CommandExecutor.new(cache_store)
  end
  
  def handle_client(socket, closing_callback)
    puts 'HANDLING CLIENT'
    while line = socket.gets
      response = process_line(socket, line)
      puts "RESPONSE: #{response}"
      socket.puts(response)
      puts 'WAITING FOR NEXT MESSAGE'
    end
  end

private

  def process_line(socket, line)
    command_data = line.chomp.split('\r\n')
    puts "the line: #{command_data.inspect}"
    parsed_command = @executor.split_arguments(command_data[0])
    if !parsed_command.success
      return parsed_command.error_message
    end
    command_args = parsed_command.command_args
    if @executor.is_storage?(command_args[:command])
      if command_data.length >=2
        data = command_data[1]
      else
        #socket.puts('SEND DATA')
        data = get_data(socket, command_args[:bytes])
      end
      return @executor.execute_storage(command_args, data)
    end
    return @executor.execute_retrieval(command_args)
  end

  def get_data(socket, length)
    puts length
    data =  socket.recv(length+2)
    puts data
    puts 'DATA RECEIVED'
    return data[0 .. -2] # remove last control characters \r\n
  end
end
