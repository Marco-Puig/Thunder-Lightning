module GamePlay
  class Load
    # Create a new game and start it
    def create_new_game
      create_new_party
      $pokemon_party.expand_global_var
      $pokemon_party.load_parameters
      $trainer.redefine_var
      $scene = Scene_Map.new
      Yuki::TJN.force_update_tone
      @running = false
    end

    private

    # Load the current game
    def load_game
      $pokemon_party = @all_saves[@index]
      $pokemon_party.expand_global_var
      $pokemon_party.load_parameters
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
      $trainer.redefine_var
      Yuki::FollowMe.set_battle_entry
      $pokemon_party.env.reset_zone
      $scene = Scene_Map.new
      Yuki::TJN.force_update_tone
      @running = false
    end

    # Creaye a new Pokemon Party object and ask the language if possible
    def create_new_party
      # No language choice => default language
      if PSDK_CONFIG.choosable_language_code.empty?
        $pokemon_party = PFM::Pokemon_Party.new(false, PSDK_CONFIG.default_language_code)
      else
        # This will create the $pokemon_party object
        call_scene(Language_Choice) { @running = false }
      end
    end
  end
end
