#encoding: utf-8

module UI
  # Class that show the category of a skill
  class CategorySprite < SpriteSheet
    # Create a new category sprite
    # @param viewport [LiteRGSS::Viewport] viewport in which the sprite is shown
    def initialize(viewport)
      super(viewport, 1, 3)
      set_bitmap("skill_categories", :interface)
    end
    # Set the object that responds to #atk_class 
    # @param object [Object, nil]
    def data=(object)
      if(self.visible = (object ? true : false))
        self.sy = object.atk_class - 1
      end
    end
  end
end
