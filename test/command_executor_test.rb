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

  def test_execute_set_correctly
    command = 'set key 0 0 4'
    parsed_result = @executor.split_arguments(command)
    
    message = @executor.execute_storage(parsed_result.command_args, 'Data')

    assert_equal 'STORED', message
  end

  def test_execute_add_correctly
    command = 'add key 0 0 4'
    parsed_result = @executor.split_arguments(command)
    
    message = @executor.execute_storage(parsed_result.command_args, 'Data')

    assert_equal 'STORED', message
  end

  def test_execute_add_already_existing
    @cache.set('Key','Data1', 0, 0)

    command = 'add Key 0 0 4'
    parsed_result = @executor.split_arguments(command)
    message = @executor.execute_storage(parsed_result.command_args, 'Data')

    assert_equal 'NOT_STORED', message
  end

  def test_execute_replace_correctly
    @cache.set('Key1','Data1', 0, 0)

    command = 'replace Key1 0 0 4'
    parsed_result = @executor.split_arguments(command)
    message = @executor.execute_storage(parsed_result.command_args, 'Data2')

    assert_equal 'STORED', message
  end

  def test_execute_replace_non_existing
    command = 'replace key 0 0 4'
    parsed_result = @executor.split_arguments(command)
    message = @executor.execute_storage(parsed_result.command_args, 'Data2')

    assert_equal 'NOT_STORED', message
  end

  def test_execute_append_correctly
    @cache.set('Key1','Data1', 0, 0)

    command = 'append Key1 0 0 4'
    parsed_result = @executor.split_arguments(command)
    message = @executor.execute_storage(parsed_result.command_args, 'Data2')

    assert_equal 'STORED', message
  end

  def test_execute_append_to_non_existing
    command = 'append key 0 0 4'
    parsed_result = @executor.split_arguments(command)
    message = @executor.execute_storage(parsed_result.command_args, 'Data2')

    assert_equal 'NOT_STORED', message
  end

  def test_execute_prepend_correctly
    @cache.set('Key1','Data1', 0, 0)

    command = 'prepend Key1 0 0 4'
    parsed_result = @executor.split_arguments(command)
    message = @executor.execute_storage(parsed_result.command_args, 'Data2')

    assert_equal 'STORED', message
  end

  def test_execute_prepend_to_non_existing
    command = 'prepend key 0 0 4'
    parsed_result = @executor.split_arguments(command)
    message = @executor.execute_storage(parsed_result.command_args, 'Data2')

    assert_equal 'NOT_STORED', message
  end

  def test_execute_cas_non_updated
    result = @cache.set('Key1','Data1', 0, 0)
    cas = result.entry.cas_unique

    command = "cas Key1 0 0 4 #{cas}" #2^32 is known to be the first cas unique generated
    parsed_result = @executor.split_arguments(command)
    message = @executor.execute_storage(parsed_result.command_args, 'Data2')

    assert_equal 'STORED', message
  end

  def test_execute_cas_already_updated
    result = @cache.set('Key1','Data1', 0, 0)
    old_cas = result.entry.cas_unique
    @cache.set('Key1','Data1', 0, 0)


    command = "cas Key1 0 0 4 #{old_cas}" # current cas is 1 more, since it's been updated
    parsed_result = @executor.split_arguments(command)
    message = @executor.execute_storage(parsed_result.command_args, 'Data2')

    assert_equal 'EXISTS', message
  end

  def test_execute_cas_non_existing
    command = "cas key 0 0 4 15" 
    parsed_result = @executor.split_arguments(command)
    message = @executor.execute_storage(parsed_result.command_args, 'Data2')

    assert_equal 'NOT_FOUND', message
  end

  def test_get_multiple
    @cache.set('Key1','Data1', 0, 0)
    @cache.set('Key2','Data2', 0, 0)

    command = 'get Key1 Key2'
    parsed_result = @executor.split_arguments(command)
    message = @executor.execute_retrieval(parsed_result.command_args)
    expected_message = "VALUE Key1 0 5\nData1\nVALUE Key2 0 5\nData2\nEND"

    assert_equal expected_message, message
  end

  def test_get_empty
    command = 'get Key1 Key2'
    parsed_result = @executor.split_arguments(command)
    message = @executor.execute_retrieval(parsed_result.command_args)
    expected_message = "END"

    assert_equal expected_message, message
  end

  def test_gets_multiple
    result1 = @cache.set('Key1','Data1', 0, 0)
    cas1 = result1.entry.cas_unique
    result2 = @cache.set('Key2','Data2', 0, 0)
    cas2 = result2.entry.cas_unique

    command = 'gets Key1 Key2'
    parsed_result = @executor.split_arguments(command)
    message = @executor.execute_retrieval(parsed_result.command_args)
    expected_message = "VALUE Key1 0 5 #{cas1}\nData1\nVALUE Key2 0 5 #{cas2}\nData2\nEND"

    assert_equal expected_message, message
  end

  def test_get_expired
    @cache.set('Key1','Data1', 0, -1)
    @cache.set('Key2','Data2', 0, 1)

    sleep(2)

    command = 'get Key1 Key2'
    parsed_result = @executor.split_arguments(command)
    message = @executor.execute_retrieval(parsed_result.command_args)
    expected_message = "END"
  end

end