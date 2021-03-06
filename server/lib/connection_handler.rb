# frozen_string_literal: true

require_relative './command_executor.rb'

class ConnectionHandler
  def initialize(cache_store)
    @executor = CommandExecutor.new(cache_store)
  end

  def handle_client(socket, closing_callback)
    while line = socket.gets
      response = process_line(socket, line)
      socket.puts(response) unless response.nil?
    end
    closing_callback.call(socket)
  rescue Errno, StandardError => e
    closing_callback.call(socket)
  end

  private

  def process_line(socket, line)
    command_data = line.chomp.split('\r\n')
    parsed_command = @executor.split_arguments(command_data[0])
    return parsed_command.error_message unless parsed_command.success

    command_args = parsed_command.command_args
    if @executor.is_storage?(command_args[:command])
      data = if command_data.length >= 2
               command_data[1]
             else
               socket.puts('SEND DATA')
               get_data(socket, command_args[:bytes])
             end
      result = @executor.execute_storage(command_args, data)
      return command_args[:noreply] ? nil : result
    end
    @executor.execute_retrieval(command_args)
  end

  def get_data(socket, length)
    data = socket.recv(length + 2)
    data[0..-2] # remove last control characters \r\n
  end
end
