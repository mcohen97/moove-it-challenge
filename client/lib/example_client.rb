# frozen_string_literal: true

require 'socket'
require 'dotenv'

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

Dotenv.load
prompt_message = 'TYPE COMMAND (X to exit)'

ip = ENV["IP_ADDRESS"].to_s.empty? ? '127.0.0.1' : ENV["IP_ADDRESS"].to_s
port = ENV["PORT"].to_i.zero? ? 5000 : ENV["PORT"].to_i
streamSock = TCPSocket.new(ip, port)

puts prompt_message

message = gets
while message != 'X'
  streamSock.print(message)
  server_message = if message.start_with?('get')
                     get_multi_line(streamSock)
                   elsif !message.chomp.split('\r\n')[0].end_with?('noreply')
                     streamSock.gets
                   end
  puts '----------------------------------------'
  print server_message
  puts '----------------------------------------'
  puts prompt_message
  message = gets
end

streamSock.close
