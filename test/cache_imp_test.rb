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
    assert_equal 'Data', fetched.value.data
  end

end