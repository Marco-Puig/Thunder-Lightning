module Battle
  module AI
    class Base
      # Function returning pokemon to switch with on request
      # @param who [PFM::PokemonBattler]
      # @return [PFM::PokemonBattler, nil]
      def request_switch(who)
        actions = switch_actions_generate_for(who)
        return nil if actions.empty?

        best = actions.compact.shuffle(random: @scene.logic.generic_rng).max_by(&:first)
        Debug::AiWindow.append(self, actions.compact) if defined?(Debug::AiWindow)
        return best.last.with
      end

      private

      # Generate the switch action for the pokemon
      # @param pokemon [PFM::PokemonBattler]
      # @param move_heuristics [Array<Float>]
      # @return [Array<[Float, Actions::Switch]>]
      def switch_actions_for(pokemon, move_heuristics)
        return [] unless @scene.logic.switch_handler.can_switch?(pokemon)

        danger_factor = switch_danger_processing(pokemon)
        return [] if move_heuristics.max < danger_factor

        return switch_actions_generate_for(pokemon)
      end

      # Generate the actual switch actions for the pokemon
      # @param pokemon [PFM::PokemonBattler]
      # @return [Array<[Float, Actions::Switch]>]
      def switch_actions_generate_for(pokemon)
        switchable = (party - [pokemon] - @scene.logic.allies_of(pokemon)).select(&:alive?)
        return switchable.map do |battler|
          [
            usable_moves(battler).map { |move| move_action_for(move, battler) }.compact.map(&:first).max || 0,
            Actions::Switch.new(@scene, pokemon, battler)
          ]
        end
      end

      # Get the danger factor of the Pokemon (depending on opponent)
      # @param pokemon [PFM::PokemonBattler]
      # @return [Float]
      def switch_danger_processing(pokemon)
        foe_moves = switch_opponent_moves(pokemon)
        foe_move_heuristics = foe_moves.map { |info| move_heuristic(info[:move], info[:foe], pokemon) }
        return foe_move_heuristics.max || @scene.logic.generic_rng.rand
      end

      # Get the opponent moves in order to choose if we switch or not
      # @param pokemon [PFM::PokemonBattler]
      # @return [Array<{ foe: PFM::PokemonBattler, move: Battle::Move }>]
      def switch_opponent_moves(pokemon)
        return [] unless @can_read_opponent_movepool

        return @scene.logic.foes_of(pokemon).flat_map do |foe|
          foe.move_history.map(&:move).uniq(&:db_symbol).map do |move|
            { foe: foe, move: move }
          end
        end
      end
    end
  end
end
