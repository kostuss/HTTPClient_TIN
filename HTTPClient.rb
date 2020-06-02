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
		rescue Errno::ENETUNREACH, RuntimeError => e
			choice=handleException(e)
			retry if choice==1

			if choice==-1
				puts "Try connecting later"
			else
				raise "Undefined error with the program"
			end					
		end
	end

	def prolongCheck
		left=@communication.remaining_time
		if left<300
			puts "Remaining session time: #{left.round(0)} seconds"
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
			if input.length()==2
				parameter=input[1]
			end

			if command=='help' and input.length==1
				@interface.printHelp

			elsif command=='login' and input.length==1
				username, password = @interface.logIn
				#@communication.authorize("superuser","AdMiNiStRaToR1@3")
				status=@communication.authorize(username,password)
				if status=='200'
					puts "User #{username} logged successfully."
				else
					puts "Try logging again"
				end

			elsif command=='logout' and input.length==1
				@communication.logOut
				puts "Logged out"

			elsif command=='prolong' and input.length==1
				resp=@communication.prolong
				if resp=='200'
					puts "Session prolonged."
				else
					puts "Try logging again"
				end
						
			elsif command=='lsusr' and (input.length==1 or (input.length==2 and /\A\d+\z/.match(parameter)))
				resp=@communication.getUsers
				if resp[0]=='200'
					if input.length==1
						@interface.printUsers(resp[1])
					else
						@interface.printOneUser(resp[1],parameter)
					end
					prolongCheck()
						
				elsif resp[0]=='401'
					puts "Login as administrator."
				elsif resp[0]=='404'
					puts "Not found"
				else
					puts resp[0]+"Something went wrong"
				end
					
				
			elsif command=='addusr' and input.length==1
				credentials=@interface.createUser
				resp=@communication.createUser(credentials)
				if resp=='200'
					puts "User #{credentials[0]} created"
					prolongCheck
				elsif resp == '400'
					puts "Give valid credentails"
				elsif resp=='401'
					puts "Login as administrator."
				elsif resp=='404'
					puts "Not found"
				else
					puts resp+"Something went wrong"
				end

			elsif command=='chngusr'
				if not (input.length==2 and /\A\d+\z/.match(parameter))
					puts "You must give id of the user"
					next
				end
				credentials=@interface.changeUser
				resp=@communication.changeUser(parameter,credentials)

				if resp=='200'
					puts "User changed"
					prolongCheck()
				elsif resp=='401'
					puts "Login as administrator."
				elsif resp=='404'
					puts "Check the users with lsusr"
				else
					puts resp+"Something went wrong"
				end

			elsif command=='rmusr'
				if not (input.length==2 and /\A\d+\z/.match(parameter))
					puts "You must give id of the user"
					next
				end
				resp=@communication.deleteUser(parameter)
				if resp=='200'
					puts "User deleted"
					prolongCheck
				elsif resp=='401'
					puts "Login as administrator."
				elsif resp=='404'
					puts "Not found"
				else
					puts resp+"Something went wrong"
				end

			elsif command=='ls' and [1,2].include?(input.length)
				
				resp=@communication.getDir(parameter)

				if resp[0]=='200'
					@interface.printDir(resp[1])
					prolongCheck()
				elsif resp[0]=='401'
					puts "Login as administrator."
				elsif resp[0]=='404'
					puts "Not found"
				else
					puts resp[0]+"Something went wrong"
				end

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

