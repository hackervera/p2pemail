if not RUBY_VERSION =~ /1.9/
  abort "You need ruby version 1.9"
end
require './simpleswitch'
require './email_db'
Thread.abort_on_exception = true
#TODO create config file for server values
mail = Database.new
message = nil
socket = nil
modulus = mail.modulus
response_callback = lambda do |msg|
  p "Got your message: #{msg["+body"]}"
  if msg.has_key? "+body"
    mail.save_message(msg["+from"],msg["+body"],Time.now)
    return
  elsif msg.has_key? "+getmail"
    p "modulus: #{modulus}"
    message.body = { "+callback" => mail.mail(msg["+end"]), "+end" => msg["+end"] }
    message.send_message
  elsif msg.has_key? "+newhost"
    mail.add_host(msg["+newhost"])
  end
end

after_connect = lambda do |this|
  this.request("+end" => modulus.to_s.sha1)
  this.request("has" => "+body")
  this.request("has" => "+newhost", "+end" => modulus.to_s.sha1)
  mail.hosts.each do |host|
    this.request("+end" => host.first)
  end
  socket = this
  message = this.message
end
  

switch = Switch.new(
          "response_callback"=>response_callback, 
          "host" => "nostat.us",
          "after_connect" => after_connect
          )
Thread.new do
  switch.start_udpserver
end
sleep 5000000
