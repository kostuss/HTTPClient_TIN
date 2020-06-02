##Module for handling communication with the user##
class UserInterface

  def initialize(io=$stdout)
    @io = io
  end

  def welcome
    @io.puts <<~TEXT
    This is administrator site. 
    You can see all available options by typing help.
    TEXT
  end

  def printHelp
    @io.puts <<~TEXT 
    List of available options: 
    1.  login        - Login to the server
    2.  logout       - Logout from the server
    3.  prolong      - Prolong session
    4.  lsusr {id}   - Check all users or one if parameter provided 
    5.  addusr       - Add new user
    6.  rmusr {id}   - Delete user with id given as parameter
    7.  chngusr {id} - Change user with id given as parameter
    8.  ls {dir}     - Check conntent of the server. Do not type path for seeing root
    9.  exit         - Exit from the program
    10. help         - See all available options
    Choose option by typing the command
    TEXT
  end

  def printDir(resp)
    puts "Name".ljust(15)+"Type".ljust(15)+"Size".ljust(15)
    out=JSON.parse(resp)
    out.each  { |hash1| puts hash1["name"].to_s.ljust(15)+hash1["type"].to_s.ljust(15)+hash1["size"].to_s }
  end

  def printUsers(resp)
    out=JSON.parse(resp)
    puts "id".ljust(5)+"username".ljust(15)+"first name".ljust(15)+"second name".ljust(15)+"role"
    out.each  { |hash1| puts hash1["id"].to_s.ljust(5)+hash1["username"].to_s.ljust(15)+hash1["first_name"].to_s.ljust(15)+hash1["last_name"].to_s.ljust(15)+hash1["role"].to_s }
  end

  def printOneUser(resp, id)
    out=JSON.parse(resp)
    puts "id".ljust(5)+"username".ljust(15)+"first name".ljust(15)+"second name".ljust(15)+"role"
    out.each  { |hash1| puts hash1["id"].to_s.ljust(5)+hash1["username"].to_s.ljust(15)+hash1["first_name"].to_s.ljust(15)+hash1["last_name"].to_s.ljust(15)+hash1["role"].to_s if hash1["id"].to_s ==id }
  end

  def logIn
    @io.print "Login to the server with administrator credentials\nUsername: "
    username=gets.chomp
    @io.print "Password: "
    password=gets.chomp

    return username, password
  end

  def createUser
    credentials=[]
    @io.print "Give credentials of the user you want to create or change.\nUsername: " 
    loop do
      credentials[0]=gets.chomp
      if credentials[0]!=''
        break
        puts "You must give value!"  
      end
    end
    @io.print "Password: "
    loop do
      credentials[1]=gets.chomp
      if credentials[1]!=''
        break
        puts "You must give value!"  
      end
    end
    @io.print "First name: "
    loop do
      credentials[2]=gets.chomp
      if credentials[2]!=''
        break
        puts "You must give value!"  
      end
    end
    @io.print "Last name: "
    loop do
      credentials[3]=gets.chomp
      if credentials[3]!=''
        break
        puts "You must give value!"  
      end
    end
    
    loop do
      @io.print "Role of user (1-user 2-admin): "
      credentials[4]=gets.chomp
      if ['1','2'].include?(credentials[4])
        break
      end
    end
    return credentials
  end

  def changeUser
    credentials=[]
    @io.print "Give credentials of the user you want to change if not press enter.\nUsername: " 
    credentials[0]=gets.chomp
    @io.print "Password: "
    credentials[1]=gets.chomp
    @io.print "First name: "
    credentials[2]=gets.chomp
    @io.print "Last name: "
    credentials[3]=gets.chomp
    loop do
      @io.print "Role of user (1-user 2-admin): "
      credentials[4]=gets.chomp
      if ['1','2',''].include?(credentials[4])
        break
      end
    end 
    return credentials
  end

end

if __FILE__ == $0
  interface = UserInterface.new
  interface.changeUser
end
