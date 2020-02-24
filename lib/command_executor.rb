# frozen_string_literal: true

require_relative './command_parsing_result.rb'

class CommandExecutor
  STORAGE_COMMANDS = %w[set add replace append prepend cas].freeze
  RETRIEVAL_COMMANDS = %w[get gets].freeze

  CLIENT_ERROR = 'CLIENT_ERROR'
  NON_EXISTENT_COMMAND_NAME = 'ERROR'

  def initialize(cache_storage)
    @cache = cache_storage
  end

  def split_arguments(command_line)
    tokens = command_line.split("\s")
    command = tokens[0]

    if is_storage?(command)
      return generate_storage_args(tokens)
    elsif is_retrieval?(command)
      return generate_retrieval_args(tokens)
    else
      return CommandParsingResult.new(nil, true, "#{NON_EXISTENT_COMMAND_NAME} Invalid command.")
    end
  end

  def execute_storage(command_args, data)
    if data.length != command_args[:bytes]
      return "#{CLIENT_ERROR} Bad data chunk."
    end

    command = command_args[:command]
    case command
    when 'set'
      result = @cache.set(command_args[:key], data, command_args[:flags], command_args[:exp_time])
    when 'add'
      result = @cache.add(command_args[:key], data, command_args[:flags], command_args[:exp_time])
    when 'replace'
      result = @cache.replace(command_args[:key], data, command_args[:flags], command_args[:exp_time])
    when 'append'
      result = @cache.append(command_args[:key], data, command_args[:flags], command_args[:exp_time])
    when 'prepend'
      result = @cache.prepend(command_args[:key], data, command_args[:flags], command_args[:exp_time])
    when 'cas'
      result = @cache.cas(command_args[:key], data, command_args[:flags], command_args[:exp_time], command_args[:cas_unique])
    else
      return "#{NON_EXISTENT_COMMAND_NAME} Invalid command."
    end

    result.message
  end

  def execute_retrieval(command_args)
    cas_required = command_args[:command] == 'gets'
    entries = @cache.get(command_args[:keys]).entries

    result = StringIO.new
    entries.each do |e|
      result << "VALUE #{e.key} #{e.flags} #{e.data.length}"
      result << " #{e.cas_unique}" if cas_required
      result << "\n#{e.data}\n"
    end
    result << 'END'

    result.string
  end

  def is_storage?(command)
    STORAGE_COMMANDS.include?(command)
  end

  private

  def is_retrieval?(command)
    RETRIEVAL_COMMANDS.include?(command)
  end

  def generate_storage_args(tokens)
    unless valid_args_count?(tokens)
      return CommandParsingResult.new(nil, true, "#{CLIENT_ERROR} Invalid number of arguments.")
    end

    key = tokens[1]
    flags = tokens[2]
    exp_time = tokens[3]
    bytes = tokens[4]

    if !valid_key?(key)
      return CommandParsingResult.new(nil, true, "#{CLIENT_ERROR} Key is not valid.")
    elsif !valid_flags?(flags)
      return CommandParsingResult.new(nil, true, "#{CLIENT_ERROR} Flags are not valid.")
    elsif !valid_time?(exp_time)
      return CommandParsingResult.new(nil, true, "#{CLIENT_ERROR} Expiration time is not valid.")
    elsif !valid_bytes?(bytes)
      return CommandParsingResult.new(nil, true, "#{CLIENT_ERROR} Bytes specified are not valid.")
    elsif is_cas?(tokens[0]) && !valid_cas_unique?(tokens)
      return CommandParsingResult.new(nil, true, "#{CLIENT_ERROR} Cas value is not valid.")
    end

    noreply = contains_no_reply?(tokens)

    args = { command: tokens[0], key: key, flags: flags, exp_time: parse_exp_time(exp_time), bytes: Integer(bytes), noreply: noreply }

    args[:cas_unique] = Integer(tokens[5]) if is_cas?(tokens[0])

    CommandParsingResult.new(args, false, nil)
  end

  def valid_args_count?(tokens)
    if tokens[0] == 'cas'
      valid = tokens.length >= 6 && tokens.length <= 7
    else
      # cas command has different args, so it has to be evaluated separately
      valid = tokens.length >= 5 && tokens.length <= 6
    end
    valid
  end

  def is_cas?(command)
    command == 'cas'
  end

  def valid_cas_unique?(tokens)
    is_unsigned_int(tokens[5])
  end

  def contains_no_reply?(tokens)
    if tokens[0] == 'cas'
      tokens.length == 7 && tokens[6] == 'noreply'
    else
      tokens.length == 6 && tokens[5] == 'noreply'
    end
  end

  def generate_retrieval_args(tokens)
    if tokens.length < 2
      return CommandParsingResult.new(nil, true, "#{CLIENT_ERROR} Invalid number of arguments.")
    end

    args = { command: tokens[0], keys: tokens.drop(1) }
    CommandParsingResult.new(args, false, nil)
  end

  def valid_key?(key)
    key.length <= 250 && (key =~ /[^[:print:]]/).nil?
  end

  def valid_flags?(flags)
    is_unsigned_int(flags)
  end

  def valid_time?(exp_time)
    is_integer?(exp_time)
  end

  def valid_bytes?(bytes)
    is_unsigned_int(bytes)
  end

  def is_unsigned_int(string)
    is_integer?(string) && Integer(string) >= 0
  end

  def is_integer?(string)
    /\A[-+]?\d+\z/ === string
  end

  def parse_exp_time(time)
    seconds = Integer(time)
    if seconds > 2_592_000
      secs_since_epoch = Time.now.to_i
      return seconds - secs_since_epoch
    end
    seconds
  end
end
