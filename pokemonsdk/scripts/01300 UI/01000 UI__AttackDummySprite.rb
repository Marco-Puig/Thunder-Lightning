#encoding: utf-8

module UI
  # Class that show the category of a skill
  class AttackDummySprite < SpriteSheet
    # Create a new category sprite
    # @param viewport [LiteRGSS::Viewport] viewport in which the sprite is shown
    def initialize(viewport)
      super(viewport, 1, $game_data_types.size)
      set_bitmap("battle_attack_dummy", :interface)
    end
    # Set the object that responds to #atk_class 
    # @param object [Object, nil]
    def data=(object)
      if(self.visible = (object ? true : false))
        self.sy = object.type 
      end
    end
  end
end
