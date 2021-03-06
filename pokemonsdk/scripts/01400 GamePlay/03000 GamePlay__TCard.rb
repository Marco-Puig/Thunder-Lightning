module GamePlay
  # Scene displaying the trainer card
  class TCard < Base
    # Coordinates of the player sprite
    PLAYER_COORDINATES = [222, 49]
    # Surface given to the player sprite
    PLAYER_SURFACE = [80, 73]
    # @return [Hash{Boolean => String} Name of the trainer image
    PLAYER_SPRITE_NAME = { true => 'tcard/female', false => 'tcard/male' }
    # Coordinate of the first badge
    BADGE_ORIGIN_COORDINATE = [14, 30]
    # Offset between badges (x/y)
    BADGE_OFFSET = [48, 49]
    # Size of a badge in the badge image
    BADGE_SIZE = [32, 32]
    # Nmber of badge we can show in this UI
    BADGE_COUNT = 8

    # Create a new TCard interface
    def initialize
      super(true)
      @viewport = Viewport.create(:main, 10_000)
      create_main_background
      create_sub_background
      create_trainer_sprite
      create_badge_sprites
      create_texts
      create_mouse_button
      @counter = 0
    end

    # Create the main background sprite
    def create_main_background
      @main_background = Sprite.new(@viewport).set_bitmap('team/Fond', :interface)
    end

    # Create the sub background sprite (the dark surfaces in the TCard)
    def create_sub_background
      @sub_background = Sprite.new(@viewport).set_bitmap('tcard/background', :interface)
    end

    # Create the trainer sprite
    def create_trainer_sprite
      @trainer_sprite = Sprite.new(@viewport)
                        .set_bitmap(PLAYER_SPRITE_NAME[$trainer.playing_girl], :interface)
      # Adjust the origin of the sprite since the TCard has a smaller surface for the sprite
      @trainer_sprite.set_origin((@trainer_sprite.width - PLAYER_SURFACE.first) / 2,
                                 (@trainer_sprite.height - PLAYER_SURFACE.last) / 2)
      @trainer_sprite.set_position(*PLAYER_COORDINATES)
    end

    # Create the badge sprites
    def create_badge_sprites
      @badges = Array.new(BADGE_COUNT) do |index|
        sprite = Sprite.new(@viewport).set_bitmap('tcard/badges', :interface)
        sprite.set_position(BADGE_ORIGIN_COORDINATE.first + (index % 2) * BADGE_OFFSET.first,
                            BADGE_ORIGIN_COORDINATE.last + (index / 2) * BADGE_OFFSET.last)
        sprite.src_rect.set((index % 2) * BADGE_SIZE.first, (index / 2) * BADGE_SIZE.last, *BADGE_SIZE)
        sprite.visible = $trainer.has_badge?(index + 1)
        next(sprite)
      end
    end

    # Create the texts
    def create_texts
      @texts = UI::SpriteStack.new(@viewport)
      # Show the start time
      @texts.add_text(4, 4, 0, 16,
                      "#{text_get(34, 14)} #{Time.at($trainer.start_time).strftime('%d/%m/%Y')}",
                      color: 9)
      @texts.add_text(225, 4, 88, 16, "#{$pokemon_party.money}$", 2, color: 9)
      @texts.add_text(217, 26, 96, 16, $trainer.name, 1, color: 9)
      @texts.add_text(217, 128, 96, 16,
                      format('%<text>s %<id>05d', text: text_get(34, 2), id: $trainer.id % 100_000), color: 9)
      @texts.add_text(122, 156, 190, 16, "#{text_get(25, 1)} #{$trainer.badge_counter}", color: 9)
      @texts.add_text(122, 190, 190, 16, "#{text_get(25, 5)} #{current_play_time}", color: 9)
    end

    # Function that returns the actual play time of the trainer
    # @return [String] playtime formated like this %02d:%02d
    def current_play_time
      time = $trainer.update_play_time
      hours = time / 3600
      minutes = (time - 3600 * hours) / 60
      format('%<hours>02d %<sep>s %<mins>02d', hours: hours, sep: text_get(25, 6), mins: minutes)
    end

    # Function that create the mouse button (cancel / quit) with its background
    def create_mouse_button
      @mouse_button_bg = Sprite.new(@viewport).set_bitmap('tcard/button_background', :interface)
      @mouse_button_bg.set_position(0, @viewport.rect.height - @mouse_button_bg.height)
      @mouse_button_cancel = UI::DexCTRLButton.new(@viewport, 3) # 3 is for cancel
    end

    # Update the background animation
    def update_background_animation
      @main_background.set_origin((@main_background.ox - 0.5) % 16, (@main_background.oy - 0.5) % 16)
    end

    def update
      return unless super
      update_mouse_ctrl
      @running = false if Input.trigger?(:B)
      update_background_animation
    end

    # Update the mouse interaction with the ctrl buttons
    def update_mouse_ctrl
      if Mouse.trigger?(:left)
        @mouse_button_cancel.set_press(@mouse_button_cancel.simple_mouse_in?)
      elsif Mouse.released?(:left)
        @running = false if @mouse_button_cancel.simple_mouse_in?
        @mouse_button_cancel.set_press(false)
      end
    end

    # Dispose the interface
    def dispose
      super
      # @viewport.dispose
    end
  end
end
