class CacheEntry
  attr_reader :key, :data, :exp_date, :flags ,:cas_unique

  def initialize(args)
    @key = args[:key]
    @data = args[:data]
    @exp_date = Time.now + args[:exp_time]
    @flags = args[:flags]
    @cas_unique = args[:cas_unique]
  end

end