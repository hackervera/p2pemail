require './simpleswitch'


Shoes.app do
  message = nil
  modulus = nil
  @stack = stack
  @entry = stack
  @edit = @entry.edit_box
  @button = @entry.button "Send message"
  @button.click do
    message.body = { "+end" => modulus.sha1, "+body" => @edit.text }
    message.send_message
  end
  @stack.para "test"
  
  after_connect = lambda do |this|
    this.request("has" => ["+somerandomstring"])
    message = this.message
    modulus = this.modulus
    this.message.body = {"+end" => this.modulus.sha1, "+callback" => "somerandomstring", "+getmail" => true }
    this.message.send_message
  end

  response_callback = lambda do |msg|
    p "Just received: #{msg}"
    p msg.class
    msg.each do |thing|
      p thing
      @stack.para thing unless output.nil?
    end 
  end

  switch = Switch.new("host" => "nostat.us", "after_connect" => after_connect, "response_callback" => response_callback)

  Thread.new do
    switch.start_udpserver
  end

end


