class HomeController < ApplicationController

  def index
  end

  def search
    if @keyword = params[:keyword]
      @list = Flickr.search @keyword
    end
    render json: @list
  rescue Exception => e
    render json: 'Internal Error', status: :unprocessable_entity
  end
end
