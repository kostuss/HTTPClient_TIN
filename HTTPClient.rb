##HTTPS Client application ##

require_relative 'SSLCommunication'
require_relative 'UserInterface'

class HTTPClient
	def initialize
		@communication=nil
		@interface=nil
	end

	def startClient
		begin
			@communication=SSLCommunication.new
			@interface=UserInterface.new
			@interface.welcome
			handleCommand
		rescue Errno::ENETUNREACH => e
			choice=handleException(e)
			retry if choice==1

			if choice==-1
				puts "Try connecting later"
			else
				raise "Undefined error with the program"
			end					
		end
	end

	def handleException(e)
		puts e
		puts "Do you want to try reconnecting?[y/n]: "
		loop do
			decision=gets.chomp
			if decision=='y'
				return 1
			elsif decision=='n'
				return -1
			else 
				puts "You need to choose [y/n]"
			end			
		end 
	end

	def handleCommand 
		loop do
			command=''
			parameter=''
			input=gets.chomp
			input=input.split(" ")
			command=input[0]
			if input.length()>1
				parameter=input[1]
			end

			if command=='help' and input.length==1
				@interface.printHelp

			elsif command=='login' and input.length==1
				username, password = @interface.logIn
				#@communication.authorize("superuser","AdMiNiStRaToR1@3")
				@communication.authorize(username,password)

			elsif command=='lsusr'
				resp=@communication.getUsers
				if resp==-1
					next
				end
				@interface.printUsers(resp)

			elsif command=='addusr' and input.length==1
				credentials=@interface.createUser
				@communication.createUser(credentials)

			elsif command=='chngusr'
				if not (input.length==2 and /\A\d+\z/.match(parameter))
					puts "You must give id of the user"
					next
				end
				credentials=@interface.createUser
				@communication.changeUser(parameter,credentials)

			elsif command=='rmusr'
				if not (input.length==2 and /\A\d+\z/.match(parameter))
					puts "You must give id of the user"
					next
				end
				@communication.deleteUser(parameter)

			elsif command=='ls' and [1,2].include?(input.length)
				
				resp=@communication.getDir(parameter)
				if resp==-1
					next
				end
				@interface.printDir(resp)

			elsif command=='exit'
				puts "Thanks for using the program"
				break	
			else
				puts "Undefined command"
		    end	
		end
	end
end

if __FILE__ == $0
  #client=HttpClient.new
  #client.startClient
end

