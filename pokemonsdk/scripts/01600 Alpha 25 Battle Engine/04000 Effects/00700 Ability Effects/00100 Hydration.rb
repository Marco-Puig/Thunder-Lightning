module Battle
  module Effects
    class Ability
      class Hydration < Ability
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(@target) && $env.rain?

          original_form = @target.form
          @target.form_calibrate
          scene.visual.show_switch_form_animation(@target) if @target.form != original_form
        end
      end
      register(:hydration, Hydration)
    end
  end
end
