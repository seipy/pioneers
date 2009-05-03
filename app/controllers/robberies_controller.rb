class RobberiesController < ApplicationController
  before_filter :require_user, :fetch_game

  def create
    @robbery = @game.robberies.build(params[:robbery])
    @robbery.user = @current_user
    if @robbery.save
      hex = {
        position: @robbery.position
      }
      stomp_send(@game, { event: "robberMoved", hex: hex })
      render :nothing => true, :status => :created
    else
      render :nothing => true, :status => :unprocessable_entity
    end
  end

  protected

  def fetch_game
    @game = Game.find(params[:game_id])
  end
end
