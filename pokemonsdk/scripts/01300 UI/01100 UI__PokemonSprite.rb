#encoding: utf-8

module UI
  # Class that show the face sprite of a Pokemon
  class PokemonFaceSprite < Sprite
    # Set the pokemon
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      if(self.visible = (pokemon ? true : false))
        bmp = self.bitmap = pokemon.battler_face
        self.set_origin(bmp.width / 2, bmp.height)
      end
    end
  end
  # Class that show the back sprite of a Pokemon
  class PokemonBackSprite < Sprite
    # Set the pokemon
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      if(self.visible = (pokemon ? true : false))
        bmp = self.bitmap = pokemon.battler_back
        self.set_origin(bmp.width / 2, bmp.height)
      end
    end
  end
  # Class that show the icon sprite of a Pokemon
  class PokemonIconSprite < Sprite
    # Set the pokemon
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      if(self.visible = (pokemon ? true : false))
        bmp = self.bitmap = pokemon.icon
        self.set_origin(bmp.width / 2, bmp.height / 2)
      end
    end
  end
  # Class that show the icon sprite of a Pokemon
  class PokemonFootSprite < Sprite
    # Format of the icon name
    D3 = '%03d'
    # Set the pokemon
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      if(self.visible = (pokemon ? true : false))
        self.bitmap = RPG::Cache.foot_print(sprintf(D3,pokemon.id))
      end
    end
  end
end
