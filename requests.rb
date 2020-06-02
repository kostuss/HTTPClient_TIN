###Deffinitions of HTTP requests used by SSLCommunication module###
require 'json'

def authorizeRequest(username, password)
	q=<<~HEREDOC
	POST /authorize HTTP/1.1\r
	\r
	{"username":"#{username}","password":"#{password}"}
	HEREDOC
	return q
end

def prolongRequest(auth_code)
	q=<<~HEREDOC
	POST /prolong-session HTTP/1.1\r
	Authorization: #{auth_code}\r\n\r\n
	HEREDOC
	return q
end

def logOutRequest(username, password)
	q=<<~HEREDOC
	POST /authorize HTTP/1.1\r
	\r
	{"username":"#{username}","password":"#{password}"}
	HEREDOC
	return q
end

def getDirRequest(auth_code,folder, info)
	q=<<~HEREDOC
	GET /dir/#{folder}?info=#{info} HTTP/1.1\r
	Authorization: #{auth_code}\r\n\r\n
	HEREDOC
	return q
end 

def createUserRequest(auth_code, credentials)

	body=generate_body(credentials)
	#body={:username => credentials[0], :password => credentials[1], :first_name => credentials[2], :last_name => credentials[3], :role => credentials[4]}.to_json
	len=body.length
	q=<<~HEREDOC
	POST /users HTTP/1.1\r
	Authorization: #{auth_code}\r
	Content-Length: #{len}\r
	\r
	#{body}
	HEREDOC
	return q
end

def changeUserRequest(auth_code,id,credentials)
	
	body=generate_body(credentials)
	#body={ :password => credentials[1], :first_name => credentials[2], :last_name => credentials[3], :role => credentials[4]}.to_json
	len=body.length
	q=<<~HEREDOC
	PATCH /users/#{id} HTTP/1.1\r
	Authorization: #{auth_code}\r
	Content-Length: #{len}\r
	\r
	#{body}
	HEREDOC
	return q
end

def generate_body(credentials)
	hash1={}
	keys=["username","password","first_name","last_name","role"]
	credentials.zip(keys).each do |credentials, key|
		if credentials!=''
			hash1[key]=credentials
		end
	end
	return hash1.to_json
end

def getUserRequest(auth_code)
	q=<<~HEREDOC
	GET /users HTTP/1.1\r
	Authorization: #{auth_code}\r\n\r\n
	HEREDOC
	return q
end

def getOneUserRequest(auth_code)
	q=<<~HEREDOC
	GET /users?limit=1&offset=0 HTTP/1.1\r
	Authorization: #{auth_code}\r\n\r\n
	HEREDOC
	return q
end

def deleteUserRequest(auth_code, id)
	q=<<~HEREDOC
	DELETE /users/#{id} HTTP/1.1\r
	Authorization: #{auth_code}\r\n\r\n
	HEREDOC
	return q
end

def generate500Request
	q=<<~HEREDOC
	POST /produce-exception HTTP/1.1\r\n\r\n
	HEREDOC
	return q
end


def getFileRequest(file, auth_code)
	q=<<~HEREDOC
	GET /file#{file} HTTP/1.1\r
	Authorization: #{auth_code}\r\n\r\n
	HEREDOC
	return q
end 

def postDirRequest(folder, auth_code)
	q=<<~HEREDOC
	POST /dir#{folder} HTTP/1.1\r
	Authorization: #{auth_code}\r\n\r\n
	HEREDOC
	return q
end 

###TODO   uwazac na content length 
def postFileRequest(auth_code, file, content)
	
end 


if __FILE__ == $0

end



