module UI
  # UI part displaying the Stats of a Pokemon in the Summary
  class Summary_Stat < SpriteStack
    # Show the IV ?
    SHOW_IV = true
    # Show the EV ?
    SHOW_EV = true
    # Create a new Stat UI for the summary
    # @param viewport [Viewport]
    def initialize(viewport)
      super(viewport, 0, 0, default_cache: :interface)
      push(0, 0, 'summary/stats')
      init_stats
      ability_text = add_text(13, 138, 100, 16, text_get(33, 142) + ': ')
      @ability_name = add_text(13 + ability_text.real_width, 138, 294, 16, :ability_name, type: SymText, color: 1)
      @ability_descr = add_text(13, 138 + 16, 294, 16, :ability_descr, type: SymMultilineText)
	  @hp_container = push(11,128,RPG::Cache.interface("menu_pokemon_hp"), rect: ::Rect.new(0,0,67,6))
	 
	  @hp = add_custom_sprite(create_hp_bar) # Copy/Paste from Party_Menu

    end

    # Set the Pokemon shown by the UI
    # @param pokemon [PFM::Pokemon]
    def data=(pokemon)
      super
      @nature_text.text = PFM::Text.parse(28, pokemon.nature_id)
      # Load the stat color according to the nature
      nature = pokemon.nature
      1.upto(5) do |i|
        color = nature[i] < 100 ? 23 : 22
        color = 0 if nature[i] == 100
        @stat_name_texts[i - 1].load_color(color)
      end
    end

    # Init the stat texts
    def init_stats
      texts = text_file_get(27)
      # --- Static part ---
      @nature_text = add_text(114, 19, 60, 16, '') # Nature
      @stat_name_texts = []
      add_text(114, 19 + 16, 60, 16, texts[15]) # HP
      @stat_name_texts << add_text(114, 19 + 32, 60, 16, texts[18]) # Attack
      @stat_name_texts << add_text(114, 19 + 48, 60, 16, texts[20]) # Defense
      @stat_name_texts << add_text(114, 19 + 64, 120, 16, texts[26]) # Speed
      @stat_name_texts << add_text(114, 19 + 80, 120, 16, texts[22]) # Attack Spe
      @stat_name_texts << add_text(114, 19 + 96, 95, 16, texts[24]) # Defense Spe
      # --- Data part ---
      add_text(114, 19 + 16, 95, 16, :hp_text, 2, type: SymText, color: 1)
      add_text(114, 19 + 32, 95, 16, :atk_basis, 2, type: SymText, color: 1)
      add_text(114, 19 + 48, 95, 16, :dfe_basis, 2, type: SymText, color: 1)
      add_text(114, 19 + 64, 95, 16, :spd_basis, 2, type: SymText, color: 1)
      add_text(114, 19 + 80, 95, 16, :ats_basis, 2, type: SymText, color: 1)
      add_text(114, 19 + 96, 95, 16, :dfs_basis, 2, type: SymText, color: 1)
      init_ev_iv
    end
	# Create the HP Bar for the pokemon Copy/Paste from Menu_Party
    # @return [UI::Bar]
    def create_hp_bar
      bar = Bar.new(@viewport,25, 129, RPG::Cache.interface('team/HPBars'), 52, 4, 0, 0, 3)
      # Define the data source of the HP Bar
      bar.data_source = :hp_rate
      return bar
    end
    # Init the ev/iv texts
    def init_ev_iv
      offset = 102
      # --- EV part ---
      if SHOW_EV
        add_text(114 + offset, 19 + 16, 95, 16, :ev_hp_text, type: SymText)
        add_text(114 + offset, 19 + 32, 95, 16, :ev_atk_text, type: SymText)
        add_text(114 + offset, 19 + 48, 95, 16, :ev_dfe_text, type: SymText)
        add_text(114 + offset, 19 + 64, 95, 16, :ev_spd_text, type: SymText)
        add_text(114 + offset, 19 + 80, 95, 16, :ev_ats_text, type: SymText)
        add_text(114 + offset, 19 + 96, 95, 16, :ev_dfs_text, type: SymText)
        offset += 44
      end
      # --- IV part ---
      if SHOW_IV
        add_text(114 + offset, 19 + 16, 95, 16, :iv_hp_text, type: SymText)
        add_text(114 + offset, 19 + 32, 95, 16, :iv_atk_text, type: SymText)
        add_text(114 + offset, 19 + 48, 95, 16, :iv_dfe_text, type: SymText)
        add_text(114 + offset, 19 + 64, 95, 16, :iv_spd_text, type: SymText)
        add_text(114 + offset, 19 + 80, 95, 16, :iv_ats_text, type: SymText)
        add_text(114 + offset, 19 + 96, 95, 16, :iv_dfs_text, type: SymText)
      end
    end
  end
end
