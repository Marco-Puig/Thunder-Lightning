module GamePlay
  # Scene displaying the Summary of a Pokemon
  class Summary < Base
    # @return [Integer] Last state index in this scene
    LAST_STATE = 2
    # @return [Integer] Index of the choosen skill of the Pokemon
    attr_accessor :skill_selected
    # Create a new sumarry Interface
    # @param pokemon [PFM::Pokemon] Pokemon currently shown
    # @param z [Integer] Z index of the UIs
    # @param mode [Symbol] :view if it's about viewing a Pokemon, :skill if it's about choosing the skill of the Pokemon
    # @param party [Array<PFM::Pokemon>] the party (allowing to switch Pokemon)
    # @param extend_data [Hash, nil] the extend data information when we are in :skill mode
    def initialize(pokemon, z = 1000, mode = :view, party = [pokemon], extend_data = nil)
      super(false, z * 10)
      @viewport = Viewport.create(:main, z)
      # @type [PFM::Pokemon]
      @pokemon = pokemon
      @mode = mode
      @party = party
      @index = mode == :skill ? 2 : 0
      @party_index = party.index(pokemon).to_i
      @skill_selected = -1
      @skill_index = -1
      @selecting_move = false
      @extend_data = extend_data
      create_sprites
      update_pokemon
    end

    private

    # Function creating all the sprites
    def create_sprites
      create_background
      create_uis
      create_top_ui
      create_controls
      create_win_text if @mode == :skill
    end

    # Create the background
    def create_background
      @background = Sprite.new(@viewport).set_bitmap('team/Fond', :interface)
    end

    # Create the various UI
    def create_uis
      @uis = [
        UI::Summary_Memo.new(@viewport),
        UI::Summary_Stat.new(@viewport),
        UI::Summary_Skills.new(@viewport)
      ]
    end

    # Create the top UI
    def create_top_ui
      @top = UI::Summary_Top.new(@viewport)
    end

    # Create the control buttons
    def create_controls
      @ctrl = Array.new(4) { |i| UI::SummaryCTRLButton.new(@viewport, i) }
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
      init_win_text
    end

    # Initialize the win_text according to the mode
    def init_win_text
      if @extend_data
        @text_info.text = text_get(23, @extend_data[:skill_message_id] || 34)
      else
        @text_info.text = ext_text(9000, 120)
      end
    end

    # Update the UI visibility according to the index
    def update_ui_visibility
      @uis.each_with_index { |ui, index| ui.visible = index == @index }
      update_ctrl_state
    end

    # Update the Pokemon shown in the UIs
    def update_pokemon
      @uis.each { |ui| ui.data = @pokemon }
      @top.data = @pokemon
      update_ui_visibility
    end

    # Update the control button state
    def update_ctrl_state
      # Get the right ID state according to the Scene state
      id_state = ctrl_id_state
      # Apply it to the buttons
      @ctrl.each { |button| button.set_state(id_state) }
    end

    # Retreive the ID state of the ctrl button
    # @return [Integer] a number between 1 & 5 that correspond to the description of the UI::SummaryCTRLButton class
    def ctrl_id_state
      case @index
      when 0
        return 1
      when 1
        return 2
      when 2
        return 6 if @mode == :skill
        return 5 if @skill_index >= 0
        return 4 if @selecting_move
      end
      return 3
    end
  end
end
