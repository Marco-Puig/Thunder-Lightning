module Battle
  module Effects
    # SmackDown Effect
    class SmackDown < PokemonTiedEffectBase
      # Get the name of the effect
      # @return [Symbol]
      def name
        return :smack_down
      end
    end
  end
end
