#encoding: utf-8

module UI
  # Sprite that show the hold item if the pokemon is holding an item
  class HoldSprite < Sprite
    # Create a new Hold Sprite
    # @param viewport [LiteRGSS::Viewport, nil] the viewport in which the sprite is stored
    def initialize(viewport)
      super(viewport)
      set_bitmap("hold", :interface)
    end
    # Set the Pokemon used to show the hold image
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      self.visible = (pokemon ? pokemon.item_holding != 0 : false)
    end
  end
  # Sprite that show the actual item held if the Pokemon is holding one
  class RealHoldSprite < Sprite
    # Set the Pokemon used to show the hold image
    # @param pokemon [PFM::Pokemon, nil]
    def data=(pokemon)
      self.visible = (pokemon ? pokemon.item_holding != 0 : false)
      set_bitmap(GameData::Item.icon(pokemon.item_holding), :icon) if visible
    end
  end
end
