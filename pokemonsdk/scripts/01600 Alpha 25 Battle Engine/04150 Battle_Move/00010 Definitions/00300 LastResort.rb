module Battle
  class Move
    class LastResort < Basic
      # Function that tests if the user is able to use the move
      # @param user [PFM::PokemonBattler] user of the move
      # @param targets [Array<PFM::PokemonBattler>] expected targets
      # @note Thing that prevents the move from being used should be defined by :move_prevention_user Hook
      # @return [Boolean] if the procedure can continue
      def move_usable_by_user(user, targets)
        return failure(user) unless user.moveset.map(&:db_symbol).include?(:last_resort)
        return failure(user) if user.moveset.size == 1
        return failure(user) unless user.move_history.flat_map(&:move).flat_map(&:db_symbol).uniq.size >= 1

        return super
      end

      # Display the usage failure message and return false
      # @param user [PFM::PokemonBattler]
      # @return [false]
      def failure(user)
        show_usage_failure(user)
        return false
      end
    end
    Move.register(:s_last_resort, LastResort)
  end
end
