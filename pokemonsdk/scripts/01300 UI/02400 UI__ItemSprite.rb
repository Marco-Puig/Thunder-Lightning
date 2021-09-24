#encoding: utf-8

module UI
  # Class that show the item icon
  class ItemSprite < Sprite
    # Set the object that responds to #atk_class 
    # @param object [Object, nil]
    def data=(object)
      set_bitmap(GameData::Item.icon(object), :icon)
    end
  end
end
