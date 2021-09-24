module UI
  # Object that show a text using a method of the data object sent
  class SymText < Text
    # Add a text inside the window, the offset x/y will be adjusted
    # @param font_id [Integer] the id of the font to use to draw the text
    # @param viewport [LiteRGSS::Viewport, nil] the viewport used to show the text
    # @param x [Integer] the x coordinate of the text surface
    # @param y [Integer] the y coordinate of the text surface
    # @param width [Integer] the width of the text surface
    # @param height [Integer] the height of the text surface
    # @param method [Symbol] the symbol of the method to call in the data object
    # @param align [0, 1, 2] the align of the text in its surface (best effort => no resize), 0 = left, 1 = center, 2 = right
    # @param outlinesize [Integer, nil] the size of the text outline
    # @param color [Integer] the id of the color
    # @param sizeid [Intger] the id of the size to use
    def initialize(font_id, viewport, x, y, width, height, method, align = 0, outlinesize = nil, color = nil, sizeid = nil)
      super(font_id, viewport, x, y, width, height, nil.to_s, align, outlinesize, color, sizeid)
      @method = method
    end

    # Set the Object used to show the text
    # @param object [Object, nil]
    def data=(object)
      return unless (self.visible = (object ? true : false))
      self.text = object.public_send(@method).to_s
    end
  end
  # Object that show a multiline text using a method of the data object sent
  class SymMultilineText < SymText
    # Set the Object used to show the text
    # @param object [Object, nil]
    def data=(object)
      return unless (self.visible = (object ? true : false))
      self.multiline_text = object.public_send(@method).to_s
    end
  end
end
