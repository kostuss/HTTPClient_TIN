###Module for handling communication with the server###
#Protocol: HTTP
#Communication: TCP Socket
#Communiation secured with SSL
require 'openssl'
require 'socket'
require 'json'
require 'jwt'
require_relative 'requests'

class SSLCommunication

	def initialize(host="77.55.211.26",port=12346, retry_limit=5)
		@host=host
		@port=port
		@ssl_socket=getSocket
		@retry_limit=retry_limit
		@auth_code="None"
		@expire_time="None"
	end

	def getSocket
		begin
			context = OpenSSL::SSL::SSLContext.new
			tcp_client = TCPSocket.new(@host, @port)
			ssl_client = OpenSSL::SSL::SSLSocket.new tcp_client, context
			ssl_client.connect
			@ssl_socket=ssl_client
		rescue Errno::ECONNREFUSED => e 
			raise "Failed to initialize socket" 
		end
	end

	def requestSocket(request)
		begin
			attempts = attempts || 0
			@ssl_socket.syswrite request
			allbuffer=''
			count=0
			len=0
			while 1==1
				buffer=@ssl_socket.sysread(1024)
				allbuffer=allbuffer+buffer
				count+=1
				if count==100
					len=content_length(allbuffer)
				end
				if count%1024==0
					puts "Downloaded: #{allbuffer.length} of #{len}"
				end 
				if buffer.length != 1024
					break
				end
			end
			return allbuffer
		rescue EOFError, NoMethodError
			attempts+=1
			@ssl_socket=getSocket()
			retry if attempts<@retry_limit
			raise "Unable to read from server"
		end 
	end

	def requestSocket1(request)
		begin
			attempts = attempts || 0
			@ssl_socket.syswrite request

			resp=@ssl_socket.sysread(1024)
			body_len=resp.split("\r\n\r\n", 2)[1].length
			#puts body_len
			#puts content_length(resp)
			if body_len<content_length(resp).to_i
				puts "2"
				puts content_length(resp).to_i-body_len
				resp1=@ssl_socket.sysread(15360)
				puts resp1.length
				resp2=@ssl_socket.sysread(15360)
				puts resp2.length
			end

			return resp
		rescue EOFError, NoMethodError
			attempts+=1
			@ssl_socket=getSocket()
			retry if attempts<@retry_limit
			raise "Unable to read from server"
		end 
	end

	def authorize(username, password)
		
		resp =requestSocket(authorizeRequest(username, password))
		status=response_status(resp)
		if status=="200"
			set_auth_code(resp)
		elsif ["400", "401","404"].include?(status)
			puts response_body(resp)
		elsif status=="500"
			raise "Something went wrong with the server during authorization"
		else
			raise "Undefined error"
		end	
		return status							
	end 

	def prolong
		resp = requestSocket(prolongRequest(@auth_code))
		status=response_status(resp)
		if status=="200"
			set_auth_code(resp)
		elsif ["400", "401","404"].include?(status)
			puts response_body(resp)
		elsif status=="500"
			raise "Something went wrong with the server during authorization"
		else
			raise "Undefined error"
		end
		return status							
	end

	def logOut
		@auth_code="None"						
	end 

	def createUser(credentials)
		resp =requestSocket(createUserRequest(@auth_code, credentials))
		status=response_status(resp)
		if status=="200"
			#DONOTHING
		elsif ["400", "401","404"].include?(status)
			puts response_body(resp)
		elsif status=="500"
			raise "Something went wrong with the server while creating user"
		else
			raise "Undefined error"
		end	
		return status
	end

	def changeUser(id, credentials)
		resp =requestSocket(changeUserRequest(@auth_code,id,credentials))
		status=response_status(resp)
		
		if status=="200"
			#puts "User #{credentials[0]} changed :)"
		elsif ["400", "401","404","405"].include?(status)
			puts response_body(resp)
		elsif status=="500"
			raise "Something went wrong with the server while changing user"
		else
			raise "Undefined error"
		end
		return status
	end

	def getUsers
		resp =requestSocket(getUserRequest(@auth_code))
		status=response_status(resp)
		#puts resp
		out=[]
		out[0]=status
		if status=="200"
			out[1]=response_body(resp)
		elsif ["400", "401","404"].include?(status)
			puts response_body(resp)
		elsif status=="500"
			raise "Something went wrong with the server while checking users"
		else
			raise"Undefined error"
		end	

		return out
	end

	def deleteUser(id)
		resp =requestSocket(deleteUserRequest(@auth_code, id))
		status=response_status(resp)
		if status=="200"
			#puts "User deleted :)"
		elsif ["400", "401","404", "405"].include?(status)
			puts response_body(resp)
		elsif status=="500"
			raise "Something went wrong with the server while deleting user"
		else
			raise "Undefined error"
		end	
		return status
	end							
	
	def getDir(dir)
		resp=requestSocket(getDirRequest(@auth_code,dir,'True'))
		status=response_status(resp)
		out=[]
		out[0]=status
		if status=="200"
			#return response_body(resp)
			out[1]=response_body(resp)
		elsif ["400", "401","404"].include?(status)
			puts response_body(resp)
		elsif status=="500"
			raise "Something went wrong with the server while listing directory"
		else
			raise "Undefined error"
		end	
		return out
	end

	def generate500
		resp=requestSocket(generate500Request())
		status=response_status(resp)
		if status=="200"
			return response_body(resp)
		elsif ["400", "401"].include?(status)
			puts response_status(resp)
		elsif status=="404"
			raise "Something went wrong with the server while testing 500"
		else
			raise "Undefined error"
		end	
	end

	def makeDir(folder)
		resp=requestSocket(postDirRequest(folder, @auth_code))
		status=response_status(resp)
		if status=="200"
			puts "Folder #{folder} created"
		elsif status=="404"
			puts "404 Not found"
		elsif status=="500"
			puts "500 Something went wrong"		
		end 
	end

	def getFile(file)
		
		resp=requestSocket(getFileRequest(file))
		status=response_status(resp)

		if status=="200"
			len=response_length(resp)
			puts "You've downloaded: #{len} bytes"
			return response_body(resp), response_header(resp)
		elsif status=="404"
			puts "404 Not found"
			return -1
		elsif status=="500"
			puts "500 Something went wrong"
			return -2		
		end 
	end

	def writeFile(file, content)
		open(file, 'w') do |f|
	  		f.puts content
		end
	end 

	def set_auth_code(response)
		headers =response.split("\r\n\r\n", 2)[0]
		headers =headers.split("\n")
		token = headers[3].split(" ")[2]
		@auth_code=token
		decoded_token= JWT.decode(token, nil, false)[0]
		@expire_time= decoded_token["expires"]+86400/12
	end

	def remaining_time
		return @expire_time-Time.now.to_f
	end

	def content_length(response)
		headers =response.split("\r\n\r\n", 2)[0]
		headers =headers.split("\n")
		return headers[6].split(" ")[1]
	end

	def response_status(response)
		headers =response.split("\r\n\r\n", 2)[0]
		headers =headers.split("\n")
		return headers[0].split(" ")[1]
	end

	def response_length(response)
		headers =response.split("\r\n\r\n", 2)[0]
		headers =headers.split("\n")
		return headers[6].split(" ")[1]
	end 

	def response_body(response)
		return response.split("\r\n\r\n", 2)[1]	
	end

	def response_header(response)
		return response.split("\r\n\r\n", 2)[0]	
	end
end

if __FILE__ == $0
	begin
		communication=SSLCommunication.new
		communication.authorize("kostuss16","Damian123")
		communication.decode_auth

	rescue Errno::ENETUNREACH => e
		puts e
	rescue RuntimeError => e
		puts e	
	end 
end
