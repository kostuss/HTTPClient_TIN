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
    1. login        - Login to the server
    2. logout       - Logout from the server
    3. lsusr        - Check all users
    4. addusr       - Add new user
    5. rmusr {id}   - Delete user with id given as parameter
    6. chngusr {id} - Change user with id given as parameter
    7. ls {dir}     - Check conntent of the server. "/" for seeing root
    8. exit         - Exit from the program
    9. help         - See all available options
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

  def logIn
    @io.print "Login to the server with administrator credentials\nUsername: "
    username=gets.chomp
    @io.print "Password: "
    password=gets.chomp

    return username, password
  end

  def createUser
    @io.print "Give credentials of the user you want to create or change.\nUsername: " 
    username=gets.chomp
    @io.print "Password: "
    password=gets.chomp
    @io.print "First name: "
    first=gets.chomp
    @io.print "Last name: "
    last=gets.chomp
    role="None"
    loop do
      @io.print "Role of user (1-user 2-admin): "
      role=gets.chomp
      if ['1','2'].include?(role)
        break
      end
    end
    return username, password, first, last, role
  end

end

if __FILE__ == $0
  
end
