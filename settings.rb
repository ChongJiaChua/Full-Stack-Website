
def validate_password(password)

    # Check for more than 8 characters
    return "Password must be at least 8 characters long." if password.length < 8
   
    # Check for at least one number
    return "Password must contain at least one number." unless password.match?(/\d/)
    
    # Check for at least one special character
    special_characters = "!()*"
    special_character_regex = Regexp.new("[#{Regexp.quote(special_characters)}]")
    return "Password must contain a special character: #{special_characters}." unless password.match?(special_character_regex)

    true
   
end

def validate_email(email)
    # Check for valid email format
    email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    return "Email cannot be empty." if email.empty?
    return "Invalid email format." unless email.match?(email_regex)

    true
end


get "/settings" do

    @form_was_submitted = !params.empty?
    @submission_error = false
    @phone_number_error = nil
    @selected_language = params[:language] || 'en'
    @phone_number = params[:phone_number]
    redirect "/login" unless session["logged_in"]
    erb :settings
end


post "/settings" do
  redirect "/login" unless session["logged_in"]

  @user = session["user"]
  user = User.first(user_name: @user)


  @newUsername = params[:newUsername].to_s.strip
  @newPassword = params[:newPassword].to_s.strip
  @newEmail = params[:newEmail].to_s.strip
  @currentPassword = params[:currentPassword].to_s.strip
  @phone_number = params[:phone_number].to_s.strip
  @selected_language = params[:language].to_s
  @notifications = params[:yes_no].to_s

  errors = {}

  # Check for errors
  @password_error = validate_password(@newPassword)
  if @password_error != true
    errors[:password] = @password_error 
  else 
    @password_error = nil
  end

  @email_error = validate_email(@newEmail)
  if @email_error != true
    errors[:email] = @email_error 
  else
    @email_error = nil
  end

  @current_password_error = nil
  if user
    user.setIv(user.iv)
    user.setSalt(user.salt)
    user.setDataCrypt(user.password)

    # Checks whether the password entered matches the password in the database
    if !user.user_name.nil? && user.login({"password" => @currentPassword})
    else
      @current_password_error = "Your current password is incorrect."
      errors[:current_password] = @current_password_error
    end
  end

  # Update the fields in the database if there are no errors
  if errors.empty?
    success_encrypt = user.encrypt(params)
    if success_encrypt == true
      user.password = user.getDataCrypt() unless @newPassword.empty?
      user.email = @newEmail unless @newEmail.empty?
      user.iv = user.getIv()
      user.salt = user.getSalt()
      user.save_changes
      session["user"] = user.user_name
      redirect "/settings"
    else
      @submission_error = true
      @error_message = "Encryption error, please try again."
    end
  else
    @submission_error = true
  end

  erb :settings
end


    