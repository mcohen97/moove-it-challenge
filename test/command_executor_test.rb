require "test/unit"
require_relative '../lib/command_executor.rb'
require_relative '../lib/cache_implementation.rb'
 
class CommandExecutorTest < Test::Unit::TestCase
 
  def setup
    @cache = CacheImplementation.new
    @executor = CommandExecutor.new(@cache)
  end

  def test_correct_storage_command
    command = 'set key 0 0 4'
    result = @executor.split_arguments(command)
    puts result.error_message
    assert_true result.success
  end
 
end