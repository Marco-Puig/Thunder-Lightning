module Battle
  module Effects
    module Mechanics
      module Disturbable
        # Make the move disturbed
        def disturb
          @disturbed = true
        end

        # Tell if the move has been disturbed
        # @return [Boolean]
        def disturbed?
          @disturbed
        end

        private

        # Create a new Forced next move effect
        # @param move [Battle::Move]
        # @param counter [Integer] number of turn the move is forced to be used
        # @param targets [Array<PFM::PokemonBattler>]
        def init_disturbable()
          @disturbed = false
        end
      end
    end
  end
end
