get "/contact" do
    @form_was_submitted = !params.empty?
    @submission_error = nil
    @email_address_error = nil

    erb :contact
end

post "/contact" do

  #gets the email address and make sure it fits the correct email format

  @email_address = params.fetch("email_address", "").strip
  @email_address_error = "Please enter a valid email address" unless @email_address.match?(/\A\S+@\S+\Z/)


  @submission_error = "Please correct the errors below" unless @email_address_error.nil?

  if @submission_error.nil?
    @form_was_submitted = true
  end

  erb :contact 

end