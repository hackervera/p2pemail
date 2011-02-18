if not RUBY_VERSION =~ /1.9/
  abort "You need ruby version 1.9 or above"
end
require './simpleswitch'
require './email_db'
#TODO create config file for server values
mail = Database.new
modulus = nil
message = nil
response_callback = lambda do |msg|
  p "Got your message: #{msg["+body"]}"
  if msg.has_key? "+body"
    mail.save_message(modulus,msg["+body"],"Now")
    return
  end
  if msg.has_key? "+getmail"
    p mail.get_mail_for_user(modulus)
    message.body = { "+#{msg["+callback"]}" => true, "+body" => mail.get_mail_for_user(modulus) }
    message.send_message
  end
end

after_connect = lambda do |this|
  modulus = this.modulus.sha1
  this.request("+end" => this.modulus.sha1)
  message = this.message
end
  

switch = Switch.new(
          "response_callback"=>response_callback, 
          "host" => "nostat.us",
          "after_connect" => after_connect
          )
switch.start_udpserver
