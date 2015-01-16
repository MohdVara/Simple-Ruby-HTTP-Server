=begin

	Name :  Mohd. Paramasvara

=end

require 'yaml'   #Classes for YAML 
require 'socket' #Classes for TCPServer and Socket
require 'uri'    #Classes for HTTP server
    
=begin    
    
    Configuration setting are from YAML files 
   
=end   

   server_config = YAML::load_file('config/server.yml')
CONTENT_TYPE_MAP = YAML::load_file('config/content_type.yml')    
       
#Files will be served from this directory
WEB_ROOT = server_config["web_root"]
    HOST = server_config["host"]
    PORT = server_config["port"]

#Map extensions to their content type
	
#Treat as binary if content type is not found
DEFAULT_CONTENT_TYPE='application/octet-stream'
	

=begin
	Helper function definitions
=end
#Determines the extension of file	
def content_type(path)
		
	#Dividing the name into two string and get the last string.	
	ext = File.extname(path).split(".").last
	
	#Check if ext(extension) is in content type map
	CONTENT_TYPE_MAP.fetch(ext, DEFAULT_CONTENT_TYPE)
	
end
		
#Sanitize client HTTP header	
def sanatize_request(request_file)
	
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
	
def http_response
	
	
end	
	
=begin
	Server main 
=end
#Run server on HOST:PORT	
 server =  TCPServer.new(HOST,PORT)
 
#Shows confirmation on server 
print "\nServer listening on port #{PORT} host #{HOST} \n"	
	
#Loop forever
loop do 
	
	#Create thread to allow multiple clients
	Thread.start(server.accept) do |client|
	
		#Get client ip information 
		client_ip = client.peeraddr[2] 
	
		#Store client HTTP GET request into requested_file
		request_file = client.gets
		
		#Show client request on console
		print "\n#{request_file} from #{client_ip}\n"
		
		#Clean request from Directory Traversal Attacks
		path = sanatize_request(request_file)
		
		
		#Replace path with default index.html when client ask directory
		if File.directory?(path)
		
			path = File.join(WEB_ROOT, 'index.html')
			print "\n Redirecting to index.html \n"
			 
		end 
	
		
		#Check it is a file and is not a directory
		if File.exist?(path) && !File.directory?(path)
			
			#Opens file specified in the path and read the file binary 
			File.open(path, "rb") do |file|
			
				print "\n Give #{file.name} \n"
				#Send HTTP packet to client
		        client.print "HTTP/1.1 200 OK\r\n" +
                             "Content-Type: #{content_type(file)}\r\n" +
                             "Content-Length: #{file.size}\r\n" +
                             "Connection: close\r\n"
				
				#Close HTTP header
                client.print "\r\n"
                 
				#write the contents of the file to the socket
				IO.copy_stream(file, client)
				
			end
		else
			
			
			#Message inside 404 error
			message = "File not found\n"
			
			#Show
			print "\n Response : " + message + "\n"
			
			#File not found respond with 404 error
			client.print "HTTP/1.1 404 Not Found\r\n" +
                          "Content-Type: text/plain\r\n" +
                          "Content-Length: #{message.size}\r\n" +
                          "Connection: close\r\n"
            
            #Close HTTP header
            client.print "\r\n"
            
            #Print content
            client.print message
			
        end
        
    #Close connection
	client.close
	
	end
	
	
end