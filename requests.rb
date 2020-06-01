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

	body={:username => credentials[0], :password => credentials[1], :first_name => credentials[2], :last_name => credentials[3], :role => credentials[4]}.to_json
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

	body={:username => credentials[0], :password => credentials[1], :first_name => credentials[2], :last_name => credentials[3], :role => credentials[4]}.to_json
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

def getUserRequest(auth_code)
	q=<<~HEREDOC
	GET /users?limit=3&offset=2 HTTP/1.1\r
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



