#encoding: utf-8

module UI
  # A class that manage the sheet sprite in order to make the thing easier
  class SpriteSheetManager
    # Creates a new SpriteSheetManager
    # @param source_object [Object] The object in which the influenced data will be retreive
    # @param source_attribute [Symbol] The attribute used to retreive the data
    def initialize(source_object, source_attribute)
      @src = source_object
      @attr = source_attribute
      @stack = []
    end

    # Add a new sprite
    # @param sprite [SheetSprite] the sprite updated
    # @param attr [Symbol] the attribute of the data used to update the sprite
    # @param direction [:both, :x, :y] the directions of the sheet sprite
    # @return [SheetSprite] the sprite attribute
    def add(sprite, attr, direction = :both)
      @stack << [sprite, attr, direction]
      return sprite
    end

    # Force a position for all sprites instead of updating them
    # @param sx [Integer] the forced sx
    # @param sy [Integer] the forced sy
    def force(sx = 0, sy = 0)
      @stack.each do |arr| 
        (sp = arr.first).sx = sx
        sp.sy = sy
      end
    end

    # Update the sprites (if needed)
    def update
      data = @src.public_send(@attr)
      @stack.each do |arr|
        sp = arr.first
        value = data.public_send(arr[1])
        case arr.last
        when :x
          sp.sx = value
        when :y
          sp.sy = value
        else
          sp.sx = value % sp.nb_x
          sp.sy = value / sp.nb_x
        end
      end
    end

    # Dispose the sprites
    def dispose
      @stack.each { |sprite| sprite.first.dispose }
      @stack.clear
    end
  end
end
