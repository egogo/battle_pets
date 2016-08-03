require 'faraday_bang'

class ServiceWrapperBase
  attr_reader :connection

  def self.connection(url)
    Faraday.new(url: url) do |faraday|
      faraday.request  :url_encoded
      faraday.adapter  Faraday.default_adapter
    end
  end
end