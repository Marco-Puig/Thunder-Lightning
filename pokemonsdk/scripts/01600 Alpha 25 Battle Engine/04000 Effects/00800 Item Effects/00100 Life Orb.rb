module Battle
  module Effects
    class Item
      class LifeOrb < Item
        # Give the move mod1 mutiplier (after the critical)
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def mod2_multiplier(user, target, move)
          return 1 if user != @target

          return 1.3
        end

        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(@target)

          # Check if target hitted and dealt damage the current turn
          check = @target.move_history.last&.current_turn? && @target.move_history.last&.targets.any? { |target| 
            target.last_hit_by_move&.id == @target.move_history.last.move.id
          }
          return if !check || @target.has_ability?(:magic_guard)

          scene.display_message_and_wait(parse_text_with_pokemon(19, 1044, @target, PFM::Text::ITEM2[1] => @target.item_name))
          logic.damage_handler.damage_change((@target.max_hp / 10).clamp(1, Float::INFINITY), @target)
        end
      end
      register(:life_orb, LifeOrb)
    end
  end
end
