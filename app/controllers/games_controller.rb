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
    @game = Game.find(params[:id], include: { map: [:hexes, :nodes, :edges], players: [:user, :cards] })
    @player = @game.players.find_by_user_id(current_user.try(:id))
    respond_to do |format|
      format.html
      format.json do
        nodes = @game.map_nodes.map do |node|
          { position: node.position,
            playerId: node.player_id,
            state: node.state }
        end
        edges = @game.map_edges.map do |edge|
          { position: edge.position,
            playerId: edge.player_id }
        end
        players = @game.players.map do |player|
          { id: player.id,
            number: player.number,
            points: player.visible_points,
            resources: player.resources,
            name: player.user_login,
            idleTime: player.idle_time }
        end
        hexes = @game.map_hexes.map do |hex|
          { type: hex.hex_type,
            position: hex.position,
            harborPosition: hex.harbor_position,
            harborType: hex.harbor_type }
        end
        if @player
          cards = @player.cards.map do |card|
            { id: card.id,
              type: card.type,
              state: card.state }
          end
        end
        game = {
          map: {
            size: @game.map_size,
            hexes: hexes,
            nodes: nodes,
            edges: edges,
            robberPosition: @game.map_robber_position,
          },
          player: {
            id: @player.id,
            bricks: @player.bricks,
            grain: @player.grain,
            lumber: @player.lumber,
            ore: @player.ore,
            wool: @player.wool,
            settlements: @player.settlements,
            cities: @player.cities,
            roads: @player.roads,
            state: @player.state,
            visiblePoints: @player.visible_points,
            hiddenPoints: @player.hidden_points,
            bricksExchangeRate: @player.bricks_exchange_rate,
            grainExchangeRate: @player.grain_exchange_rate,
            lumberExchangeRate: @player.lumber_exchange_rate,
            oreExchangeRate: @player.ore_exchange_rate,
            woolExchangeRate: @player.wool_exchange_rate,
            cards: cards
          },
          players: players,
          id: @game.id,
          state: @game.state,
          phase: @game.phase,
          currentTurn: @game.current_turn,
          currentTurnCardPlayed: @game.current_turn_card_played,
          currentPlayerId: @game.current_player_id,
          cards: @game.cards_count
        }
        render :json => { game: game }
      end
    end
  end

  def update
    @game = Game.find(params[:id])
    @game.user = @current_user
    if @game.update_attributes(params[:game])
      flash[:success] = "Success"
    else
      flash[:error] = "Error"
    end
    redirect_to game_path(@game)
  end

  def end_turn
    @game = Game.find(params[:id])
    if @game.end_turn(@current_user)
      flash[:success] = "Success"
    else
      flash[:error] = "Error"
    end
    redirect_to game_path(@game)
  end
end
