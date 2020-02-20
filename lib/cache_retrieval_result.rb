class CacheRetrievalResult

  attr_reader :success, :entries

  def initialize(args)
    @success = args[:success]
    @entries = args[:entries]
  end

end

class KeyValue

  attr_reader :key, :value

  def initialize(args)
    @key = args[:key]
    @value = args[:value]
  end

end