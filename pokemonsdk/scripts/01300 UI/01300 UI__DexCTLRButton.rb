#encoding: utf-8

module UI
  # Control button of the pokedex
  class DexCTRLButton < SpriteStack
    # Array of button coordinates
    Coordinates = [[3, 219], [83, 219], [163, 219], [243, 219]]
    # Array of Key to press
    Keys = [:A, :X, :Y, :B]
    # Text base indexes in the file
    TEXT_INDEXES = [6, 10, 6, 14, 22]
    # Create a new Button
    # @param viewport [LiteRGSS::Viewport]
    # @param id [Integer] the id of the button
    def initialize(viewport, id)
      super(viewport, *Coordinates[id], default_cache: :pokedex)
      push(0, 0, "Buttons").set_rect_div(id == 3 ? 1 : 0, 0, 2, 2)
      @stack.first.src_rect.x += 1 if id == 3
      push(0, 1, nil, keys[id], id == 3, type: KeyShortcut)
      @font_id = 20
      add_text(17, 3, 51, 13, get_text(0, id), color: id == 3 ? 21 : 20)
      @id = id
    end
    # Change the button state
    # @param id_state [Integer] the state of the DEX scene (0, 1, 2)
    def set_state(id_state)
      if id_state >= 2 and @id > 0 and @id < 3
        return self.visible = false
      end
      self.visible = true if @id > 0 and @id < 3
      @stack.last.text = get_text(id_state, @id)
      return self
    end
    # Set the button pressed
    # @param pressed [Boolean] if the button is pressed or not
    def set_press(pressed)
      @stack.first.set_rect_div(@id == 3 ? 1 : 0, pressed ? 1 : 0, 2, 2)
      @stack.first.src_rect.x += 1 if @id == 3
      @stack.first.src_rect.y += 1 if pressed
    end
    # Return the correct text from a state and an id
    # @param state_id [Integer] state id of the interface
    # @param id [Integer] id of the text
    # @return [String]
    def get_text(state_id, id)
      ext_text(9000, TEXT_INDEXES[state_id] + id)
    end

    private

    # Return the Keys Array
    def keys
      Keys
    end
  end
  # Control button of the Team
  class TeamCTRLButton < DexCTRLButton
    # Create a new Button
    # @param viewport [LiteRGSS::Viewport]
    # @param id [Integer] the id of the button
    def initialize(viewport, id)
      super
      set_state(3)
    end
    # Change the button state
    # @param id_state [Integer] the state of the Team scene (3)
    def set_state(id_state)
      if id_state != 3 and @id > 0 and @id < 3
        return self.visible = false
      end
      self.visible = true if @id > 0 and @id < 3
      @stack.last.text = get_text(id_state, @id)
      return self
    end
  end
  
  class SelectCTRLButton < TeamCTRLButton
    def initialize(viewport, id)
      super
      set_state(4)
      self.x=(Coordinates[3][0])
      self.y=(Coordinates[3][1])
    end

    def set_state(id_state)
      self.visible = true
      @stack.last.text = get_text(id_state, 3)
      return self
    end
  end
end
