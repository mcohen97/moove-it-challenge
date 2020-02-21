require 'socket'  
streamSock = TCPSocket.new( "127.0.0.1", 5001 )  

puts 'TYPE X TO EXIT, OTHERWISE TYPE MESSAGE:'
message = gets
while message != 'X'
  streamSock.puts(message)
  puts 'WAITING FOR RESPONSE'
  server_message = streamSock.gets
  print server_message
  puts 'NEXT MESSAGE:'
  message = gets
end

streamSock.close