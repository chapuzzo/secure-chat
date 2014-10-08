# coding: utf-8
require 'sinatra'
# require 'sinatra/streaming'

set server: 'thin', connections: []

get '/' do
  halt erb(:login) unless params[:user]
  erb :chat, locals: { user: params[:user].gsub(/\W/, '') }
end

get '/stream', provides: 'text/event-stream' do
  stream :keep_open do |out|
    settings.connections << out
    mytimer = EventMachine::PeriodicTimer.new(20) {
      out << "\n"
    }

    out << "data: Bienvenid@\n\n"
    puts settings.connections.count # added

    out.callback { 
        # puts %q(deleting by callback)
        mytimer.cancel
        settings.connections.delete(out) 
    }
  end
end

post '/' do
  settings.connections.each { |out| out << "data: #{params[:msg]}\n\n" }
  204 # response without entity body
end

__END__

@@ layout
<html>
  <head> 
    <title>Super Simple Chat with Sinatra</title> 
    <meta charset="utf-8" />
    <script src="//ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"></script>
  </head> 
  <body><%= yield %></body>
</html>

@@ login
<form action='/'>
  <label for='user'>nickname:</label>
  <input name='user' value='' />
  <input type='submit' value="Entra!" />
</form>

@@ chat
<pre id='chat'></pre>


<script>
  // reading
  var es = new EventSource('/stream');
  es.onmessage = function(e) { 
    console.log(e);
    if (e.data != '')
      $('#chat').append(e.data + "\n") 
  };
  $(document).ready(function(){
    // writing
    $("form").on("submit",function(e) {
      console.log("sending");
      var sent = {msg: "<%= user %>: " + $('#msg').val()};
      console.log(sent);
      $.post('/', sent);
      $('#msg').val(''); 
      $('#msg').focus();
      e.preventDefault();
      console.log("sent");
      return false;
    });
    $('#msg').focus();
  });
</script>

<form>
  <input id='msg' placeholder='tu mensaje es ...' />
</form>