class CacheRetrievalResult

  attr_reader :success, :entries

  def initialize(args)
    @success = args[:success]
    @entries = args[:entries]
  end

end