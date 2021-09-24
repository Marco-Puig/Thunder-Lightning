module Battle
  class Visual
    # Variable giving the position of the battlers to show from bank 0 in bag UI
    BAG_PARTY_POSITIONS = 0..5
    # Method that show the item choice
    # @return [Array<Integer, PFM::PokemonBattler>, nil]
    def show_item_choice
      Graphics.freeze
      @battle_scene.message_window.visible = false
      party = BAG_PARTY_POSITIONS.collect { |i| @battle_scene.logic.battler(0, i) }
      party.compact!
      scene = GamePlay::Battle_Bag.new(party)
      scene.main
      return_data = scene.return_data
      log_debug("Bag returned #{return_data}")
      @battle_scene.message_window.visible = true
      Graphics.transition
      return nil
    end

    # Method that show the pokemon choice
    # @return [PFM::PokemonBattler, nil]
    def show_pokemon_choice

      return nil
    end
  end
end
