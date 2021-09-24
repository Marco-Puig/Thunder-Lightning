#encoding: utf-8

module UI
  # Class that show the sprite of a key
  class KeyShortcut < Sprite
    # Create a new KeyShortcut sprite
    # @param viewport [LiteRGSS::Viewport]
    # @param key [Symbol] Input.trigger? argument
    # @param red [Boolean] pick the red texture instead of the blue texture
    def initialize(viewport, key, red = false)
      super(viewport)
      set_bitmap(red ? 'Key_ShortRed' : 'Key_Short', :pokedex)
      find_key(key)
    end
    # KeyIndex that holds the value of the Keyboard constants in the right order according to the texture
    KeyIndex = [
      Keyboard::A, Keyboard::B, Keyboard::C, Keyboard::D, Keyboard::E, Keyboard::F, Keyboard::G, Keyboard::H, Keyboard::I, Keyboard::J,
      Keyboard::K, Keyboard::L, Keyboard::M, Keyboard::N, Keyboard::O, Keyboard::P, Keyboard::Q, Keyboard::R, Keyboard::S, Keyboard::T,
      Keyboard::U, Keyboard::V, Keyboard::W, Keyboard::X, Keyboard::Y, Keyboard::Z, Keyboard::Num0, Keyboard::Num1, Keyboard::Num2, Keyboard::Num3,
      Keyboard::Num4, Keyboard::Num5, Keyboard::Num6, Keyboard::Num7, Keyboard::Num8, Keyboard::Num9, Keyboard::Space, Keyboard::Backspace, Keyboard::Enter, Keyboard::LShift,
      Keyboard::LControl, Keyboard::LAlt, Keyboard::Escape, Keyboard::Left, Keyboard::Right, Keyboard::Up, Keyboard::Down
    ]
    # KeyIndex for the NumPad Keys
    NUMPAD_KEY_INDEX = [
      -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
      -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
      -1, -1, -1, -1, -1, -1, Keyboard::Numpad0, Keyboard::Numpad1, Keyboard::Numpad2, Keyboard::Numpad3,
      Keyboard::Numpad4, Keyboard::Numpad5, Keyboard::Numpad6, Keyboard::Numpad7, Keyboard::Numpad8, Keyboard::Numpad9, -1, -1, -1, Keyboard::RShift,
      Keyboard::RControl, Keyboard::RAlt, -1, -1, -1, -1, -1
    ]
    # Find the key rect in the Sprite according to the input key requested
    # @param key [Symbol] the Virtual Input Key.
    def find_key(key)
      key_array = Input::Keys[key]
      key_array.each do |i|
        if (id = KeyIndex.index(i) || NUMPAD_KEY_INDEX.index(i))
          return set_rect_div(id % 10, id / 10, 10, 5)
        end
      end
      set_rect_div(9, 4, 10, 5) # A blank key
    end
  end

  # Class that allow to show a binding of a specific key
  class KeyBinding < KeyShortcut
    # @return [Symbol] the key the button describe
    attr_reader :key
    # @return [Integer] the index of the key in the Keys[key] array
    attr_reader :index
    # Create a new KeyBinding sprite
    # @param viewport [LiteRGSS::Viewport]
    # @param key [Symbol] Input.trigger? argument
    # @param index [Integer] Index of the key in the Keys constant
    def initialize(viewport, key, index)
      @index = index
      @key = key
      super(viewport, key, false)
    end

    # Find the key rect in the Sprite according to the input key requested
    # @param key [Symbol] the Virtual Input Key.
    def find_key(key)
      key_val = Input::Keys[key][@index] || -1
      if (id = KeyIndex.index(key_val) || NUMPAD_KEY_INDEX.index(key_val))
        return set_rect_div(id % 10, id / 10, 10, 5)
      end
      set_rect_div(9, 4, 10, 5) # A blank key
    end

    # Update the key
    def update
      find_key(@key)
    end
  end

  # Class that allow to show a binding of a specific key on the Joypad
  class JKeyBinding < KeyShortcut
    # @return [Symbol] the key the button describe
    attr_reader :key
    # Create a new KeyBinding sprite
    # @param viewport [LiteRGSS::Viewport]
    # @param key [Symbol] Input.trigger? argument
    # @param index [Integer] Index of the key in the Keys constant
    def initialize(viewport, key)
      @key = key
      super(viewport, key, true)
    end
    # KeyIndex that holds the value of the key value in the order of the texture
    KeyIndex = [
      0, 1, -1, -1, -1, -1, -1, -1, -1, -1,
      -1, 4, -1, -1, -1, -1, -1, 5, -1, -1,
      -1, -1, -1, 2, 3, -1, -1, -1, -1, -1,
      -1, -1, -1, -1, 8, 9, -1, 6, 7, -1,
      11, 10, -1, 14, 15, 12, 13
    ]
    # Find the key rect in the Sprite according to the input key requested
    # @param key [Symbol] the Virtual Input Key.
    def find_key(key)
      key_val = Input::Keys[key].last
      if key_val && key_val < 0
        key_val = (key_val.abs - 1) % 32
        if (id = KeyIndex.index(key_val))
          return set_rect_div(id % 10, id / 10, 10, 5)
        end
      end
      set_rect_div(9, 4, 10, 5) # A blank key
    end

    # Update the key
    def update
      find_key(@key)
    end

    # Return the index of the key in the Keys[key] array
    # @return [Integer]
    def index
      return Input::Keys[key].size - 1
    end
  end
end
