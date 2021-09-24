module UI
  # Sprite that show the 1st type of the Pokemon
  class Type1Sprite < SpriteSheet
    # Create a new Type Sprite
    # @param viewport [LiteRGSS::Viewport, nil] the viewport in which the sprite is stored
    # @param from_pokedex [Boolean] if the type is the Pokedex type (other source image)
    def initialize(viewport, from_pokedex = false)
      super(viewport, 1, $game_data_types.size)
      filename = "types_#{$options.language}"
      if from_pokedex
        set_bitmap(RPG::Cache.pokedex_exist?(filename) ? filename : 'types', :pokedex)
      else
        set_bitmap(RPG::Cache.interface_exist?(filename) ? filename : 'types', :interface)
      end
    end

    # Set the Pokemon used to show the type
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      if (self.visible = (pokemon ? true : false))
        self.sy = pokemon.type1
      end
    end
  end
  # Sprite that show the 2nd type of the Pokemon
  class Type2Sprite < Type1Sprite
    # Set the Pokemon used to show the type
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      if (self.visible = (pokemon ? true : false))
        self.sy = pokemon.type2
      end
    end
  end
  # Class that show a type image using an object that responds to #type
  class TypeSprite < Type1Sprite
    # Set the object that responds to #type
    # @param object [Object, nil]
    def data=(object)
      if (self.visible = (object ? true : false))
        self.sy = object.type
      end
    end
  end
end
