require 'uri'
require 'net/http'

class RedirectCheck
  def self.check(uri)
    return { :http_code => '-1', :error => 'Protocol not supported' } if uri =~ /^(?!https?).*:\/\//
    
    uri = "http://#{uri}" unless uri =~ /^https?:\/\//
    uri = URI.parse(uri)
    begin
      Net::HTTP.start(uri.host, uri.port) do |http|
        { :http_code => http.head(uri.request_uri).code }
      end
    rescue Exception => e
      { :http_code => '0', :error => 'Connection failed' }
    end
  end
end

if __FILE__ == $0 and 1 == ARGV.size
  puts RedirectCheck.check(ARGV[0])
end
