module GamePlay
  # Class that show the KeyBinding UI and allow to change it
  class KeyBinding < Base
    # Create a new KeyBinding UI
    def initialize
      super
      @viewport = Viewport.create(:main, 10_000)
      create_background
      create_overlay
      create_ctrl_buttons
      create_ui
      @cool_down = 0
    end

    # Update the UI
    def update
      update_background_animation
      @ui.update_blink
      return unless super
      return @cool_down -= 1 if @cool_down > 0
      update_input
    end

    private

    # Update the inputs
    def update_input
      if @ui.key_index == -1
        update_navigation_input
      elsif @ui.blinking
        update_key_binding
      else
        update_key_selection
      end
    end

    # Update the inputs during the naviation
    def update_navigation_input
      if Input.trigger?(:B)
        KeyBinding.save_inputs
        return @running = false
      elsif Input.trigger?(:A) || Input.trigger?(:RIGHT)
        @ui.key_index = 0
      elsif Input.trigger?(:LEFT)
        @ui.key_index = 4
      elsif Input.trigger?(:DOWN)
        @ui.main_index += 1
      elsif Input.trigger?(:UP)
        @ui.main_index -= 1
      end
    end

    # Update the key selection
    def update_key_selection
      if Input.trigger?(:B)
        @ui.key_index = -1
      elsif Input.trigger?(:A)
        return display_message(ext_text(8998, 28)) if @ui.key_index == 4 && !Input.joy_connected?(Input.main_joy)
        @ui.blinking = true
        @cool_down = 10
      elsif Input.trigger?(:LEFT)
        @ui.key_index = (@ui.key_index - 1).clamp(0, 4)
      elsif Input.trigger?(:RIGHT)
        @ui.key_index = (@ui.key_index + 1).clamp(0, 4)
      elsif Input.trigger?(:DOWN)
        @ui.main_index += 1
      elsif Input.trigger?(:UP)
        @ui.main_index -= 1
      end
    end

    # Update the key detection during the UI blinking
    def update_key_binding
      if @ui.key_index < 4
        UI::KeyShortcut::KeyIndex.each do |key_value|
          return validate_key(key_value) if Keyboard.press?(key_value)
        end
        UI::KeyShortcut::NUMPAD_KEY_INDEX.each do |key_value|
          return validate_key(key_value) if key_value >= 0 && Keyboard.press?(key_value)
        end
      else
        unless Input.joy_connected?(Input.main_joy)
          @ui.blinking = false
          return display_message(ext_text(8998, 28))
        end
        0.upto(Input.joy_button_count(Input.main_joy)) do |key_value|
          if Input.joy_button_press?(Input.main_joy, key_value)
            return validate_key((-key_value - 1) - 32 * Input.main_joy)
          end
        end
      end
    end

    # Validate the key change
    # @param key_value [Integer] the value of the key in Keyboard
    def validate_key(key_value)
      if key_value == Keyboard::Escape
        ch = display_message_and_wait(ext_text(8998, 31), 1, ext_text(8998, 32), ext_text(8998, 33))
        return if ch == 0
      end
      Input::Keys[@ui.current_key][@ui.current_key_index] = key_value
      @ui.update
    ensure
      @ui.blinking = false
    end

    # Create the background sprite
    def create_background
      @background = Sprite.new(@viewport).set_bitmap('team/Fond', :interface)
    end

    # Update the background animation
    def update_background_animation
      @background.set_origin((@background.ox - 0.5) % 16, (@background.oy - 0.5) % 16)
    end

    # Create the overlay sprite
    def create_overlay
      overlay = 'key_binding/overlay_'
      overlay_lang = overlay + ($options&.language || Load::DEFAULT_GAME_LANGUAGE)
      if RPG::Cache.interface_exist?(overlay_lang)
        overlay = overlay_lang
      else
        overlay << 'en'
      end
      @overlay = Sprite.new(@viewport).set_bitmap(overlay, :interface)
    end

    # Create the UI
    def create_ui
      @ui = UI::KeyBindingViewer.new(@viewport)
    end

    # Create the CTRL buttons
    def create_ctrl_buttons

    end
  end
end
