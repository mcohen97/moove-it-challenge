# frozen_string_literal: true

class CommandParsingResult
  attr_reader :success, :error_message, :command_args

  def initialize(args, error, error_message)
    @success = !error
    @error_message = error_message
    @command_args = args
  end
end
