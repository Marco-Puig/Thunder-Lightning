module Battle
  module Effects
    class Item
      class AirBalloon < Item
        # Function called after damages were applied (post_damage, when target is still alive)
        # @param handler [Battle::Logic::DamageHandler]
        # @param hp [Integer] number of hp (damage) dealt
        # @param target [PFM::PokemonBattler]
        # @param launcher [PFM::PokemonBattler, nil] Potential launcher of a move
        # @param skill [Battle::Move, nil] Potential move used
        def on_post_damage(handler, hp, target, launcher, skill)
          return if target != @target

          handler.scene.display_message_and_wait(parse_text_with_pokemon(19, 411, target))
          handler.logic.item_change_handler.change_item(:none, true, target)
        end
      end
      register(:air_balloon, AirBalloon)
    end
  end
end
