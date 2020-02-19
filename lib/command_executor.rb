require_relative './command_parsing_result.rb'

class CommandExecutor

  STORAGE_COMMANDS = %w[set add replace append prepend cas]
  RETRIEVAL_COMMANDS = %w[get gets]


  def initialize(cache_storage)
    @cache = cache_storage
  end

  def split_arguments(line)
    tokens = line.split(' ')
    command = tokens[0]
    
    if is_storage?(command)
      return generate_storage_args(tokens)
    elsif is_retrieval?(command)
      return generate_retrieval_args(tokens)
    else
      return CommandParsingResult.new(nil, true, 'Invalid command')
    end
  end

private

  def is_storage?(command)
    return STORAGE_COMMANDS.include?(command)
  end

  def is_retrieval?(command)
    return RETRIEVAL_COMMANDS.include?(command)
  end

  def generate_storage_args(tokens)
    if tokens.length > 6 || tokens.length < 5
      return CommandParsingResult.new(nil, true, 'Invalid number of arguments')
    end
    key = tokens[1]
    if !valid_key?(key)
      return CommandParsingResult.new(nil, true, 'Key is not valid')
    end
    flags = tokens[2]
    if !valid_flags?(flags)
      return CommandParsingResult.new(nil, true, 'Flags are not valid')
    end
    exp_time = tokens[3]
    if !valid_time?(exp_time)
      return CommandParsingResult.new(nil, true, 'Expiration time is not valid')
    end
    bytes = tokens[4]
    if !valid_bytes?(bytes)
      return CommandParsingResult.new(nil, true, 'Bytes specified are not valid')
    end

    noreply = tokens.length == 6 && tokens[5] == 'noreply'? true : false
    
    args = {command: tokens[0], key: key, exp_time: parse_exp_time(exp_time), bytes: Integer(bytes), noreply: noreply}
    return CommandParsingResult.new(args, false, nil)
  end

  def generate_retrieval_args(tokens)
    if tokens.length < 2
      return CommandParsingResult.new(nil, true, 'Invalid number of arguments')
    end
    args = {command: tokens[0], keys: tokens.drop(1)}
    return CommandParsingResult.new(args, false)
  end

  def valid_key?(key)
    return key.length <= 250 && (key =~ /[^[:print:]]/).nil?
  end

  def valid_flags?(flags)
    return is_unsigned_int(flags)
  end

  def valid_time?(exp_time)
    return is_integer?(exp_time) 
  end

  def valid_bytes?(bytes)
    return is_unsigned_int(bytes)
  end

  def is_unsigned_int(string)
    return is_integer?(string) && Integer(string) >= 0 
  end

  def is_integer?(string)
    /\A[-+]?\d+\z/ === string
  end

  def parse_exp_time(time)
    seconds = Integer(time)
    if seconds > 2592000
      secs_since_epoch = Time.now.to_i
      return seconds - secs_since_epoch
    end
    return seconds
  end

end