require 'socket'  

def get_multi_line(socket)
  total_message = StringIO.new
  partial_message = socket.gets
  
  while !partial_message.start_with?("END")
    total_message << partial_message
    partial_message = socket.gets
  end
  total_message << partial_message
  return total_message.string
end

prompt_message = 'TYPE COMMAND (X to exit)'

streamSock = TCPSocket.new( "127.0.0.1", 5001 )  

puts prompt_message

message = gets
while message != 'X'
  streamSock.puts(message)
  if message.start_with?('get')
    server_message = get_multi_line(streamSock)
  else  
    server_message = streamSock.gets
  end
  puts '----------------------------------------'
  print server_message
  puts '----------------------------------------'
  puts prompt_message
  message = gets
end

streamSock.close