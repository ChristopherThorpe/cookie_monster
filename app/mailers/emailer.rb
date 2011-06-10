class Emailer < ActionMailer::Base
  include Resque::Mailer

  default :from => "from@example.com"

  def contact(recipient, subject, message, sent_at = Time.now)
     @subject = subject
     @recipients = recipient
     @sent_on = sent_at
         @body["title"] = 'This is title'
         @body["email"] = 'sender@yourdomain.com'
         @body["message"] = message
     @headers = {}
  end

end
