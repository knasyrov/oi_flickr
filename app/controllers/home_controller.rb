class HomeController < ApplicationController
  def index
  end

  def search
    if @keyword = params[:keyword]
      search = $flickr.search(@keyword)
      search.callback do |list|
        render json: list
        EM::next_tick {
          request.env['async.callback'].call(response)
        }
      end
      search.errback do |error|
        render :json => error, :status => :unprocessable_entity
        EM::next_tick {
          request.env['async.callback'].call(response)
        }
      end
    else
      render :json => 'Не указано ключевое слово', :status => :unprocessable_entity
    end   
    throw :async  
  end

end
