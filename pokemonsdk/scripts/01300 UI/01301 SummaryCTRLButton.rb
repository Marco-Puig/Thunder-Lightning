module UI
  # Control button of the Summary
  #
  # This CTRL Button will have 6 states
  #   - 1 : DOWN = NEXT, LEFT = MOVES, RIGHT = STATS, B = QUIT
  #   - 2 : DOWN = NEXT, LEFT = MEMO, RIGHT = MOVES, B = QUIT
  #   - 3 : A = SELECT, LEFT = STATS, RIGHT = MEMO, B = QUIT
  #   - 4 : A = SWITCH, HIDDEN, HIDDEN, B = CANCEL
  #   - 5 : A = CONFIRM, HIDDEN, HIDDEN, B = CANCEL
  #   - 6 : HIDDEN, HIDDEN, HIDDEN, B = CANCEL
  class SummaryCTRLButton < DexCTRLButton
    # Array of Key to press
    KEYS = [
      %i[DOWN LEFT RIGHT B],
      %i[A LEFT RIGHT B]
    ]
    # Text base indexes in the file
    TEXT_INDEXES = [
      [112, 113, 114, 115],
      [112, 116, 113, 115],
      [117, 114, 116, 115],
      [118, 1, 1, 13],
      [119, 1, 1, 13],
      [1, 1, 1, 13]
    ]
    # Create a new Button
    # @param viewport [LiteRGSS::Viewport]
    # @param id [Integer] the id of the button
    def initialize(viewport, id)
      super
      # @type [UI::KeyShortcut]
      @key = @stack[1]
    end

    # Change the button state
    # @param id_state [Integer] one of the state described in the class description
    def set_state(id_state)
      return unless id_state.between?(1, 5)
      text_id = TEXT_INDEXES[id_state - 1][@id]
      return self.visible = false if text_id == 1
      self.visible = true if @id > 0 && @id < 3
      @key.find_key(KEYS[id_state <= 2 ? 0 : 1][@id])
      @stack.last.text = ext_text(9000, text_id)
      return self
    end

    private

    # Return the Keys Array
    def keys
      KEYS[0]
    end
  end
end
