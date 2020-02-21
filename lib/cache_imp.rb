require_relative './cache_entry.rb'
require_relative './cache_storage_result.rb'
require_relative './cache_retrieval_result.rb'

class CacheImp

  def initialize
    @hash_storage = {}
    @cas_current = 2**32
  end

  def set(key, data, flags, exp_time)
    cas_unique = next_cas_val()
    entry = CacheEntry.new(key:key, data:data, flags: flags, exp_time: exp_time, cas_unique: cas_unique)
    @hash_storage[key] = entry
    return CacheStorageResult.new(success: true, message: 'STORED', entry: entry)
  end

  def add(key, data, flags, exp_time)
    if !@hash_storage.key?(key)
      set(key, data, flags, exp_time)
    else
      return CacheStorageResult.new(success: false, message: 'NOT_STORED')
    end
  end

  def replace(key, data, flags, exp_time)
    if !@hash_storage.key?(key)
      return CacheStorageResult.new(success: false, message: 'NOT_STORED')
    else
      set(key, data, flags, exp_time)
    end
  end

  def append(key, data, flags, exp_time)
    if !@hash_storage.key?(key)
      return CacheStorageResult.new(success: false, message: 'NOT_STORED')
    else
      current_entry = @hash_storage[key]
      set(key, current_entry.data + data, flags, exp_time)
    end
  end

  def prepend(key, data, flags, exp_time)
    if !@hash_storage.key?(key)
      return CacheStorageResult.new(success: false, message: 'NOT_STORED')
    else
      current_entry = @hash_storage[key]
      set(key, data + current_entry.data, flags, exp_time)
    end
  end

  def cas(key, data, flags, exp_time, cas_unique)
    if !@hash_storage.key?(key)
      return CacheStorageResult.new(success: false, message: 'NOT_FOUND')
    elsif @hash_storage[key].cas_unique != cas_unique
      return CacheStorageResult.new(success: false, message: 'EXISTS')
    else
       set(key, data, flags, exp_time)
    end
  end

  def get(keys)
    result = CacheRetrievalResult.new(success: true, entries: [])
    
    keys.each do |k|
      add_entry_if_valid(result, k)
    end

    return result
  end

private

  def next_cas_val
    val = @cas_current
    @cas_current = @cas_current + 1
    return val
  end

  def add_entry_if_valid(result, key)
    val = @hash_storage[key]
    if !val.nil? && !expired?(val)
      result.entries << val
    elsif !val.nil? && expired?(val)
      remove_entry(key)
    end
  end

  def expired?(entry)
    return !entry.exp_date.nil? && entry.exp_date <= Time.now
  end

  def remove_entry(key)
    @hash_storage.delete(key)
  end
end

