class CacheEntry
  attr_reader :data, :exp_time, :flags ,:cas_unique

  def initialize(data, flags, exp_time, cas_unique)
    @data = data
    @exp_time = exp_time
    @flags = flags
    @cas_unique = cas_unique
  end

end