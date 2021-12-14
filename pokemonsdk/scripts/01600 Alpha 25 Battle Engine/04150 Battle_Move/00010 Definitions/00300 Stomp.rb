module Battle
  class Move
    class Stomp < Basic
      # Get the real base power of the move (taking in account all parameter)
      # @param user [PFM::PokemonBattler] user of the move
      # @param target [PFM::PokemonBattler] target of the move
      # @return [Integer]
      def real_base_power(user, target)
        return super * 2 if target.effects.has?(:minimize)

        return super
      end

      # Return the chance of hit of the move
      # @return [Float]
      def chance_of_hit(user, target)
        return 100 if target.effects.has?(:minimize)

        super
      end
    end

    Move.register(:s_stomp, Stomp)
  end
end
