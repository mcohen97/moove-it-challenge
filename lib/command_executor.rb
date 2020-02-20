require_relative './command_parsing_result.rb'

class CommandExecutor

  STORAGE_COMMANDS = %w[set add replace append prepend cas]
  RETRIEVAL_COMMANDS = %w[get gets]


  def initialize(cache_storage)
    @cache = cache_storage
  end

  def split_arguments(line)
    tokens = line.split("\s")
    command = tokens[0]
    
    if is_storage?(command)
      return generate_storage_args(tokens)
    elsif is_retrieval?(command)
      return generate_retrieval_args(tokens)
    else
      return CommandParsingResult.new(nil, true, 'Invalid command')
    end
  end

  def execute_storage(command, data)

  end

  def execute_retrieval(command)
  end
  
  def is_storage?(command)
    return STORAGE_COMMANDS.include?(command)
  end


private

  def is_retrieval?(command)
    return RETRIEVAL_COMMANDS.include?(command)
  end

  def generate_storage_args(tokens)

    if !valid_args_count?(tokens)
      return CommandParsingResult.new(nil, true, 'Invalid number of arguments')
    end
    
    key = tokens[1]
    flags = tokens[2]
    exp_time = tokens[3]
    bytes = tokens[4]
      
    if !valid_key?(key)
      return CommandParsingResult.new(nil, true, 'Key is not valid')
    elsif !valid_flags?(flags)
      return CommandParsingResult.new(nil, true, 'Flags are not valid')
    elsif !valid_time?(exp_time)
      return CommandParsingResult.new(nil, true, 'Expiration time is not valid')
    elsif !valid_bytes?(bytes)
      return CommandParsingResult.new(nil, true, 'Bytes specified are not valid')
    elsif is_cas?(tokens[0]) && !valid_cas_unique?(tokens)
      return CommandParsingResult.new(nil, true, 'Cas value is not valid')
    end

    noreply = contains_no_reply?(tokens)
    
    args = {command: tokens[0], key: key, flags: flags, exp_time: parse_exp_time(exp_time), bytes: Integer(bytes), noreply: noreply}

    if is_cas?(tokens[0])
      args[:cas_unique] = Integer(tokens[5])
    end

    return CommandParsingResult.new(args, false, nil)
  end

  def valid_args_count?(tokens)
    if tokens[0] == 'cas'
      valid = 6 <= tokens.length && tokens.length <= 7
    else 
      #cas command has different args, so it has to be evaluated separately
      valid = 5 <= tokens.length && tokens.length <= 6 
    end
    return valid
  end

  def is_cas?(command)
    return command == 'cas'
  end

  def valid_cas_unique?(tokens)
    return is_unsigned_int(tokens[5])
  end

  def contains_no_reply?(tokens)
    if tokens[0] == 'cas'
      return tokens.length == 7 && tokens[6] == 'noreply'
    else
      return tokens.length == 6 && tokens[5] == 'noreply'
    end
  end

  def generate_retrieval_args(tokens)
    if tokens.length < 2
      return CommandParsingResult.new(nil, true, 'Invalid number of arguments')
    end
    args = {command: tokens[0], keys: tokens.drop(1)}
    return CommandParsingResult.new(args, false, nil)
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