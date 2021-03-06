module Battle
  class Scene
    private

    # Method that ask for the player choice (it calls @visual.show_player_choice)
    def player_action_choice
      # If the battle does not allow player choice we skip
      return @next_update = :trigger_all_AI if no_player_action?
      # If the method was called and the player cannot make another choice it's a bug so we end the battle
      return @next_update = :battle_end unless can_player_make_another_action_choice?

      choice, forced_action = @visual.show_player_choice(@player_actions.size)
      log_debug("Player action choice : #{choice} / #{forced_action}")
      case choice
      when :attack
        # The player choose to attack, at next update will be skill_choice
        @next_update = :skill_choice
      when :bag
        # The player choose to open the bag, next update will be item_choice
        @next_update = :item_choice
      when :pokemon
        # The player choose to open the party, next update will be switch_choice
        @next_update = :switch_choice
      when :flee
        # The player wants to flee from the battle
        flee_attempt
      when :cancel
        # The player canceled, he wants to try an other strategy, we remove the last actions
        while (action = @player_actions.pop)
          clean_action(action)
          # If the action is not empty it was a Pokemon we could control so we stop poping
          break unless action&.is_a?(Actions::Base)
        end
      when :try_next
        # The visual interface detected that the current Pokemon is dead
        @player_actions << Actions::Base.new(self)
      when :action
        # The player choice returned an action to use
        @player_actions << forced_action
        @next_update = can_player_make_another_action_choice? ? :player_action_choice : :trigger_all_AI
      else
        # The visual interface detected an anomaly, we go to the end of the battle
        @next_update = :battle_end
      end
    ensure
      @skip_frame = true
    end

    # Method that asks for the skill the current Pokemon should use
    def skill_choice
      pokemon = logic.battler(0, @player_actions.size)
      if !pokemon.can_move?
        move = Battle::Move[:s_struggle].new(GameData::Skill[:struggle].id, 1, 1, self)
        @player_actions << Actions::Attack.new(self, move, pokemon, 1, pokemon.position)
        @next_update = can_player_make_another_action_choice? ? :player_action_choice : :trigger_all_AI
      elsif @visual.show_skill_choice(@player_actions.size)
        # The player choosed a move
        @next_update = :target_choice
      else
        # The player canceled
        @next_update = :player_action_choice
      end
    ensure
      @skip_frame = true
    end

    # Method that asks the target of the choosen move
    def target_choice
      launcher, skill, target_bank, target_position, mega = @visual.show_target_choice
      if launcher
        next_action = Actions::Attack.new(self, skill, launcher, target_bank, target_position)
        if mega
          @player_actions << [next_action, Actions::Mega.new(self, launcher)]
        else
          @player_actions << next_action
        end
        log_debug("Action : #{@player_actions.last}") if debug? # To prevent useless overhead outside debug
        @next_update = can_player_make_another_action_choice? ? :player_action_choice : :trigger_all_AI
      else
        # If the player canceled we return to the player action
        @next_update = :skill_choice
      end
    ensure
      @skip_frame = true
    end

    # Check if the player can make another action choice
    # @note push empty hash where Pokemon cannot be controlled
    # @return [Boolean]
    def can_player_make_another_action_choice?
      next_relative_mon = @player_actions.size.upto(@battle_info.vs_type - 1).find_index do |position|
        next false unless (pokemon = @logic.battler(0, position))

        next pokemon.alive? && pokemon.from_party?
      end
      return false unless next_relative_mon

      # We fill actions that player cannot control
      next_relative_mon.times { @player_actions << Actions::Base.new(self) }
      return true
    end

    # Tell if the player is not allowed to take any actions
    # @return [Boolean]
    def no_player_action?
      return true if @no_player_action

      return @logic.all_battlers.none?(&:from_party?)
    end

    # Method that asks the item to use
    def item_choice
      item_wrapper = @visual.show_item_choice
      if item_wrapper
        if item_wrapper.item.is_a?(GameData::FleeingItem)
          remove_item(@logic.battler(0, @player_actions.size).bag, item_wrapper, 1)
          @logic.battle_result = 1
          @next_update = :battle_end
        elsif item_wrapper.item.is_a?(GameData::BallItem)
          remove_item(@logic.battler(0, @player_actions.size).bag, item_wrapper, 1)
          if (caught = logic.catch_handler.try_to_catch_pokemon(logic.alive_battlers(1)[0], logic.alive_battlers(0)[0], item_wrapper.item))
            logic.battle_info.caught_pokemon = logic.alive_battlers(1)[0]
            give_pokemon_procedure(logic.battle_info.caught_pokemon.original, item_wrapper.item)
            @logic.battle_phase_end_caught
          end
          return @next_update = caught ? :battle_end : :trigger_all_AI
        end

        # The player made a choice we store the action and we check if he can make other choices
        @player_actions << Actions::Item.new(self, item_wrapper, @logic.battler(0, @player_actions.size).bag, @logic.battler(0, @player_actions.size))
        log_debug("Action : #{@player_actions.last}") if debug? # To prevent useless overhead outside debug
        @next_update = can_player_make_another_action_choice? ? :player_action_choice : :trigger_all_AI
      else
        # If the player canceled we return to the player action
        @next_update = :player_action_choice
      end
    end

    # Remove the item if it can be for Special Items
    # @param bag [PFM::Bag]
    # @param item_wrapper [PFM::ItemDescriptor::Wrapper]
    # @param amount [Integer]
    def remove_item(bag, item_wrapper, amount)
      return false unless item_wrapper.item.limited

      bag.remove_item(item_wrapper.item.id, amount)
    end

    # Begin the Pokemon giving procedure
    # @param pkmn [PFM::Pokemon] pokemon that was just caught
    # @param ball [GameData::BallItem]
    def give_pokemon_procedure(pkmn, ball)
      Audio.bgm_play(*@battle_info.victory_bgm)
      message_window.blocking = true
      message_window.wait_input = true
      $quests.catch_pokemon(pkmn)
      $quests.beat_pokemon(pkmn.id)
      $wild_battle.remove_roaming_pokemon(pkmn)
      display_message_and_wait(parse_text(18, 67, PKNAME[0] => pkmn.name))
      unless $pokedex.pokemon_caught?(pkmn.id)
        $pokedex.mark_captured(pkmn.id)
        if $pokedex.enabled?
          display_message_and_wait(parse_text(18, 68, PKNAME[0] => pkmn.name))
          call_scene(GamePlay::Dex, pkmn)
        end
      end
      $pokedex.pokemon_captured_inc(pkmn.id)
      # Rename
      if display_message_and_wait(parse_text(30, 0, PKNAME[0] => pkmn.name), 0, text_get(25, 20), text_get(25, 21)) == 0
        call_scene(GamePlay::NameInput, pkmn.name, 12, pkmn) do |scene|
          pkmn.given_name = scene.return_name
        end
      end
      $game_system.map_interpreter.add_pokemon(pkmn)
      # Stocked
      if $game_switches[Yuki::Sw::SYS_Stored]
        display_message_and_wait(parse_text(30, 1, PKNICK[0] => pkmn.given_name, '[VAR BOX(0001)]' => $storage.get_box_name($storage.current_box)))
      end
    end

    # Method that asks the pokemon to switch with
    def switch_choice
      pokemon_to_send = @visual.show_pokemon_choice
      if pokemon_to_send
        pokemon_to_switch = @logic.battler(0, @player_actions.size)
        # The player made a choice we store the action and we check if he can make other choices
        @player_actions << Actions::Switch.new(self, pokemon_to_switch, pokemon_to_send)
        pokemon_to_send.switching = true
        pokemon_to_switch.switching = true
        log_debug("Action : #{@player_actions.last}") if debug? # To prevent useless overhead outside debug
        @next_update = can_player_make_another_action_choice? ? :player_action_choice : :trigger_all_AI
      else
        # If the player canceled we return to the player action
        @next_update = :player_action_choice
      end
    end

    # Clean the action that was removed from the stack (Make sure we don't lock things)
    def clean_action(action)
      return unless action

      if action.is_a?(Actions::Switch)
        action = Actions::Switch.from(action)
        action.who.switching = false
        action.with.switching = false
      end
    end

    # Method that checks if the flee is possible
    def flee_attempt
      @message_window.width = @visual.viewport.rect.width
      @message_window.wait_input = true
      result = @logic.flee_handler.attempt(@player_actions.size)
      if result == :success
        @logic.battle_result = 1
        @next_update = :battle_end
      elsif result == :blocked
        @next_update = :player_action_choice
      else
        @next_update = :trigger_all_AI
      end
    end
  end
end
