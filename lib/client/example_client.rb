# frozen_string_literal: true

require 'socket'

def get_multi_line(socket)
  total_message = StringIO.new
  partial_message = socket.gets

  while !partial_message.start_with?('END') && !partial_message.start_with?('ERROR') && !partial_message.start_with?('CLIENT_ERROR')
    total_message << partial_message
    partial_message = socket.gets
  end
  total_message << partial_message
  total_message.string
end

prompt_message = 'TYPE COMMAND (X to exit)'

streamSock = TCPSocket.new('127.0.0.1', 5005)

puts prompt_message

message = gets
while message != 'X'
  streamSock.print(message)
  server_message = if message.start_with?('get')
                     get_multi_line(streamSock)
                   else
                     streamSock.gets
                   end
  puts '----------------------------------------'
  print server_message
  puts '----------------------------------------'
  puts prompt_message
  message = gets
end

streamSock.close
