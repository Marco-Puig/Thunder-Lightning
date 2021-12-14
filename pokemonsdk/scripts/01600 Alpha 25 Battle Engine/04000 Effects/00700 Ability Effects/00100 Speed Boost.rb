module Battle
  module Effects
    class Ability
      class SpeedBoost < Ability
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(@target)

          if logic.stat_change_handler.stat_increasable?(:spd, @target)
            scene.visual.show_ability(@target)
            logic.stat_change_handler.stat_change_with_process(:spd, 1, @target)
          end
        end
      end
      register(:speed_boost, SpeedBoost)
    end
  end
end
