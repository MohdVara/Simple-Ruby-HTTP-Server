module Helper
=begin

	Helper function definitions
	
=end

	#Determines the extension of file	
	def Helper.content_type(path)
		
		#Dividing the name into two string and get the last string.	
		ext = File.extname(path).split(".").last
	
		#Check if ext(extension) is in content type map
		CONTENT_TYPE_MAP.fetch(ext, DEFAULT_CONTENT_TYPE)
	
	end
		
	#Sanitize client HTTP header	
	def Helper.sanatize_request(request_file)
	
		#Process of extracting the URI from the HTTP GET request
		request_uri = request_file.split(" ")[1]
		path = URI.unescape(URI(request_uri).path)
		clean_uri = []
	  
		#Split the path into components
		parts = path.split("/")
		
		#Loops through whole link
		parts.each do |part|
			
			#skip any empty or current directory (".") path componenets
			next if part.empty? || part == '.'
			
			part == '..' ? clean_uri.pop : clean_uri <<  part
		
		end
	
		#return the web root joined to the clean path
		File.join(WEB_ROOT, *clean_uri)	
	
	end
end