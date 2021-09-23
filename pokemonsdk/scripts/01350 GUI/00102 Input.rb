module GUI
  class Input < Button
    DEFAULT_NAME = 'gui/input'
    DEFAULT_BUILDER = [5, 5, 22, 22, 5, 5]
    CTRL_V = "\u0016"
    CTRL_C = "\u0003"
    BACKSPACE = "\b"
    BACKSPACE_RANGE = 0...-1

    # @return [Boolean] active state
    attr_accessor :active

    def initialize(viewport, width, text = nil, image_name = DEFAULT_NAME, builder = DEFAULT_BUILDER, color: default_text_color)
      @active = false
      super
    end

    def update
      return nil unless Mouse.moved || (press = Mouse.press?(:left))
      if simple_mouse_in?
        if press
          set_state(:click)
          return @active = true
        elsif !@active
          set_state(:hover)
        end
      elsif press
        @active = false
        set_state(:normal)
      elsif !@active
        set_state(:normal)
      end
      false
    end

    def update_text(input)
      return unless active && input
      if Keyboard.press?(Keyboard::LControl) || Keyboard.press?(Keyboard::RControl)
        if input.include?(CTRL_V)
          return self.text = Yuki.get_clipboard.to_s
        elsif input.include?(CTRL_C)
          return Yuki.set_clipboard(text)
        end
      end
      return self.text = text[BACKSPACE_RANGE] if input.include?(BACKSPACE)
      input = input.gsub(/[\x00-\x1F]/, nil.to_s)
      self.text += input
    end

    def default_text_align
      0
    end

    def default_text_color
      0
    end
  end
end
