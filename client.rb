require './simpleswitch'
after_connect = lambda do |this|
  loop do
    msg = gets.chomp
    if msg == "mail"
      this.message.body = { "+end" => this.modulus.sha1, "+getmail" => true }
      this.message.send_message
      next
    end
    this.message.body = { "+end" => this.modulus.sha1, "+body" => msg }
    this.message.send_message
  end
end
switch = Switch.new("host" => "nostat.us", "after_connect" => after_connect)
switch.start_udpserver
