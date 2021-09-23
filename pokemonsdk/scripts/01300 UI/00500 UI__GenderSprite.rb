#encoding: utf-8

module UI
  # Sprite that show the gender of a Pokemon
  class GenderSprite < SpriteSheet
    # Create a new Gender Sprite
    # @param viewport [LiteRGSS::Viewport, nil] the viewport in which the sprite is stored
    def initialize(viewport)
      super(viewport, 3, 1)
      set_bitmap("battlebar_gender", :interface)
    end
    # Set the Pokemon used to show the gender
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      if(self.visible = (pokemon ? true : false))
        self.sx = pokemon.gender
      end
    end
  end
end
