module UI
  # UI part displaying the "Memo" of the Pokemon in the Summary
  class Summary_Memo < SpriteStack
    # Create a new Memo UI for the summary
    # @param viewport [Viewport]
    def initialize(viewport)
      super(viewport, 0, 0, default_cache: :interface)
      push(0, 0, 'summary/memo')
      @invisible_if_egg = []
      init_memo
      @text_info = add_text(13, 138, 294, 16, '')
      no_egg @exp_container = push(30, 129, RPG::Cache.interface('exp_bar'))
      no_egg @exp_bar = push_sprite(create_exp_bar)
      @exp_bar.data_source = :exp_rate
    end

    # Set an object inivisible if the Pokemon is an egg
    # @param object [#visible=] the object that is invisible if the Pokemon is an egg
    def no_egg(object)
      @invisible_if_egg << object
      return object
    end

    # Define the pokemon shown by this UI
    # @param pokemon [PFM::Pokemon]
    def data=(pokemon)
      if (self.visible = !pokemon.nil?)
        super
        @invisible_if_egg.each { |sprite| sprite.visible = false } if pokemon.egg?
        @level_text.x = @level_value.x + @level_value.width - @level_value.real_width -
                        @level_text.real_width - 2
        load_text_info(pokemon)
      end
    end

    # Change the visibility of the ui
    # @param value [Boolean] new visibility
    def visible=(value)
      super
      @invisible_if_egg.each { |sprite| sprite.visible = false } if @data&.egg?
    end

    # Initialize the Memo part
    def init_memo
      texts = text_file_get(27)
      # --- Static part ---
      add_text(114, 19, 60, 16, texts[2]) # Nom
      no_egg add_text(114, 19 + 16, 60, 16, texts[0]) # NoPokedex
      @level_text = no_egg(add_text(114 + 97, 19 + 16, 60, 16, texts[29])) # Level
      no_egg add_text(114, 19 + 32, 60, 16, texts[3]) # Type
      no_egg add_text(114, 19 + 48, 60, 16, texts[8]) # DO
      no_egg add_text(114 + 97, 19 + 48, 60, 16, texts[9]) # Numero id
      no_egg add_text(114, 19 + 64, 120, 16, texts[10]) # Pt exp
      no_egg add_text(114, 19 + 80, 120, 16, texts[12]) # Next lvl
      no_egg add_text(114, 19 + 96, 95, 16, text_get(23, 7)) # Objet
      # --- Data part ---
      with_font(20) { no_egg add_text(11, 125, 56, 13, 'EXP') }
      add_text(114, 19, 194, 16, :name, 2, type: SymText, color: 1)
      no_egg add_text(114, 19 + 16, 95, 16, :id_text, 2, type: SymText, color: 1)
      @level_value = no_egg(add_text(114 + 97, 19 + 16, 95, 16, :level_text, 2, type: SymText, color: 1))
      no_egg push(241, 19 + 34, nil, type: Type1Sprite)
      no_egg push(275, 19 + 34, nil, type: Type2Sprite)
      no_egg add_text(114, 19 + 48, 90, 16, :trainer_name, 2, type: SymText, color: 1)
      no_egg add_text(114 + 97, 19 + 48, 97, 16, :trainer_id_text, 2, type: SymText, color: 1)
      no_egg add_text(114, 19 + 64, 194, 16, :exp_text, 2, type: SymText, color: 1)
      no_egg add_text(114, 19 + 80, 194, 16, :exp_remaining_text, 2, type: SymText, color: 1)
      no_egg add_text(114, 19 + 96, 194, 16, :item_name, 2, type: SymText, color: 1)
    end

    # Load the text info
    # @param pokemon [PFM::Pokemon]
    def load_text_info(pokemon)
      return load_egg_text_info(pokemon) if pokemon.egg?

      time = Time.new
      time -= (time.to_i - 1)
      time += pokemon.captured_at
      time_egg = Time.new
      time_egg -= (time_egg.to_i - 1)
      time_egg += pokemon.egg_at if pokemon.egg_at
      hash = {
        '[VAR NUM2(0007)]' => time_egg.strftime('%d'),
        '[VAR NUM2(0006)]' => time_egg.strftime('%m'),
        '[VAR NUM2(0005)]' => time_egg.strftime('%y'),
        '[VAR LOCATION(0008)]' => pokemon.egg_zone_name,
        '[VAR NUM3(0003)]' => pokemon.captured_level.to_s,
        '[VAR NUM2(0002)]' => time.strftime('%d'),
        '[VAR NUM2(0001)]' => time.strftime('%m'),
        '[VAR NUM2(0000)]' => time.strftime('%y'),
        '[VAR LOCATION(0004)]' => pokemon.captured_zone_name
      }
      mem = pokemon.memo_text || []
      text = parse_text(mem[0] || 28, mem[1] || 25, hash).gsub(/([0-9.]) ([a-z]+ *)\:/i) { "#{$1} \n#{$2}:" }
      text.gsub!('Level', "\nLevel") if $options.language == 'en'
      @text_info.multiline_text = text
    end

    def create_exp_bar
      bar = Bar.new(@viewport, 31, 130, RPG::Cache.interface('bar_exp'), 73, 2, 0, 0, 1)
      # Define the data source of the EXP Bar
      bar.data_source = :exp_rate
      return bar
    end

    # Load the text info when it's an egg
    # @param pokemon [PFM::Pokemon]
    def load_egg_text_info(pokemon)
      time_egg = Time.new
      time_egg -= (time_egg.to_i - 1)
      time_egg += pokemon.egg_at if pokemon.egg_at
      hash = {
        '[VAR NUM2(0007)]' => time_egg.strftime('%d'),
        '[VAR NUM2(0006)]' => time_egg.strftime('%m'),
        '[VAR NUM2(0005)]' => time_egg.strftime('%y'),
        '[VAR LOCATION(0008)]' => pokemon.egg_zone_name,
        '[VAR NUM3(0003)]' => pokemon.captured_level.to_s,
        '[VAR LOCATION(0004)]' => pokemon.captured_zone_name
      }
      if pokemon.step_remaining > 10_240
        text = parse_text(28, 89, hash).gsub(/([0-9.]) ([a-z]+ *)\:/i) { "#{$1} \n#{$2}:" }
      elsif pokemon.step_remaining > 2_560
        text = parse_text(28, 88, hash).gsub(/([0-9.]) ([a-z]+ *)\:/i) { "#{$1} \n#{$2}:" }
      elsif pokemon.step_remaining > 1_280
        text = parse_text(28, 87, hash).gsub(/([0-9.]) ([a-z]+ *)\:/i) { "#{$1} \n#{$2}:" }
      else
        text = parse_text(28, 86, hash).gsub(/([0-9.]) ([a-z]+ *)\:/i) { "#{$1} \n#{$2}:" }
      end
      text.gsub!('Level', "\nLevel") if $options.language == 'en'
      @text_info.multiline_text = text # .gsub(/([^.]\.|\?|\!) /) { "#{$1} \n" }
    end
  end
end
