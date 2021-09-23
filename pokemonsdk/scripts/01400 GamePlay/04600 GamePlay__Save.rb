module GamePlay
  # Save game interface
  class Save < Base
    # Windowskin used to save the game
    Windowskin = 'message'
    # Base filename of the save file
    BASE_FILENAME = 'Saves/Pokemon_Party'
    # Corrupted save file message
    CORRUPTED_FILE_MESSAGE = 'Corrupted Save File'
    # Unkonw location text
    UNKNOWN_ZONE = 'Zone ???'
    # Time format
    DispTime = '%02d:%02d'
    # MultiSave file format
    MULTI_SAVE_FORMAT = '%s-%d'
    # List of the usable root path for the save state
    SAVE_ROOT_PATHS = [
      '.',
      ENV['APPDATA'] || Dir.home,
      Dir.home
    ]
    # @return [Integer] index of the save file (to allow multi-save)
    @@save_index = 0
    # Create a new GamePlay::Save interface
    # @param no_message [Boolean] tell the upper interface to disable message processing
    def initialize(no_message = false)
      super(no_message)
      make_save_directory
      # Instanciate IVARs
      @pokemon_party = nil
      @filename = Save.save_filename
      @fileexist = File.exist?(@filename)
      # Making Windows
      instanciate_windows
      build_window if @fileexist
    end

    # Function processing the Save interface
    def main_process
      save_question = text_get(26, 15)
      yes = text_get(25, 20)
      no = text_get(25, 21)
      # Dont save the game if the player don't answer yes (0), make no (1) the default option
      return unless display_message(save_question, 1, yes, no) == 0
      save_game
      saved_message = parse_text(26, 17, TRNAME[0] => $trainer.name)
      display_message(saved_message)
    end

    # Function that instanciate the windows
    def instanciate_windows
      @save_window = Game_Window.new
      @save_window.x = 2
      @save_window.y = 2
      @save_window.z = 10_001
      @save_window.width = 200
      @save_window.height = 108
      @save_window.windowskin = RPG::Cache.windowskin(Windowskin)
      @save_window.visible = false
    end

    # Function creating the save directory
    def make_save_directory
      directory = File.dirname(Save.save_filename)
      Dir.mkdir!(directory)
    end

    # Function that builds the save window (text + visibility)
    # @param win [Game_Window] the built window
    def build_window(win = @save_window)
      @pokemon_party = pokemon_party = current_pokemon_party || Save.load
      win.visible = true
      width = 168
      if pokemon_party
        win.add_text(0, 0, width, 16, retreive_zone_name(pokemon_party), 0).load_color(3)
        # Show the continue text
        win.add_text(0, 16, width, 16, text_get(25, 0), 0) if self.class != Save
        # Show the badge part
        win.add_text(0, 32, width, 16, text_get(25, 1), 0)
        win.add_text(0, 32, width, 16, pokemon_party.trainer.badge_counter, 2).load_color(1)
        # Show the Pokedex part
        win.add_text(0, 48, width, 16, text_get(25, 3), 0)
        win.add_text(0, 48, width, 16, pokemon_party.pokedex.pokemon_seen, 2).load_color(1)
        # Show the game time part
        win.add_text(0, 64, width, 16, text_get(25, 5), 0)
        win.add_text(0, 64, width, 16, retreive_play_time(pokemon_party), 2).load_color(1)
        # Show player name
        win.add_text(0, 16, width, 16, pokemon_party.trainer.name, 2)
           .load_color(pokemon_party.trainer.playing_girl ? 2 : 1)
      else
        # Show the corrupted message
        win.add_text(0, 0, width, 16, CORRUPTED_FILE_MESSAGE, 1).load_color(2)
        @save_window.height = 44
      end
    end

    # Function that returns the formated game time
    # @param pokemon_party [PFM::Pokemon_Party] the save state
    def retreive_play_time(pokemon_party)
      time = pokemon_party.trainer.play_time
      hours = time / 3600
      minutes = (time - 3600 * hours) / 60
      format(DispTime, hours, minutes)
    end

    # Function that return the zone name
    # @param pokemon_party [PFM::Pokemon_Party] the save state
    def retreive_zone_name(pokemon_party)
      zone = pokemon_party.env.get_current_zone
      return $game_data_zone[zone].map_name if zone && $game_data_zone[zone]
      UNKNOWN_ZONE
    end

    # Function that saves the game
    def save_game
      GamePlay::Save.save(@filename)
    end

    # Function that disposes the scene
    def dispose
      @save_window.dispose
      $game_temp.message_window_showing = false
      super
    end

    # Return the current Pokemon_Party object
    # @return [Pokemon_Party, nil]
    def current_pokemon_party
      $pokemon_party
    end

    class << self
      # Save a game
      # @param filename [String, nil] name of the save file (nil = auto name the save file)
      def save(filename = nil)
        # Fix the filename for event processing
        filename ||= Save.save_filename
        # Clear states
        $game_temp.message_proc = nil
        $game_temp.choice_proc = nil
        $game_temp.battle_proc = nil
        $game_temp.message_window_showing = false
        # Update informations about the save and make the game ready to save
        $game_system.save_count += 1
        $trainer.update_play_time
        $trainer.current_version = PSDK_Version
        $trainer.game_version = Game_Version
        $game_map.begin_save
        # Build the save data
        save_data = 'PKPRT'
        save_data << Marshal.dump($pokemon_party)
        # Save the game
        File.binwrite(filename, save_data)
        # Make the game ready to play again
        $game_map.end_save
      end

      # Load a game
      # @param filename [String, nil] name of the save file (nil = auto name the save file)
      # @return [PFM::Pokemon_Party, nil] The save data (nil = no save data / data corruption)
      # @note Change $pokemon_party
      def load(filename = nil)
        filename ||= Save.save_filename
        return nil unless File.exist?(filename)
        File.open(filename, 'rb') do |save_file|
          raise LoadError, 'Fichier corrompu' if save_file.read(5) != 'PKPRT'
          $pokemon_party = Marshal.load(save_file)
          $pokemon_party.load_parameters
          return $pokemon_party
        end
      rescue LoadError, StandardError
        return nil
      end

      def save_root_path
        SAVE_ROOT_PATHS.find(&File.method(:writable?)) || ''
      end

      def save_filename
        root = save_root_path.tr('\\', '/').encode(Encoding::UTF_8)
        game_name = root.start_with?('.') ? '' : ".#{Config::Title}/"
        filename = (@@save_index > 0 ? format(MULTI_SAVE_FORMAT, BASE_FILENAME, @@save_index) : BASE_FILENAME)
        return format('%<root>s/%<game_name>s%<filename>s', root: root, game_name: game_name, filename: filename)
      end
    end
  end
end
