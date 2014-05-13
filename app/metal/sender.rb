require 'sinatra/async'

class Sender < Sinatra::Base
  register Sinatra::Async

  aget '/sendds' do
    body "hello async"
  end

  aget '/send' do
=begin    
    EM.add_timer(5) do 
      body 'delayed 5 seconds'
    end   
=end
n = 0
timer = EventMachine::PeriodicTimer.new(5) do
  body "the time is #{Time.now}"
  timer.cancel if (n+=1) > 5
end    
  end

end