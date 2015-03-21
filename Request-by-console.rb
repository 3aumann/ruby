#!/usr/bin/ruby
 
require "uri"
require "net/http"
require 'optparse' 
 
 
# USAGE 
# for help in console
# ruby Request-by-console.rb -h 
 
 
class Request
 
	def initialize(uri, param)
		@param = param
		@uri = uri
 
		# define headers
		# overide the ruby default useragent 'Ruby'
		@useragent = "" 
		@referer   = ""
 
	end
 
	def setHeader=(v)
		@header = v
	end
 
	def setHeaderUseragent=(v)
		@useragent = v
	end
 
	def setHeaderReferer=(v)
		@referer = v
	end
 
	def showHTTPResponseHeaders()
		if !@res.nil? then	
			puts "HTTP Response Headers"
			@res.each_header do |key, value|
  				puts "#{key} => #{value}"
			end
		end	
		puts "\n"
	end
 
	def showResponseHTTP()
		if !@res.nil? then	
			puts "HTTP response \n"
			puts "HTTP/#{@res.http_version} #{@res.code} #{@res.message}"
			puts "\n"
		end
	end
 
	def showResponseHTTP_code()
		if !@res.nil? then	
			puts "HTTP response codes \n"
			puts "\t HTTP code: #{@res.code}"
			puts "\n"
		end
	end
 
	def showResponseHTTP_message()
		if !@res.nil? then	
			puts "HTTP response message \n"
			puts "\t HTTP message: #{@res.message}"
			puts "\n"
		end
	end
 
	def showResponse_content_type()
		if !@res.nil? then	
			puts "response content_type \n"
			puts "\t HTTP content_type: #{@res.content_type}"
			puts "\n"
		end	
	end
 
	def showResponse_body()
		if !@res.nil? then	
			puts "response body \n"
			puts "\t body #{@res.body}"
			puts "\n"
		end
	end
 
	def logResponse(logfile)
 		t = File.file?(logfile) ? "a+" : "w"
		if !@res.nil? then	
			File.open(logfile, t) do |f|
				f.write "#@method #@uri?" + URI.encode_www_form(@param) + " #{@res.code} #{@res.message} #{@res.class.name} \n"
			end
		else
			File.open(logfile, t) do |f|
				f.write "#@method #@uri Request fails \n"
			end
		end	
	end
 
	def logResponseFull(logfile)
		t = File.file?(logfile) ? "a+" : "w"
		if !@res.nil? then	
			File.open(logfile, t) do |f|
				f.write "
					#@method #@uri #@param
					#{@res.code} 
					#{@res.message} 
					#{@res.class.name}
					#{@res.content_type} 
					#{@res.body} 
					\n"
			end
		else
			File.open(logfile, t) do |f|
				f.write "#@uri Request fails \n"
			end
		end	
	end
 
	def showParams()
		puts "parameter \n"
		@param.each do |key, value|
			puts "\t" + key + ': ' + value + "\n"
		end
		puts "\n"
	end
 
	def showLinkget()
		puts "try to open URI with GET (written as GET declaration): \n"
		puts @uri + '?' + URI.encode_www_form(@param) + "\n"
	end
 
	def showLinkpost()
		puts "try to open URI with POST: "
		puts @uri  + "\n"
	end
 
	def post()
 
		self.showLinkpost()
		self.showParams()
 
		uri = URI(@uri)
		@method = :"POST"
 
		begin
			
			http = Net::HTTP.new(uri.host, uri.port)
 
			request = Net::HTTP::Post.new(uri.request_uri)
			request.set_form_data(@param)
 
			puts "Headers"
			puts "User-Agent: #{@useragent}" 
			puts "Referer: #{@referer} \n" 
 
			request["User-Agent"] = @useragent
			request["Referer"] = @referer
 
 
			if !@header.nil? then 
				puts "additional Headers"
					@header.each do|k,v|
					puts "#{k}: #{v}" 
					request.add_field(k, v)
				end
				puts "\n"
			end
 
			@res = http.request(request)
 
		# one to get them all	
		rescue StandardError
			puts 'POST Request fails, check spelling of the uri'
		end	
	end
 
	def get()
 
		self.showLinkget()
		self.showParams()
 
		@method = :"GET"
 
		uri = URI(@uri)
		uri.query = URI.encode_www_form(@param)
		
		begin
 
			http = Net::HTTP.new(uri.host, uri.port)
			request = Net::HTTP::Get.new(uri.request_uri)
 
			puts "Headers"
			puts "User-Agent: #{@useragent}" 
			puts "Referer: #{@referer} \n" 
 
			# overide ruby default with "" or set by -U
			request["User-Agent"] = @useragent 
			request["Referer"] = @referer
 
			if !@header.nil? then 
				puts "Additional Headers"
					@header.each do|k,v|
					puts "#{k}: #{v}" 
					request.add_field(k, v)
				end
				puts "\n"
			end
 
			@res = http.request(request)
 
		# one to get them all	
		rescue StandardError
			puts 'GET Request fails, check spelling of the uri'
		end	
	end
end
 
 
class ConsoleInput
 
	def initialize()
 
		@options = {}
		@param = Hash.new
		@header = Hash.new
 
		optparse = OptionParser.new do |opts| 
 
			opts.on( '-h', '--help', 'Display this screen' ) do     
				puts opts 
				exit   
			end
 
			opts.on( '-u', '--uri URI', "URI -u test.com no http://" ) do |u| 
				@options[:uri] = u 
			end 
 
			@options[:method] = :"GET" 
 
			opts.on( '-m', '--method METHOD', [:"GET", :"POST"], "Request METHOD -m GET or -m POST" ) do |m| 
				@options[:method] = m 
			end 
 
			#options[:keys] = [] 
			#opts.on( '-k', '--keys a,b,c', Array, "List of parameter keys" ) do |f| 
			#	options[:keys] = f 
			#end 
 
			opts.on("-P", "--Parameter <key,value>", "key,value pairs: -P k1,v1 -P k2,v2 etc.") do |i|
				list = i.split(',')
				unless list.length == 2
					raise "error because you didn't place all arguments like -i k1,v1 -i k2,v2"
				end
				@param[list.first] = list.last 
			end 
 
			opts.on("-H", "--Header <key,value>", "key,value pairs: -H k1,v1 -H k2,v2 etc.") do |h|
				list = h.split(',')
				unless list.length == 2
					raise "error because you didn't place all arguments like -H k1,v1 -h k2,v2"
				end
				@header[list.first] = list.last 
			end 
 
			opts.on( '-U', '--Useragent UA', "UA -U test script" ) do |a| 
				@options[:useragent] = a
			end
 
			opts.on( '-R', '--Referer REFERER', "referer -R test script" ) do |r| 
				@options[:referer] = r
			end
 
		end 
 
		optparse.parse!
 
		if @options[:uri].nil? then 
			puts 'URI is mandatory: -u test.net'
			exit
		else
			@options[:uri] = 'http://' + @options[:uri]
		end	
 
		request = Request.new(@options[:uri], @param)
 
 
		if !@options[:useragent].nil? then 
			request.setHeaderUseragent = @options[:useragent]
		end
 
		if !@options[:referer].nil? then 
			request.setHeaderReferer = @options[:referer]
		end
 
		if !@header.nil? then 
			request.setHeader = @header
		end
 
		if @options[:method] == :"POST" then 
			request.post() 
		end 
 
		if @options[:method] == :"GET" then 
			request.get() 
		end
 
		request.showResponseHTTP()
		request.showHTTPResponseHeaders()
		request.logResponse('Response.log')
 
	end
end	
 
	ConsoleInput.new() 