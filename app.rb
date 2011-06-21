require 'rubygems'
require 'bundler'
Bundler.require(:default, (ENV['RACK_ENV'] ||= :development.to_s).to_sym)
require './lib/redirectcheck'

CACHE_LIFETIME = 86400 # cache for 1 day
GA_CODE = "<script type=\"text/javascript\">var _gaq = _gaq || [];_gaq.push(['_setAccount', '#GA_ACCOUNT#']);_gaq.push(['_trackPageview']);(function() {var ga = document.createElement('script');ga.type = 'text/javascript'; ga.async = true;ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);})();</script>"

# handle json call
get %r{/json/(.*)} do
  uri = params[:captures].first
  content_type :json
  result = RedirectCheck.check(uri)
  etag Digest::MD5.hexdigest("#{result[:http_code]}-#{uri}")
  # deliver result
  result.to_json
end
  
get %r{/(.*)} do
  if request.env['HTTP_USER_AGENT'].include? 'redirectcheck-client'
    uri = params[:captures].first
    Gabba::Gabba.new(ENV['GA_ACCOUNT'], "redirectcheck.koeniglich.ch").event("Clients", "Request", request.env['HTTP_USER_AGENT']) if ENV['GA_ACCOUNT']
    result = RedirectCheck.check(uri)
    result[:http_code]
  else
    index_html = File.read('./views/index.html')
    index_html.sub!('<!--#GA#-->', GA_CODE.sub('#GA_ACCOUNT#', ENV['GA_ACCOUNT'])) if ENV['GA_ACCOUNT']
    etag Digest::MD5.hexdigest(index_html)
    index_html
  end
end