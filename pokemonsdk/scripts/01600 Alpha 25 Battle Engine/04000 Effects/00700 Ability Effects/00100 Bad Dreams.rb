module Battle
  module Effects
    class Ability
      class BadDreams < Ability
        # Function called at the end of a turn
        # @param logic [Battle::Logic] logic of the battle
        # @param scene [Battle::Scene] battle scene
        # @param battlers [Array<PFM::PokemonBattler>] all alive battlers
        def on_end_turn_event(logic, scene, battlers)
          return unless battlers.include?(@target)

          sleeping_foes = logic.foes_of(@target).select(&:asleep?)
          scene.visual.show_ability(@target) if sleeping_foes.any?
          sleeping_foes.each do |sleeping_foe|
            hp = sleeping_foe.max_hp / 8
            logic.damage_handler.damage_change(hp.clamp(1, Float::INFINITY), @target)
          end
        end
      end
      register(:bad_dreams, BadDreams)
    end
  end
end
