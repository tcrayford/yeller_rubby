class BrokenController < ApplicationController
  def index
    raise 'error'
  end
end
