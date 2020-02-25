# frozen_string_literal: true

class CacheRetrievalResult
  attr_reader :success, :entries

  def initialize(args)
    @success = args[:success]
    @entries = args[:entries]
  end
end
