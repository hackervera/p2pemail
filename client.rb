require './simpleswitch'
require './email_db'
require 'yaml'
config = YAML::load_file('server.config')
  mail = Database.new
  message = nil
  modulus = mail.modulus
  server = config['server']

Shoes.app :width => 1000, :title => "P2P Mail" do
  p "MODULUS: #{modulus}"
  @outgoing = flow :width => 400
  flow :width => 100
  @incoming = flow :width => 500
  
  @outgoing_stack = @outgoing.stack :width => 400
  @incoming_stack = @incoming.stack :height => 300, :scroll => true
  @mailbutton_stack = @incoming.stack
  @messages = @incoming_stack.para "test"
  @incomingmessage_stack = @incoming_stack.stack
  
  @outgoing_flow_to = @outgoing_stack.flow
  @outgoing_flow_body = @outgoing_stack.flow
  @outgoing_flow_to.inscription "TO:  "
  @outgoing_flow_body.inscription "BODY:  "
  @to_address = @outgoing_flow_to.edit_line :width => 350
  @message_entry = @outgoing_stack.edit_box :width => 400
  @send_button = @outgoing_stack.button "Send message"
  @getmail_button = @mailbutton_stack.button "Get mail"
  @send_button.click do
   p message
    message.body = { "+end" => @to_address.text, "+body" => @message_entry.text, "+from" => modulus.sha1 }
    message.send_message
    @message_entry.text = ""
    @message_entry.focus
  end
  @getmail_button.click do
    @messages.text = "Retrieving messages..."
    message.body = { "+getmail" => true, "+end" => modulus.to_s.sha1, "+from" => modulus.to_s.sha1, "_hop" => 1}
    message.send_message
  end
  

  after_connect = lambda do |this|
    message = this.message
    this.message.body = { ".tap" => [ { "is" => modulus.sha1 } ] }
    this.message.send_message
    p "modulus: #{modulus}"
    this.message.body = {"+end" => modulus.sha1, "+getmail" => true }
    this.message.send_message
    if server
      this.message.body= {"+end" => server, "+newhost" => modulus.to_s.sha1 }
      this.message.send_message
    end
  end


  response_callback = lambda do |msg|
    p "Just received: #{msg}"
    if msg.has_key?("+callback") && msg["+end"] == modulus.sha1
      text = msg["+callback"].map do |mail_item|
        "FROM: #{mail_item["from"]}\n Message: #{mail_item["message"]}\n Timestamp: #{mail_item["time"]}"
      end.reverse
        @messages.text = text.join "\n\n"
    end
  end
  
    switch = Switch.new("host" => "nostat.us", "after_connect" => after_connect, "response_callback" => response_callback)

  Thread.new do
    switch.start_udpserver
  end
  stack
  para "\n\nYour address is:\n"
  @mycode = edit_line :width => "350", :align => "center"
  @mycode.text = "#{modulus.to_s.sha1}"
  @friends = para 
  @friends.text = "(give this to your friends)"



end


