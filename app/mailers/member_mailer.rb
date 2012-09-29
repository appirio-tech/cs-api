class MemberMailer < ActionMailer::Base
  default from: "CloudSpokes Team <support@cloudspokes.com>"
  
  def welcome_email(username, email)
    @username = username
    mail(:to => "#{username} <#{email}>", :subject => "Thank you for registering #{username}")
  end
  
end