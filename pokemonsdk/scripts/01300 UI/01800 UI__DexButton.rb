module UI
  # Dex sprite that show the Pokemon infos
  class DexButton < SpriteStack
    # Create a new dex button
    # @param viewport [LiteRGSS::Viewport]
    # @param i [Integer] index of the sprite in the viewport
    def initialize(viewport, i)
      # Create the sprite stack at coordinate 147, 62 using the RPG::Cache.pokedex as image source
      super(viewport, 147, 62, default_cache: :pokedex)

      # Show the background image
      add_background('But_List')
      # Show the caught indicator
      @catch_icon = add_sprite(119, 9, 'Catch')
      # Show the Pokemon Icon Sprite
      add_sprite(17, 15, NO_INITIAL_IMAGE, type: PokemonIconSprite)
      # Show the Pokemon formated ID
      add_text(35, 1, 116, 16, :id_text3, type: SymText, color: 10)
      # Show the Pokemon name
      add_text(35, 16, 116, 16, :name, type: SymText, color: 10)
      # Show the obfuscator in forground when the Pokemon button is not 
      @obfuscator = add_foreground('But_ListShadow')

      # Adjust the position according to the index
      set_position(i == 0 ? 147 : 163, y - 40 + i * 40)
    end

    # Change the data
    # @param pokemon [PFM::Pokemon] the Pokemon shown by the button
    def data=(pokemon)
      super(pokemon)
      # Change the catch visibility to the captured state of the Pokemon
      @catch_icon.visible = $pokedex.has_captured?(pokemon.id)
    end

    # Tell the button if it's selected or not : change the obfuscator visibility & x position
    # @param value [Boolean] the selected state
    def selected=(value)
      @obfuscator.visible = !value
      set_position(value ? 147 : 163, y)
    end
  end
end
