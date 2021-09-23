module GUI
  class Manager

    attr_reader :buttons
    attr_reader :labels
    attr_reader :inputs

    def initialize(viewport, parent, grid_width, grid_height)
      @viewport = viewport
      @parent = parent
      @grid_width = grid_width.to_i
      @grid_height = grid_height.to_i
      @x = 0
      @y = 0
      @element_width = viewport.rect.width / @grid_width
      @element_height = viewport.rect.height / @grid_height
      @labels = {}
      @buttons = {}
      @inputs = {}
    end

    def add_button(name, text, x: nil, y: nil, width: 1, type: Button, on_click: nil, &on_click_proc)
      x_pos, y_pos = get_position(x, y)
      update_position(width) unless x
      on_click = on_click_proc ? on_click_proc : on_click
      button = @buttons[name] = type.new(@viewport, width * @element_width, text)
      button.on_action = on_click
      button.set_position(x_pos, y_pos + get_element_offset(button))
      button
    end

    def add_label(name, text, x: nil, y: nil, width: 1, height: 1, type: Text, color: 0, align: 0)
      x_pos, y_pos = get_position(x, y)
      update_position(width) unless x
      text =@labels[name] = type.new(0, @viewport, x_pos, y_pos - Text::Util::FOY, width * @element_width, height * @element_height, text, align)
      text.load_color(color) if color > 0
      text
    end

    def add_input(name, x: nil, y: nil, width: 1, type: Input, on_update_text: nil, &on_update_text_proc)
      x_pos, y_pos = get_position(x, y)
      update_position(width) unless x
      on_update_text = on_update_text_proc ? on_update_text_proc : on_update_text
      input = @inputs[name] = type.new(@viewport, width * @element_width)
      input.on_action = on_update_text
      input.set_position(x_pos, y_pos + get_element_offset(input))
      input
    end

    def update
      result = update_buttons
      result |= update_inputs(result)
      result
    end

    def update_buttons(result = false)
      @buttons.each do |name, button|
        next unless button.update
        button.call_action(name, @parent) unless result
        result = true
      end
      result
    end

    def update_inputs(result = false)
      text = result ? nil : LiteRGSS::Input.get_text
      @inputs.each do |name, input|
        input.update
        next unless input.active
        unless result || !text
          input.update_text(text)
          input.call_action(name, @parent)
        end
        result = true
      end
      result
    end

    def set_current_position(x, y)
      x = 0 if x < 0
      x = @grid_width - 1 if x >= @grid_width
      y = 0 if y < 0
      y = @grid_height - 1 if y >= @grid_height
      @x = x
      @y = y
    end

    private
    def get_position(x, y)
      x_pos = (x ? x : @x) * @element_width
      y_pos = (y ? y : @y) * @element_height
      return x_pos, y_pos
    end

    def update_position(width)
      @x += width
      if @x >= @grid_width
        @x = 0
        @y += 1
      end
    end

    def get_element_offset(element)
      height = element.height
      return (@element_height - height) / 2 if height < @element_height
      0
    end
  end
end