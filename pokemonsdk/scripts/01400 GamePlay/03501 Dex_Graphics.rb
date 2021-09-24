module GamePlay
  class Dex
    private

    # Create all the graphics
    def create_graphics
      create_viewport
      create_background
      create_frame
      unless @page_id # If we're only showing a Pokemon Dex info we'll not create the other sprites
        create_list
        create_arrow
        create_scroll_bar
        create_progression
        create_worldmap
      end
      create_face
      create_info
      create_ctrls
    end

    # Update all the graphics
    def update_graphics
      update_background_animation
      update_arrow
    end

    # Update the background animation
    def update_background_animation
      @background.set_origin((@background.ox - 0.5) % 16, (@background.oy - 0.5) % 16)
    end

    # Update the arrow animation
    def update_arrow
      return unless @arrow&.visible
      return if Graphics.frame_count % 15 != 0
      @arrow.x += @arrow_direction
      @arrow_direction = 1 if @arrow.x <= 127
      @arrow_direction = -1 if @arrow.x >= 129
    end

    # Create the viewport and a Stack making the graphic creation easier
    def create_viewport
      @viewport = Viewport.create(:main, 50_000)
      @stack = SpriteStack.new(@viewport, default_cache: :pokedex)
    end

    # Create the background
    def create_background
      @background = @stack.add_background('fond')
    end

    # Create the Pokemon list
    def create_list
      @list = Array.new(6) { |i| DexButton.new(@viewport, i) }
    end

    # Create arrow (telling which Pokemon we're choosing)
    def create_arrow
      @arrow = @stack.add_sprite(127, 0, 'arrow')
    end

    # Create the scrollbar
    def create_scroll_bar
      @scrollbar = @stack.add_sprite(309, 36, 'scroll')
      @scrollbut = @stack.add_sprite(308, 41, 'but_scroll')
    end

    # Create the frame sprite
    def create_frame
      @frame = Sprite.new(@viewport)
    end

    # Create the face sprite ui
    def create_face
      @pokeface = DexWinSprite.new(@viewport)
    end

    # Create the progression ui
    def create_progression
      @seen_got = DexSeenGot.new(@viewport)
    end

    # Create the info ui
    def create_info
      @pokemon_info = DexWinInfo.new(@viewport)
      @pokemon_descr = @stack.add_text(11, 153, 298, 16, nil.to_s, color: 10)
    end

    # Create the worldmap ui
    def create_worldmap
      @pokemon_worldmap = GamePlay::WorldMap.new(:pokedex, $env.get_worldmap)
    end

    # Create the ctrls button
    def create_ctrls
      @ctrl = Array.new(4) { |i| DexCTRLButton.new(@viewport, i) }
    end
  end
end
