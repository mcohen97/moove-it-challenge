require "test/unit"
require_relative '../lib/cache_imp.rb'

class CommandExecutorTest < Test::Unit::TestCase

  def setup
    @cache = CacheImp.new
  end

  def test_set_key_value
    result = @cache.set('Key','Data', 0, 60)
    fetched = @cache.get(['Key']).entries[0]

    assert_true result.success
    assert_equal 'STORED', result.message
    assert_equal 'Data', fetched.data
  end

  def test_add_non_existing
    result = @cache.add('Key','Data', 0, 60)
    fetched = @cache.get(['Key']).entries[0]

    assert_true result.success
    assert_equal 'STORED', result.message
    assert_equal 'Data', fetched.data
  end

  def test_add_already_existing
    @cache.set('Key','Data', 0, 60)
    result = @cache.add('Key','Data', 0, 60)
    fetched = @cache.get(['Key']).entries[0]

    assert_false result.success
    assert_equal 'NOT_STORED', result.message
  end

  def test_replace_existing
    result = @cache.add('Key','Data1', 0, 60)
    result = @cache.replace('Key','Data2', 0, 60)
    fetched = @cache.get(['Key']).entries[0]

    assert_true result.success
    assert_equal 'STORED', result.message
    assert_equal 'Data2', fetched.data
  end

  def test_replace_non_existing
    result = @cache.replace('Key','Data2', 0, 60)
    fetched = @cache.get(['Key']).entries[0]

    assert_false result.success
    assert_equal 'NOT_STORED', result.message
  end

  def test_get_non_existing
    result = @cache.get(['non_existing'])
    
    assert_true result.success
    assert_false result.entries.any?
  end

  def test_get_multiple
    @cache.add('Key1','Data1', 0, 60)
    @cache.add('Key2','Data2', 0, 60)
    @cache.add('Key3','Data3', 0, 60)

    result = @cache.get(['Key1', 'Key3'])

    assert_true result.success
    assert_equal 2, result.entries.length
  end

  def test_get_multiple_some_non_existing
    @cache.add('Key1','Data1', 0, 60)

    result = @cache.get(['Key1', 'Key3'])

    assert_true result.success
    assert_equal 1, result.entries.length
  end

  def test_get_expired_keys
    @cache.add('Key1','Data1', 0, 0)
    sleep(1)
    result = @cache.get(['Key1'])

    assert_false result.entries.any?
  end

  def test_cas_successfully
    @cache.add('Key1','Data1', 0, 60)
    fetched = @cache.get(['Key1']).entries[0]
    cas_unique = fetched.cas_unique

    result = @cache.cas('Key1', 'Data2', 2 , 70, cas_unique)
    assert_true result.success
    assert_equal 'STORED', result.message
    assert_equal 'Data2', result.entry.data
  end

  def test_cas_already_updated
    @cache.add('Key1','Data1', 0, 60)
    fetched = @cache.get(['Key1']).entries[0]
    cas_unique = fetched.cas_unique
    cas_unique+= 72 #provide a different cas_unique, so that is rejected

    result = @cache.cas('Key1', 'Data2', 2 , 70, cas_unique)
    fetched = @cache.get(['Key1']).entries[0]
    assert_false result.success
    assert_equal 'EXISTS', result.message
    assert_equal 'Data1', fetched.data
  end

  def test_cas_non_existent
    result = @cache.cas('Key1', 'Data2', 2 , 70, 22)
    assert_false result.success
    assert_equal 'NOT_FOUND', result.message
  end
  
end