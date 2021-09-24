module Battle
  class Visual
    # Method that shows the trainer choice
    # @param pokemon_index [Integer] Index of the Pokemon in the party
    # @return [Symbol, nil] :attack, :bag, :pokemon, :flee, :cancel, :try_next
    def show_player_choice(pokemon_index)
      # return :try_next if spc_cannot_use_this_pokemon?(pokemon_index)
      @viewport.rect.height = @viewport_sub.rect.y
      @locking = true
      @player_choice_ui.reset
      @player_choice_ui.visible = true
      spc_show_message(pokemon_index)
      # spc_start_bouncing_animation(pokemon_index)
      loop do
        @battle_scene.update
        @player_choice_ui.update
        Graphics.update
        break if @player_choice_ui.validated?
      end
      # spc_stop_bouncing_animation(pokemon_index)
      @player_choice_ui.visible = false
      @locking = false
      return @player_choice_ui.result
    end

    # Show the message "What will X do"
    # @param pokemon_index [Integer]
    def spc_show_message(pokemon_index)
      pokemon = @battle_scene.logic.battler(0, pokemon_index)
      (window = @battle_scene.message_window).wait_input = false
      window.width = @viewport.rect.width - @player_choice_ui.width
      @battle_scene.display_message(_parse(18, 71, '[VAR 010C(0000)]' => pokemon.given_name))
    end
  end
end
