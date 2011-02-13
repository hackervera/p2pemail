require './simpleswitch'


response_callback = lambda do |msg|
  p "Got your message: #{msg["+body"]}"
end

request = lambda do |this|
  p this.modulus.sha1
  this.request("+end" => this.modulus.sha1)
end
  

switch = Switch.new(
          "response_callback"=>response_callback, 
          "host" => "nostat.us",
          "request" => request
          )
switch.start_udpserver
