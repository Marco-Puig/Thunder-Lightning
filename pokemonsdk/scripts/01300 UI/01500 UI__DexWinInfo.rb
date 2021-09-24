module UI
  # Dex sprite that show the Pokemon infos
  class DexWinInfo < SpriteStack
    # Change the data
    # Array of visible sprites if the Pokémon was captured
    VISIBLE_SPRITES = 1..7
    # Create a new dex win sprite
    def initialize(viewport)
      # Create the sprite stack at coordinate 131, 37 using the RPG::Cache.pokedex as image source
      super(viewport, 131, 37, default_cache: :pokedex)

      # Show the background of the WinInfos
      add_background('WinInfos')
      # Show the "caught" indicator
      add_sprite(8, 4, 'Catch')
      # Show the Pokedex Name of the Pokemon
      add_text(29, 4, 116, 16, :pokedex_name, type: SymText, color: 10)
      # Show the Specie of the Pokemon
      add_text(9, 27, 116, 16, :pokedex_species, type: SymText)
      # Show the weight (formated) of the Pokemon
      add_text(9, 67, 116, 16, :pokedex_weight, type: SymText)
      # Show the height (formated) of the Pokemon
      add_text(9, 87, 116, 16, :pokedex_height, type: SymText)
      # Show the 1st type of the Pokemon
      add_sprite(25, 47, NO_INITIAL_IMAGE, true, type: Type1Sprite)
      # Show the 2nd type of the Pokemon
      add_sprite(112, 47, NO_INITIAL_IMAGE, true, type: Type2Sprite)
    end

    # Define the Pokemon shown by the UI
    # @param pokemon [PFM::Pokemon]
    def data=(pokemon)
      super(pokemon)
      # Show / hide the sprites according to the captured state of the Pokemon
      is_captured = pokemon && $pokedex.has_captured?(pokemon.id)
      VISIBLE_SPRITES.each do |i|
        @stack[i].visible = is_captured
      end
    end
  end
end
