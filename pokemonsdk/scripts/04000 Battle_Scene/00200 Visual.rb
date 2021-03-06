module Battle
  # Class that manage all the thing that are visually seen on the screen
  class Visual
    # Name of the background according to their processed zone_type
    BACKGROUND_NAMES = %w[back_building back_grass back_tall_grass back_taller_grass back_cave
                          back_mount back_sand back_pond back_sea back_under_water back_ice back_snow]

    # @return [Hash] List of the parallel animation
    attr_reader :parallel_animations

    # @return [Viewport] the viewport used to show the sprites
    attr_reader :viewport

    # @return [Viewport] the viewport used to show some UI part
    attr_reader :viewport_sub

    # @return [Array<Battle_UI::GroundSprite>] the ground sprites
    attr_reader :grounds

    # Create a new visual instance
    # @param battle_scene [Scene] scene that hold the logic object
    def initialize(battle_scene)
      @battle_scene = battle_scene
      @screenshot = Graphics.snap_to_bitmap
      # All the battler by bank
      @battlers = {}
      # All the bars by bank
      @info_bars = {}
      # All the team info bar by bank
      @team_info = {}
      # All the animation currently being processed (automatically removed)
      @animations = []
      # All the parallel animations (manually removed)
      @parallel_animations = {}
      # Is the visual locking the update of the battle
      @locking = false
      # Create all the sprites
      create_viewport
      create_background
      create_battlers
      create_player_choice
      create_skill_choice
    end

    # Update the visuals
    def update
      @animations.each(&:update)
      @animations.delete_if(&:done?)
      @parallel_animations.each_value(&:update)
      update_battlers
    end

    # Dispose the visuals
    def dispose
      @animations.clear
      @parallel_animations.clear
      @viewport.dispose
    end

    # Tell if the visual are locking the battle update (for transition purpose)
    def locking?
      @locking
    end

    # Unlock the battle scene
    def unlock
      @locking = false
    end

    private

    # Create the Visual viewport
    def create_viewport
      @viewport = Viewport.create(:main, 500)
      rc = @viewport.rect
      @viewport_sub = Viewport.new(rc.x, rc.y + rc.height - 48, rc.width, 48)
    end

    # Create the default background & the grounds that comes with it
    def create_background
      @background = ShaderedSprite.new(@viewport).set_bitmap(name = background_name, :battleback)
      @grounds = Array.new(@battle_scene.logic.bank_count) do |bank|
        Battle_UI::GroundSprite.new(@viewport, name, bank)
      end
    end

    # Return the background name according to the current state of the player
    # @return [String]
    def background_name
      return $game_temp.battleback_name unless $game_temp.battleback_name.to_s.empty?
      zone_type = $env.get_zone_type
      zone_type += 1 if zone_type > 0 || $env.grass?
      return BACKGROUND_NAMES[zone_type].to_s
    end

    # Create the battler sprites (Trainer + Pokemon)
    def create_battlers
      infos = @battle_scene.battle_info
      (logic = @battle_scene.logic).bank_count.times do |bank|
        # create the trainer sprites
        infos.battlers[bank].each_with_index do |battler, position|
          sprite = Battle_UI::TrainerSprite.new(@viewport, battler, bank, position, infos)
          store_battler_sprite(bank, -position - 1, sprite)
        end
        # Create the Pokemon sprites
        infos.vs_type.times do |position|
          sprite = Battle_UI::PokemonSprite.new(@viewport)
          sprite.pokemon = logic.battler(bank, position)
          store_battler_sprite(bank, position, sprite)
        end
      end
    end

    # Update the battler sprites
    def update_battlers
      @battlers.each_value do |battlers|
        battlers.each_value(&:update)
      end
    end

    # Create the player choice
    def create_player_choice
      @player_choice_ui = Battle_UI::PlayerChoice.new(@viewport_sub)
    end

    # Create the skill choice
    def create_skill_choice
      @skill_choice_ui = Battle_UI::SkillChoice.new(@viewport_sub)
    end
  end
end
