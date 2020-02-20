require "test/unit"
require_relative '../lib/command_executor.rb'
require_relative '../lib/cache_imp.rb'
 
class CommandExecutorTest < Test::Unit::TestCase
 
  def setup
    @cache = CacheImp.new
    @executor = CommandExecutor.new(@cache)
  end
  # using set as the example to test storage commands
  def test_correct_set_command
    command = 'set key 0 0 4'
    result = @executor.split_arguments(command)
    
    assert_true result.success
    assert_equal 6, result.command_args.length
    assert_false result.command_args[:noreply]
  end

  def test_correct_set_command_with_noreply
    command = 'set key 0 0 4 noreply'
    result = @executor.split_arguments(command)
    
    assert_true result.success
    assert_equal 6, result.command_args.length
    assert_true result.command_args[:noreply]
  end

  def test_set_too_many_args
    command = 'set key 0 0 4 55 23'
    result = @executor.split_arguments(command)
    
    assert_false result.success
    assert_equal 'Invalid number of arguments', result.error_message
  end

  def test_set_too_few_args
    command = 'set key 0 0'
    result = @executor.split_arguments(command)
    
    assert_false result.success
    assert_equal 'Invalid number of arguments', result.error_message
  end

  def test_correct_cas_command
    command = 'cas key 0 0 4 22'
    result = @executor.split_arguments(command)
    
    assert_true result.success
    assert_equal 7, result.command_args.length
  end

  def test_correct_cas_command_with_noreply
    command = 'cas key 0 0 4 22 noreply'
    result = @executor.split_arguments(command)
    
    assert_true result.success
    assert_equal 7, result.command_args.length
    assert_true result.command_args[:noreply]
  end

  def test_cas_invalid_args_count
    command = 'cas key 0 0 4 22 55 86'
    result = @executor.split_arguments(command)
    
    assert_false result.success
    assert_equal 'Invalid number of arguments', result.error_message
  end

  def test_unknown_command
    command = 'unknown 22'
    result = @executor.split_arguments(command)

    assert_false result.success
    assert_equal 'Invalid command', result.error_message
  end

  def test_too_long_key
    str = "a" * 251
    command = "set #{str} 0 0 4"
    result = @executor.split_arguments(command)

    assert_false result.success
    assert_equal 'Key is not valid', result.error_message
  end

  def test_key_with_control_characters
    command = "set ke\0y 0 0 4"
    result = @executor.split_arguments(command)
    
    assert_false result.success
    assert_equal 'Key is not valid', result.error_message
  end

  def test_non_numerical_flags
    command = 'set key flags 0 4'
    result = @executor.split_arguments(command)

    assert_false result.success
    assert_equal 'Flags are not valid', result.error_message
  end

  def test_negative_flags
    command = 'set key -10 0 4'
    result = @executor.split_arguments(command)

    assert_false result.success
    assert_equal 'Flags are not valid', result.error_message
  end

  def test_non_numerical_exp_time
    command = 'set key 0 exp_time 4'
    result = @executor.split_arguments(command)

    assert_false result.success
    assert_equal 'Expiration time is not valid', result.error_message
  end
 
  def test_exp_time_conversion
    exp_time = Time.now.to_i + 60
    command = "set key 0 #{exp_time} 4"
    result = @executor.split_arguments(command)

    assert_in_delta 60, result.command_args[:exp_time], 1
  end

  def test_non_numerical_bytes
    command = 'set key 0 0 bytes'
    result = @executor.split_arguments(command)

    assert_false result.success
    assert_equal 'Bytes specified are not valid', result.error_message
  end

  def test_negative_bytes
    command = 'set key 0 0 -5'
    result = @executor.split_arguments(command)

    assert_false result.success
    assert_equal 'Bytes specified are not valid', result.error_message
  end

  def test_non_numerical_cas_unique
    command = 'cas key 0 0 4 cas_unique'
    result = @executor.split_arguments(command)
    
    assert_false result.success
    assert_equal 'Cas value is not valid', result.error_message
  end

  def test_negative_cas_unique
    command = 'cas key 0 0 4 -10'
    result = @executor.split_arguments(command)
    
    assert_false result.success
    assert_equal 'Cas value is not valid', result.error_message
  end

  def test_invalid_noreply
    command = 'set key 0 0 4 invalid'
    result = @executor.split_arguments(command)
    
    assert_true result.success
    assert_false result.command_args[:noreply]
  end

  def test_correct_get_command
    command = 'get key1 key2'
    result = @executor.split_arguments(command)

    assert_true result.success
    assert_equal 2, result.command_args.length
    assert_equal 2, result.command_args[:keys].length
  end

  def test_get_invalid_args_count
    command = 'get'
    result = @executor.split_arguments(command)

    assert_false result.success
    assert_equal 'Invalid number of arguments', result.error_message
  end

end