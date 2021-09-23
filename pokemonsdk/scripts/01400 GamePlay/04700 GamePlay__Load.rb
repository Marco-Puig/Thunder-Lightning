#encoding: utf-8

#noyard
module GamePlay
  class Load < Save
    # @return [String] Default language of the game
    DEFAULT_GAME_LANGUAGE = 'fr'
    # @return [Array] List of the languages the player can choose (empty list = no choice)
    LANGUAGE_CHOICE_LIST = %w[en fr es]
    # @return [Array] List of the language name when the player can choose
    LANGUAGE_CHOICE_NAME = %w[English French Spanish]
    # Create a new GamePlay::Load scene
    # @param delete_game [Boolean] if we should delete the save state
    def initialize(delete_game = false)
      @viewport = Viewport.create(:main, 1)
      @viewport.color = Color.new(162, 194, 204)
      super(false)
      @save_window.x = (@viewport.rect.width - @save_window.width) / 2
      @running = true
      @index = 0
      @max_index = (@fileexist ? 2 : 1)
      @delete_game = @fileexist & delete_game
      if @delete_game
        $pokemon_party = PFM::Pokemon_Party.new(false, @pokemon_party.options.language)
        $pokemon_party.expand_global_var
        @save_window.visible = false
      end
      new_game_window
      Graphics.sort_z
    end

    def main
      curr_scene = $scene
      check_up
      while @running && curr_scene == $scene
        Graphics.update
        update
      end
      ::Scheduler.start(:on_scene_switch, ::Scene_Title) unless @running
      dispose
    end

    def update
      return @message_window.update if @delete_game
      if Input.trigger?(:DOWN)
        @index += 1
        @index = 0 if @index >= @max_index
        refresh
      elsif Input.trigger?(:UP)
        @index -= 1
        @index = @max_index - 1 if @index < 0
        refresh
      elsif Input.trigger?(:A)
        action
      elsif Mouse.trigger?(:left)
        mouse_action
      elsif Input.trigger?(:B) && $scene.class == ::Scene_Title
        @running = false
      end
    end

    def new_game_window
      @new_window = Game_Window.new
      @new_window.x = 60
      @new_window.y = 112
      @new_window.z = 10_001
      @new_window.width = 200
      @new_window.height = 32
      @new_window.add_text(0, 0, 200, 16, ext_text(9000, 0))
      @new_window.opacity = 128
      @new_window.windowskin = RPG::Cache.windowskin(Windowskin)
      @new_window.visible = @save_window.visible && @pokemon_party
    end

    def action
      Graphics.freeze
      # @@save_index = @index
      if @fileexist && @index == 0
        load_game
      else
        $pokemon_party = PFM::Pokemon_Party.new(false, @pokemon_party&.options&.language || DEFAULT_GAME_LANGUAGE)
        $pokemon_party.expand_global_var
        $game_system.se_play($data_system.cursor_se)
        $game_map.update
      end
      $trainer.redefine_var
      Yuki::FollowMe.set_battle_entry
      $pokemon_party.env.reset_zone
      $scene = Scene_Map.new
      Yuki::TJN.force_update_tone
      @running = false
    end

    def mouse_action
      if @save_window.visible
        if @save_window.simple_mouse_in?
          @index = 0
          action
        end
      end
      if @new_window.visible && @new_window.simple_mouse_in?
        @index = 1
        action
      end
    end

    def load_game
      $pokemon_party = @pokemon_party
      $pokemon_party.expand_global_var
      $game_system.se_play($data_system.cursor_se)
      $game_map.setup($game_map.map_id)
      $game_player.moveto($game_player.x, $game_player.y) # center
      $game_party.refresh
      $game_system.bgm_play($game_system.playing_bgm)
      $game_system.bgs_play($game_system.playing_bgs)
      $game_map.update
      $game_temp.message_window_showing = false
      $trainer.load_time
      Pathfinding.load
    end

    def refresh
      if @fileexist
        @save_window.opacity = (@index != 0 ? 128 : 255)
      end
      @new_window.opacity = (@index != 1 ? 128 : 255)
    end

    def dispose
      @new_window&.dispose
      super
    end

    # Ask the player if he really wants to delete his game
    def delete_game_question
      Graphics.transition
      # Message break prevention
      Graphics.update while Input.press?(:B)
      scene = $scene
      $scene = self
      message = text_get(25, 18)
      oui = text_get(25, 20)
      non = text_get(25, 21)
      # Delete the game ?
      c = display_message(message, 1, non, oui)
      if c == 1
        message = text_get(25, 19)
        # Really ?
        c = display_message(message, 1, non, oui)
        if c == 1
          # Ok deleted!
          File.delete(@filename)
          message = text_get(25, 17)
          display_message(message)
        end
      end
      $scene = scene
      return @running = false
    end

    # Create a new game and start it
    def create_new_game
      # No language choice => default language
      if LANGUAGE_CHOICE_LIST.empty?
        $pokemon_party = PFM::Pokemon_Party.new(false, DEFAULT_GAME_LANGUAGE)
      else
        ask_game_language
      end
      $pokemon_party.expand_global_var
      $trainer.redefine_var
      $scene = Scene_Map.new
      Yuki::TJN.force_update_tone
      @running = false
    end

    # Ask the game language to the player
    def ask_game_language
      win1, win2 = create_language_window
      Graphics.transition
      loop do
        Graphics.update
        win2.update
        break if win2.validated?
      end
      Graphics.freeze
      $pokemon_party = PFM::Pokemon_Party.new(false, LANGUAGE_CHOICE_LIST[win2.index])
      win2.dispose
      win1.dispose
    end

    # Create the language window
    # @return [Array]
    def create_language_window
      win1 = Window.new
      win1.lock
      stack = UI::SpriteStack.new(win1)
      stack.add_text(0, 0, 160, 16, 'Choose your language')
      win1.set_position(80, 80)
      win1.set_size(160, 44)
      win1.window_builder = GameData::Windows::MessageWindow
      win1.windowskin = RPG::Cache.windowskin(Windowskin)
      win1.unlock
      win2 = Yuki::ChoiceWindow.new(160, LANGUAGE_CHOICE_NAME)
      win2.set_position(80, 128)
      win2.z = win1.z = 200
      Graphics.transition
      return win1, win2
    end

    # Check if the game states should be deleted or if the player should start a new game
    def check_up
      return delete_game_question if @delete_game
      return create_new_game unless @pokemon_party
      Graphics.transition
    end

    # Force the current pokemon party to be nil since we load the game
    # @return [nil]
    def current_pokemon_party
      nil
    end
  end
end
