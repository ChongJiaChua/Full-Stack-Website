
@login_error = ""
@register_error = ""
#used to create error messsage
temp = ""
def generate_creator_code
  code = ""
  6.times do
    code += ('A'..'Z').to_a.sample
  end
  code
end

def unique_creator_code
  loop do
    code = generate_creator_code
    return code unless User.first(creator_code: code)
  end
end

def username_valid_check()
  #checks if username is unique
  user = User.first(user_name: @new_username)
  if (user == nil) then
    return true
  else
    return false
  end
end



#Loads the initial view
get "/login" do
  erb :login
end

#Runs when the user submits the login form
post "/login" do
  @username = params.fetch("username","").strip
  @password = params.fetch("password","").strip
  #Finds the user in the database
  user = User.first(user_name: @username)
  banned_user = Banneduser.first(banned_user: @username)
  
  if (banned_user != nil) then
    @loginError = "Your account has been banned"

  elsif (user != nil) then
    user.setIv(user.iv)
    user.setSalt(user.salt)
    user.setDataCrypt(user.password)

    #checks if password is the same as in the database
    if (user.user_name.nil? == false && user.login(params) == true) then
      session["logged_in"] = true
      session["user"] = @username
      $choice = rand(10)
      
      if user.freepopcorn_date
        @last_update_date = Date.parse(user.freepopcorn_date)
        @current_date = Date.today
        
        # Calculate month difference between the date today and date in database
        month_difference = (@current_date.year * 12 + @current_date.month) - (@last_update_date.year * 12 + @last_update_date.month)
        if month_difference >= 1
        premium_num = user.premium
        user.popcorn = user.popcorn + (month_difference*10) + (premium_num*500) #Add popcorn to user
        user.freepopcorn_date = @current_date.to_s
        user.save_changes
        end
      end
      redirect "/"
    end
  end

  @login_error = "Username or Password is incorrect. Please try again."
  if (banned_user != nil) then
    @login_error = "Your account has been banned"
  end
  erb :login
end

#Runs when the user submits the register form
post "/register" do
  $crypter = User.new
  #long term flag to see if whole password is valid
  valid_pass_num_flag = false
  valid_pass_spec_flag = false
  
  @new_username = params.fetch("newUsername", "").strip
  @new_password = params.fetch("newPassword","").strip
  @new_email = params.fetch("newEmail","").strip
  if (@new_username == "" || @new_password == "" || @new_email == "") then
    erb:login
  end
  temp = ""
  user_unique = username_valid_check()
  #check username for numbers
  user_valid_num = true
  i = 0
  while user_valid_num == true && i < @new_username.length() do
    begin
      check = @new_username[i].to_i
      #to_i returns 0 if the character is a character rather than a number
      if (check != 0) then
        #forces an exception into the rescue code
        exception = 5/0
      end
      user_valid_num = true
    rescue
      user_valid_num = false
    end
    i += 1
  end
  #length check
  if (@new_password.length < 8) then
    temp = temp + "\n" + "Password is too short."
  end
  x = 0
  #short term flag to see if a character is valid
  pass_valid_num = false
  pass_valid_spec = false
  #checks through whole password for numbers and special characters
  while x <= @new_password.length() do
    begin
      check = @new_password[x].to_i
      #to_i returns 0 if the character is a character rather than a number
      if (check == 0) then
        #forces an exception into the rescue code
        exception = 5/0
      end
      pass_valid_num = true
    rescue
      pass_valid_num = false
    end
    case @new_password[x]
    when "!","*","(",")"
      pass_valid_spec = true
    else
      pass_valid_spec = false
    end
    x +=1
    if (pass_valid_num == true) then
      valid_pass_num_flag = true
    end
    if (pass_valid_spec == true) then
      valid_pass_spec_flag = true
    end
  end

  
  valid_email = false
  #checks for valid email
  if (@new_email =~ /[a-z]+@[a-z]+\.[a-z]+/i ) then
    valid_email = true
  end

  #Adds error messages
  if (user_unique == false) then
    temp = temp + "\n" + "Username is already taken."
  end
  if (user_valid_num == false) then
    temp = temp + "\n" + "Username cannot contain a number."
  end
  if (valid_pass_num_flag == false) then
    temp = temp + "\n" + "Password does not contain a number."
  end
  if (valid_pass_spec_flag == false) then
    temp = temp + "\n" + "Password does not contain a special character."
  end
  if (valid_email == false) then
    temp = temp + "\n" + "Invalid Email."
  end

  creator_code = unique_creator_code

  #add username and password to database
  @account_type = "customer"
  if (valid_pass_num_flag == true && valid_pass_spec_flag == true && valid_email == true && user_valid_num == true && user_unique == true) then
    success_encrypt = $crypter.encrypt(params)
    if (success_encrypt == true) then
      $crypter.user_name = @new_username
      $crypter.account_type = @account_type
      $crypter.password = $crypter.getDataCrypt()
      $crypter.email = @new_email
      $crypter.popcorn = 0
      $crypter.compound = 1000.0
      $crypter.premium = 0
      $crypter.iv = $crypter.getIv()
      $crypter.salt = $crypter.getSalt()
      $crypter.creation_date = Date.today
      $crypter.freepopcorn_date = $crypter.creation_date
      $crypter.creator_code = creator_code
      $crypter.save_changes
    end
    if (success_encrypt == nil) then
      @error = "Encryption error, please try again."
      erb :login
    end

    session["logged_in"] = true
    session["user"] = @new_username

    #change redirect to dashboard
    redirect "/"
  end
  
  @register_error = temp
  erb :login
end