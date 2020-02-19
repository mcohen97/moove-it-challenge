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
    
    assert_true result.success
    assert_equal 5, result.command_args.length
  end

  def test_unknown_command
    command = 'unknown 22'
    result = @executor.split_arguments(command)

    assert_false result.success
  end

  def test_too_long_key
    str = "a" * 251
    command = 'set ' + str + ' 0 0 4'
    result = @executor.split_arguments(command)

    assert_false result.success
  end

  def test_key_with_control_characters
    command = "set ke\ry 0 0 4"
    result = @executor.split_arguments(command)
    
    assert_false result.success
  end
 
end