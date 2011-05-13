require 'uri'
require 'net/https'

class RedirectCheck
  def self.check(uri)
    return { :http_code => '-1', :error => 'Protocol not supported' } if uri.match(/^(?!https?).*:\/\//)
    
    uri = "http://#{uri}" unless uri.match(/^https?:\/\//)
    uri = URI.parse(uri)
    begin
      http = Net::HTTP.new(uri.host, uri.port)
      if uri.scheme == 'https' or uri.port == 443
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      http.start do |http|       
        { :http_code => http.head(uri.request_uri).code }
      end
    rescue Exception => e
      puts e
      { :http_code => '0', :error => 'Connection failed' }
    end
  end
end

if __FILE__ == $0 and 1 == ARGV.size
  puts RedirectCheck.check(ARGV[0])
end
