#encoding: utf-8

module UI
  # Simple click button
  class Button < SpriteStack
    # Tell if the button is active or not
    # @return [Boolean]
    attr_accessor :active
    # Create a new dex button
    # @param viewport [LiteRGSS::Viewport]
    # @param x [Integer] x position of the button
    # @param y [Integer] y position of the button
    # @param filename [String] name of the file used to create the button (in Windowskins)
    # @param content [String, Symbol] text content of the button
    # @param icon [String, Bitmap, nil] additionnal icon (in WindowSkin if string)
    # @param offset_x [Integer] text offset_x in the button
    # @param offset_y [Integer] text offset_y in the button
    # @param line_heigh [Integer] height of the text line
    # @yieldparam text [Text] Text shown in the button if you want to change its properties
    def initialize(viewport, x , y, filename, content, icon: nil, offset_x: 2, offset_y: 1, line_heigh: 16)
      super(viewport, x, y, default_cache: :windowskin)
      _ox = offset_x
      push(0, 0, filename, 1, 3, type: SpriteSheet)
      if(icon)
        push(offset_x, offset_y, icon)
        _ox += @stack.last.width
      end
      if(content.is_a?(Symbol))
        text = add_text(_ox, offset_y, @stack.first.width - 2 * offset_x, line_heigh, content, 1, type: SymText)
      else
        text = add_text(_ox, offset_y, @stack.first.width - 2 * offset_x, line_heigh, content, 1)
      end
      yield(text) if block_given?
      @active = true
      @mouse_was_in = false
      @on_click = nil
      @on_enter = nil
      @on_leave = nil
    end
    # Register the proc to call when the user click on the button
    # @yieldparam button [self]
    # @return [self]
    def on_click(&block)
      @on_click = block
      return self
    end
    # Register the proc to call when the user click on the button
    # @yieldparam button [self]
    # @return [self]
    def on_enter(&block)
      @on_enter = block
      return self
    end
    # Register the proc to call when the user click on the button
    # @yieldparam button [self]
    # @return [self]
    def on_leave(&block)
      @on_leave = block
      return self
    end
    # Update the button interaction
    # @return [Boolean] the button require the update process to stop
    def update
      return unless @active
      if simple_mouse_in?
        if @mouse_was_in
          if Mouse.press?(:left)
            @stack.first.sy = 1
            return true
          elsif(Mouse.released?(:left))
            @on_click.call(self) if @on_click
            @stack.first.sy = 2
            return false
          end
        elsif Mouse.press?(:left)
          return false
        end
        @stack.first.sy = 2
        @mouse_was_in = true
        @on_enter.call(self) if @on_enter
      else
        if @mouse_was_in and !Mouse.press?(:left)
          @mouse_was_in = false
          @stack.first.sy = 0
          @on_leave.call(self) if @on_leave
        end
      end
      return false
    end
  end
end
