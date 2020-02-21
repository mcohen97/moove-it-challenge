class CacheEntry
  attr_reader :key, :data, :exp_date, :flags ,:cas_unique

  def initialize(args)
    @key = args[:key]
    @data = args[:data]
    @exp_date = args[:exp_time] == 0? nil : Time.now + args[:exp_time]
    @flags = args[:flags]
    @cas_unique = args[:cas_unique]
  end

end