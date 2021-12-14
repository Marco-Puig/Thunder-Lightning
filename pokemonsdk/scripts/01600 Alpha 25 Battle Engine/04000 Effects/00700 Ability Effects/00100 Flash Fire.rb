module Battle
  module Effects
    class Ability
      class FlashFire < Ability
        # Function called when a damage_prevention is checked
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        # @return [:prevent, Integer, nil] :prevent if the damage cannot be applied, Integer if the hp variable should be updated
        def on_damage_prevention(handler, hp, target, launcher, skill)
          return if target != @target
          return unless skill&.type_fire?
          return unless launcher&.can_be_lowered_or_canceled?

          return handler.prevent_change do
            handler.scene.visual.show_ability(target) if target.frozen? || !@boost_enabled
            handler.logic.status_change_handler.status_change_with_process(:cure, target) if target.frozen?
            @boost_enabled = true
          end
        end

        # Give the move mod1 mutiplier (before the +2 in the formula)
        # @param user [PFM::PokemonBattler] user of the move
        # @param target [PFM::PokemonBattler] target of the move
        # @param move [Battle::Move] move
        # @return [Float, Integer] multiplier
        def mod1_multiplier(user, target, move)
          return 1 if user != @target || !@boost_enabled

          return move.type_fire? ? 1.5 : 0
        end

        # Reset the boost when leaving battle
        def reset
          @boost_enabled = false
        end
      end
      register(:flash_fire, FlashFire)
    end
  end
end

Hooks.register(PFM::PokemonBattler, :on_reset_states, 'PSDK reset FlashFire') do
  ability_effect.reset if ability_effect.is_a?(Battle::Effects::Ability::FlashFire)
end
