class CacheStorageResult

  attr_reader :success, :message, :entry

  def initialize(args)
    @success = args[:success]
    @message = args[:message]
    @entry = args[:entry]
  end

end
