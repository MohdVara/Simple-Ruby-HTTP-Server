=begin

	Name :  Mohd. Paramasvara

=end


=begin

	Load Classes & Module

=end


require 'yaml'                 #Classes for YAML 
require 'socket'               #Classes for TCPServer and Socket
require 'uri'                  #Classes for HTTP server

   $LOAD_PATH << './include'   #Load PATH for custom functions
	
require 'functions'            #Include helper functions


=begin    
    
    Configuration setting are from YAML files 
   
=end   


   server_config = YAML::load_file('config/server.yml')         # Load server constant
CONTENT_TYPE_MAP = YAML::load_file('config/content_type.yml')   # Load content types   
       
#Set constant variable for easy maintenance
WEB_ROOT = server_config["web_root"]
    HOST = server_config["host"]
    PORT = server_config["port"]

	
#Treat as binary if content type is not found
DEFAULT_CONTENT_TYPE='application/octet-stream'


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
		path = Helper.sanatize_request(request_file)
		
		
		#Replace path with default index.html when client ask directory
		if File.directory?(path)
		
			path = File.join(WEB_ROOT, 'index.html')
			print "\n Redirecting to index.html \n"
			 
		end 
	
		
		#Check it is a file and is not a directory
		if File.exist?(path) && !File.directory?(path)
			
			#Opens file specified in the path and read the file binary 
			File.open(path, "rb") do |file|
			
				#Send HTTP packet to client
			    client.print "HTTP/1.1 200 OK\r\n" +
                             "Content-Type: #{Helper.content_type(file)}\r\n" +
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