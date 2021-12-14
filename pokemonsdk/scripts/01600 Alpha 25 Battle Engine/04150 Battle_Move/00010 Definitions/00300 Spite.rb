module Battle
  class Move
    class Spite < Move
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return false unless super

        if targets.all? { |target| target.skills_set[target.last_skill]&.pp == 0 }
          show_usage_failure(user)
          return false
        end

        return true
      end

      private

      # Function that deals the effect to the pokemon
      # @param user [PFM::PokemonBattler] user of the move
      # @param actual_targets [Array<PFM::PokemonBattler>] targets that will be affected by the move
      def deal_effect(user, actual_targets)
        actual_targets.each do |target|
          next unless target.last_skill && target.skills_set[target.last_skill].pp > 0

          num = logic.generic_rng.rand(2..5)
          target.skills_set[target.last_skill].pp -= num
          scene.display_message_and_wait(parse_text_with_pokemon(19, 641, target, PFM::Text::MOVE[1] => name, '[VAR NUM1(0002)]' => num))
        end
      end
    end
    Move.register(:s_spite, Spite)
  end
end
