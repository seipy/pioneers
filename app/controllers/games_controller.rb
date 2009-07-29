# -*- coding: utf-8 -*-

# Pioneers - web game based on the Settlers of Catan board game.
#
# Copyright (C) 2009 Jakub Kuźma <qoobaa@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

class GamesController < ApplicationController
  before_filter :require_user, :except => [:index, :show]

  def index
    @games = Game.all
  end

  def show
    @game = Game.find(params[:id], include: { board: [:hexes, :nodes, :edges], players: [:user, :cards] })
    @user_player = @game.players.find_by_user_id(current_user.try(:id))
    respond_to do |format|
      format.html
      format.json do
        render :json => { :game => game }
      end
    end
  end

  def update
    @game = Game.find(params[:id])
    @game.user = @current_user
    if @game.end_turn
      # stomp_send(@game, { :game => game })
      # render :nothing => true, :status => :created
      # render :nothing => true, :status => :created
      render :json => { :game => game }
    else
      render :nothing => true, :status => :unprocessable_entity
    end
  end
end
