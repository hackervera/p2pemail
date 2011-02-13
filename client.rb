require './simpleswitch'

extra_code = lambda do |this|
  loop do
    msg = gets
    this.message.body = { "+end" => this.modulus.sha1, "+body" => msg.chomp }
    this.message.send_message
  end
end
switch = Switch.new("host" => "nostat.us", "extra_code" => extra_code)
switch.start_udpserver
