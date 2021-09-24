#encoding: utf-8

module GamePlay
  # Class that display the Party Menu interface and manage user inputs
  #
  # This class has several modes
  #   - :map => Used to select a Pokemon in order to perform stuff
  #   - :menu => The normal mode when opening this interface from the menu
  #   - :battle => Select a Pokemon to send to battle
  #   - :item => Select a Pokemon in order to use an item on it (require extend data : hash)
  #   - :hold => Give an item to the Pokemon (requires extend data : item_id)
  #   - :select => Select a number of Pokemon for a temporary team.
  #     (Number defined by $game_variables[6] and possible list of excluded Pokemon requires extend data : array)
  #
  # This class can also show an other party than the player party,
  # the party paramter is an array of Pokemon upto 6 Pokemon
  class Party_Menu < Base
    # Return data of the Party Menu
    # @return [Integer]
    attr_accessor :return_data
    # Return the skill process to call
    # @return [Array(Proc, PFM::Pokemon, PFM::Skill), Proc, nil]
    attr_accessor :call_skill_process
    # Selector Rect info
    # @return [Array]
    SelectorRect = [[0, 0, 132, 52], [0, 64, 132, 52]]
    # Create a new Party_Menu
    # @param party [Array<PFM::Pokemon>] list of Pokémon in the party
    # @param mode [Symbol] :map => from map (select), :menu => from menu, :battle => from Battle, :item => Use an item, :hold => Hold an item, :choice => processing a choice related proc (do not use)
    # @param extend_data [Integer, Hash] extend_data informations
    # @param no_leave [Boolean] tells the interface to disallow leaving without choosing
    def initialize(party, mode = :map, extend_data = nil, no_leave: false)
      super()
      @move = -1
      @return_data = -1
      # Scene mode
      # @type [Symbol]
      @mode = mode
      # Displayed party
      # @type [Integer, Hash, nil]
      @extend_data = extend_data
      @no_leave = no_leave
      @index = 0
      # @type [Array<PFM::Pokemon>]
      @party = party
      @counter = 0 #  Used by the selector
      @intern_mode = :normal # :normal, :move_pokemon, :move_item, :choose_move_pokemon, :choose_move_item
      # Scene viewport
      # @type [LiteRGSS::Viewport]
      @viewport = Viewport.create(:main, 10_000)
      # Array containing the temporary team selected
      # @type [Array<PFM::Pokemon>]
      @temp_team = []
      create_background
      create_team_buttons
      create_frames #  Must be after team buttons to ensure the black frame to work
      create_selector
      create_ctrls
      create_win_text
      init_win_text
      # Resetting the affected variable to prevent bugs
      $game_variables[Yuki::Var::Party_Menu_Sel] = -1
      # Telling the B action the user is seeing a choice and make it able to cancel the choice
      # @type [PFM::Choice_Helper]
      @choice_object = nil
      # Running state of the scene
      # @type [Boolean]
      @running = true
    end

    # Create the background sprite
    def create_background
      # Scene background
      # @type [LiteRGSS::Sprite]
      @background = Sprite.new(@viewport).set_bitmap('team/Fond', :interface)
    end

    # Create the frame sprites
    def create_frames
      # @type [LiteRGSS::Sprite]
      @black_frame = Sprite.new(@viewport) #  Get the Blackn ^^
      # Scene frame
      # @type [LiteRGSS::Sprite]
      @frame = Sprite.new(@viewport).set_bitmap($options.language == 'fr' ? 'team/FrameFR' : 'team/FrameEN', :interface)
    end

    # Create the team buttons
    def create_team_buttons
      # Team button list
      # @type [Array<UI::TeamButton>]
      @team_buttons = Array.new(@party.size) do |i|
        btn = UI::TeamButton.new(@viewport, i)
        btn.data = @party[i]
        next(btn)
      end
    end

    # Create the selector
    def create_selector
      # Scene selector
      # @type [LiteRGSS::Sprite]
      @selector = Sprite.new(@viewport).set_bitmap('team/Cursors', :interface)
      @selector.src_rect.set(*SelectorRect[0])
      update_selector_coordinates
    end

    # Create the control buttons
    def create_ctrls
      # Scene Control buttons
      # @type [Array<UI::TeamCTRLButton>]
      @ctrl = Array.new(4) { |i| UI::TeamCTRLButton.new(@viewport, i) } if @mode != :select
      # Scene Control button
      # @type [Array<UI::SelectCTRLButton>]
      @ctrl = Array.new(1) { |i| UI::SelectCTRLButton.new(@viewport, i + 1) } if @mode == :select
    end

    # Create the text window (info to the player)
    def create_win_text
      # Scene Text window (info)
      # @type [UI::SpriteStack]
      @win_text = UI::SpriteStack.new(@viewport)
      @win_text.push(0, 217, 'team/Win_Txt')
      # Real text info
      # @type [LiteRGSS::Text]
      @text_info = @win_text.add_text(2, 220, 238, 15, nil.to_s, color: 9)
    end

    # Initialize the win_text according to the mode
    def init_win_text
      case @mode
      when :map, :battle
        return @text_info.text = text_get(23, 17)
      when :hold
        return @text_info.text = text_get(23, 23)
      when :item
        if @extend_data
          extend_data_button_update
          return @text_info.text = text_get(23, 24)
        end
      when :select
        select_pokemon_button_update
        return @text_info.text = text_get(23, 17)
      end
      @win_text.visible = false
    end

    # Function that update the team button when extend_data is correct
    def extend_data_button_update
      if (_proc = @extend_data[:on_pokemon_choice])
        apt_detect = (@extend_data[:open_skill_learn] or @extend_data[:stone_evolve])
        @team_buttons.each do |btn|
          btn.show_item_name
          v = @extend_data[:on_pokemon_choice].call(btn.data)
          if apt_detect
            c = (v ? 1 : v == false ? 2 : 3)
            v = (v ? 143 : v == false ? 144 : 142)
          else
            c = (v ? 1 : 2)
            v = (v ? 140 : 141)
          end
          btn.item_text.load_color(c).text = parse_text(22, v)
        end
      end
    end
    
    # Function that updates the text displayed in the team button when in :select mode
    def select_pokemon_button_update
      @team_buttons.each do |btn|
        btn.show_item_name
        c = 0
        if @temp_team.include?(btn.data)
          c = 1
          v = 155 + @temp_team.index(btn.data)
        elsif @extend_data.kind_of?(Array)
          if @extend_data.include?(@party[@team_buttons.index(btn)].id)
            c = 2
            v = 154
          else 
            v = 153
          end
        else
          v = 153
        end
        btn.item_text.load_color(c).text = fix_number(parse_text(23, v))
      end
    end

    # Globaly update the scene
    def update
      update_during_process
      return unless super
      update_mouse_ctrl
      return action_A if Input.trigger?(:A)
      return action_X if Input.trigger?(:X)
      return action_Y if Input.trigger?(:Y)
      return action_B if Input.trigger?(:B)
      update_selector_move
    end

    # Update the selector
    def update_selector
      @counter += 1
      if @counter == 60
        @selector.src_rect.set(*SelectorRect[1])
      elsif @counter >= 120
        @counter = 0
        @selector.src_rect.set(*SelectorRect[0])
      end
    end

    # Update the background animation
    def update_background_animation
      @background.set_origin((@background.ox - 0.5) % 16, (@background.oy - 0.5) % 16)
    end

    # Update the scene during an animation or something else
    def update_during_process
      update_selector
      update_background_animation
    end

    # Show the win_text
    # @param str [String] String to put in the Win Text
    def show_win_text(str)
      @text_info.text = str
      @win_text.visible = true
    end

    # Hide the win_text
    def hide_win_text
      @win_text.visible = false
    end

    # Show the item name
    def show_item_name
      @team_buttons.each(&:show_item_name)
    end

    # Hide the item name
    def hide_item_name
      @team_buttons.each(&:hide_item_name)
    end

    # Show the black frame for the currently selected Pokemon
    def show_black_frame
      @black_frame.set_bitmap("team/dark#{@index + 1}", :interface)
      @black_frame.visible = true
      1.upto(8) do |i|
        @black_frame.opacity = i * 255 / 8
        update_during_process
        Graphics.update
      end
    end

    # Hide the black frame for the currently selected Pokemon
    def hide_black_frame
      8.downto(1) do |i|
        @black_frame.opacity = i * 255 / 8
        update_during_process
        Graphics.update
      end
      @black_frame.visible = false
    end

    # Fix special characters used in some Ruby Host texts
    def fix_number(string)
      string = string.sub('', 'er')
      string.sub!('', 'ème')
      return string
    end

    def dispose
      super
      # @viewport.dispose
    end
  end
end
