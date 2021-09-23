module Battle
  class Visual
    # Method that show the skill choice and store it inside an instance variable
    # @param pokemon_index [Integer] Index of the Pokemon in the party
    # @return [Boolean] if the player has choose a skill
    def show_skill_choice(pokemon_index)
      # return :try_next if spc_cannot_use_this_pokemon?(pokemon_index)
      @locking = true
      @skill_choice_ui.reset(@battle_scene.logic.battler(0, pokemon_index))
      @skill_choice_ui.visible = true
      @battle_scene.message_window.visible = false
      # spc_start_bouncing_animation(pokemon_index)
      loop do
        @battle_scene.update
        @skill_choice_ui.update
        Graphics.update
        break if @skill_choice_ui.validated?
      end
      # spc_stop_bouncing_animation(pokemon_index)
      @battle_scene.message_window.visible = true
      @skill_choice_ui.visible = false
      @locking = false
      return @skill_choice_ui.result != :cancel
    end

    # Method that show the target choice once the skill was choosen
    # @return [Array<PFM::PokemonBattler, Battle::Move, Integer(bank), Integer(position)>, nil]
    def show_target_choice

    end
  end
end
