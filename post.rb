
require 'net/http'

def request uri, para_array, requesttype

	uri = URI(uri)

	if requesttype == 'post'
		para_array.each do |para|
			res = Net::HTTP.post_form(uri, para)

			puts 'POST ' 
			para.each do |key, value|
				puts key + ': ' + value
			end

			puts res.code       # => '200'
			puts res.message    # => 'OK'
			#puts res.class.name # => 'HTTPOK'
			puts res.body if res.is_a?(Net::HTTPSuccess)
			puts "\n"
		end
	end


	if requesttype == 'get'
		para_array.each do |para|
			uri.query = URI.encode_www_form(para)
			res = Net::HTTP.get_response(uri)

			puts 'GET ' + uri.query
			puts res.code       # => '200'
			puts res.message    # => 'OK'
			#puts res.class.name # => 'HTTPOK'
			puts res.body if res.is_a?(Net::HTTPSuccess)
			puts "\n"
		end
	end
end



uri = 'http://example.com/'


para_array = [
				{'email' => '3aumann@example.com', 'customer' => '100', 'name' => 'ruby 1'},
				{'email' => '3aumann@example.com', 'customer' => '100', 'name' => 'ruby  2'},
				{'email' => '3aumann@example.com', 'customer' => '100', 'name' => 'ruby  3'},

			 ]



request uri, para_array,'post'