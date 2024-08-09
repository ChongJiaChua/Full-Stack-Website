def validate_email(email)
  # Check for email format
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  return "Email cannot be empty." if email.empty?
  return "Invalid email format." unless email.match?(email_regex)
 
  return true 
end


get "/admin_settings" do

  @form_was_submitted = !params.empty?
  @submission_error = false
  redirect "/login" unless session["logged_in"]
  erb :admin_settings

end


post "/admin_settings" do
  
  redirect "/login" unless session["logged_in"]

  old_username = params[:old_username].strip
  new_username = params[:new_username].strip
  new_email = params[:new_email].strip

  user = User.first(user_name: old_username)

  errors = {}

  email_error = validate_email(new_email)
  errors[:email] = email_error if email_error != true 

  #change the users email as long as the formatting is still correct

  if errors.empty?
    user.email = new_email unless new_email.empty?
    user.save_changes
  else
    redirect "admin_settings"
  end

  #if successful, redirects back to the dashboard, otherwise it prints errors
  if user.save
    redirect "/adminDashboard"
  else
    @submission_error = true
    erb :admin_settings, locals: {error_message: "Failed to update settings.", errors: errors}
  end
end





  