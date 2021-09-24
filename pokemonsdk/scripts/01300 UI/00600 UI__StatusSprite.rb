#encoding: utf-8

module UI
  # Sprite that show the status of a Pokemon
  class StatusSprite < SpriteSheet
    # Create a new Status Sprite
    # @param viewport [LiteRGSS::Viewport, nil] the viewport in which the sprite is stored
    def initialize(viewport)
      super(viewport, 1, 10)
      set_bitmap("BattleBar_states", :interface)
    end
    # Set the Pokemon used to show the status
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      if(self.visible = (pokemon ? true : false))
        self.sy = pokemon.status
      end
    end
  end
end
