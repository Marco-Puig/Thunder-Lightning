module GUI
  class CheckBox < Button
    NAMES = {
      normal: NAMES,
      checked: {
        normal: '%s_checked',
        hover: '%s_checked_hover',
        click: '%s_checked_click'
      }
    }
    
    DEFAULT_NAME = 'gui/check'
    DEFAULT_BUILDER = [16, 4, 8, 14, 2, 0]

    # @return [Boolean] check state
    attr_accessor :checked

    def initialize(viewport, width, text = nil, checked = false, image_name = DEFAULT_NAME, builder = DEFAULT_BUILDER, color: default_text_color)
      @checked = checked
      super(viewport, width, text, image_name, builder, color: color)
    end
    
    def set_state(state)
      return if @state == state
      self.windowskin = RPG::Cache.interface(format(NAMES[@checked ? :checked : :normal][state], @image_name))
      @state = state
    end

    def update
      result = super
      if(result)
        state = @state
        @state = nil
        @checked = !@checked
        set_state(state)
      end
      result
    end

    def default_text_x
      16
    end

    def default_text_align
      0
    end
  end
end
