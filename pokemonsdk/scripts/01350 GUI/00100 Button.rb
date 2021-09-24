module GUI
  class Button < Window
    NAMES = {
      normal: '%s',
      hover: '%s_hover',
      click: '%s_click'
    }
    DEFAULT_NAME = 'gui/button'
    DEFAULT_BUILDER = [5, 5, 22, 22, 5, 5]

    delegate :text, :@text

    # @return [Proc, Symbol, nil] action called when a action is defined
    attr_accessor :on_action

    def initialize(viewport, width, text = nil, image_name = DEFAULT_NAME, builder = DEFAULT_BUILDER, color: default_text_color)
      super(viewport)
      @image_name = image_name
      @text = Text.new(0, self, default_text_x, default_text_y - Text::Util::FOY, 0, builder[3], text.to_s, default_text_align)
      @text.load_color(color) unless color == 0
      self.stretch = true
      self.window_builder = builder
      set_state(:normal)
      set_size(width, windowskin.height)
    end

    def update
      return nil unless Mouse.moved || (press = Mouse.press?(:left)) || (release = Mouse.released?(:left))
      if simple_mouse_in?
        if press || release
          set_state(:click)
          return true if release
        else
          set_state(:hover)
        end
      else
        set_state(:normal)
      end
      false
    end

    def call_action(name, parent)
      return unless @on_action
      @on_action.is_a?(Symbol) ? parent.send(@on_action, name, self) : @on_action.call(name, self)
    end

    def set_state(state)
      return if @state == state
      self.windowskin = RPG::Cache.interface(format(NAMES[state], @image_name))
      @state = state
    end

    def text=(text)
      @text.text = text.to_s
    end

    def width=(width)
      super
      @text.width = text_width(width)
      self
    end

    def set_size(width, height)
      super
      @text.width = text_width(width)
      self
    end

    def text_width(width = self.width)
      width - 2 * window_builder[-2]
    end

    def default_text_align
      1
    end

    def default_text_color
      9
    end

    def default_text_x
      0
    end

    def default_text_y
      0
    end
  end
end
