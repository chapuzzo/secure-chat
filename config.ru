require File.join(File.dirname(__FILE__), 'chat.rb')
 
 map "/" do
   run Sinatra::Application
 end
