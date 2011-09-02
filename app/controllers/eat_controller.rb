class EatController < ApplicationController

  def food
    Resque.enqueue(Eat, params[:food])
    Emailer.contact.deliver('foo@bar.com', 'food', params[:food])
    $redis.set('most_recent_food', params[:food])
    render :text => "Put #{params[:food]} in fridge to eat later."
  end

end
