
module UI
  # Dex sprite that show the Pokemon location
  class DexWinMap < SpriteStack
    # Filename of the World Map Icon
    MAP_ICON = '344'

    # Create a new dex win sprite
    def initialize(viewport, display_controls = true)
      # Create the sprite stack at coordinate 0, 0 using the RPG::Cache.pokedex as image source
      super(viewport, 0, 0, default_cache: :pokedex)

      @pkm_icon  = add_sprite(28, 123, NO_INITIAL_IMAGE, type: PokemonIconSprite)
      @item_icon = add_sprite(13, 106, NO_INITIAL_IMAGE)
      @location  = add_text(10, 18, 132, 16, ext_text(9000, 19), 1, color: 10)
      @region    = add_text(150, 0, 150, 24, 'REGION', 2, color: 10)
      if display_controls
        add_sprite(40, 221, NO_INITIAL_IMAGE, :Y, type: KeyShortcut)
        add_text(60, 221, 140, 16, ext_text(9000, 32), color: 10) # Next worldmap
        add_sprite(190, 221, NO_INITIAL_IMAGE, :X, type: KeyShortcut)
        add_text(210, 221, 140, 16, ext_text(9000, 33), color: 10) # Zoom
      end

      # Set region text in bold
      @region.bold = true
    end

    # Change the data and the state
    # @param pokemon [PFM::Pokemon, :map] if set to map, we'll be showing the map icon
    def data=(pokemon)
      if pokemon == :map
        @pkm_icon.visible = false
        @item_icon.visible = true
        @item_icon.set_bitmap(MAP_ICON, :icon)
      elsif pokemon.is_a? PFM::Pokemon
        @pkm_icon.visible = true
        @item_icon.visible = false
        super(pokemon)
      end
    end

    # Set the location name
    # @param place [String] the name to display
    # @param color [Integer] the color code
    def set_location(place, color = 10)
      @location.multiline_text = place
      @location.load_color color
    end

    # Set the region name
    # @param place [String] the name to display
    # @param color [Integer] the color code
    def set_region(reg, color = 10)
      @region.multiline_text = reg.upcase
      @location.load_color color
    end
  end
end
