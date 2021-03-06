module BattleUI
  # Abstraction helping to design player choice a way that complies to what Visual expect to handle
  module PlayerChoiceAbstraction
    # @!parse
    #   include GenericChoice
    # The result :attack, :bag, :pokemon, :flee, :cancel, :try_next, :action
    # @return [Symbol, nil]
    attr_reader :result
    # The possible action made by the player (other than choosing a sub action)
    # @return [Battle::Actions::Base]
    attr_reader :action
    # Get the index
    # @return [Integer]
    attr_reader :index

    # Reset the choice
    # @param can_switch [Boolean]
    def reset(can_switch)
      @action = nil
      @result = nil
      @can_switch = can_switch
      @index = 0
      scene.visual.set_info_state(:choice)
      super() if @super_reset
    end

    # If the player made a choice
    # @return [Boolean]
    def validated?
      !@result.nil? && (respond_to?(:done?, true) ? done? : true)
    end

    private

    # Force the action to use an item
    # @param item [GameData::Item]
    def use_item(item)
      @result = :action
      item_wrapper = PFM::ItemDescriptor.actions(item.id)
      user = scene.logic.battler(0, scene.player_actions.size)
      @action = Battle::Actions::Item.new(scene, item_wrapper, $bag, user)
    end

    # Set the choice as wanting to switch pokemon
    # @return [Boolean] if the operation was a success
    def choice_pokemon
      return false unless @can_switch

      @result = :pokemon
      return true
    end

    # Set the choice as wanting to flee
    # @return [Boolean] if the operation was a success
    def choice_flee
      return false unless @can_switch

      @result = :flee
      return true
    end

    # Set the choice as wanting to use a move
    # @return [Boolean] if the operation was a success
    def choice_attack
      @result = :attack
      return true
    end

    # Set the choice as wanting to use an item from bag
    # @return [Boolean] if the operation was a success
    def choice_bag
      @result = :bag
      return true
    end

    # Set the choice as wanting to cancel the choice
    # @return [Boolean] if the operation was a success
    def choice_cancel
      return false if scene.player_actions.empty?

      @result = :cancel
      return true
    end

    # Show failure for specific choice like Pokemon & Flee
    # @param play_buzzer [Boolean] tell if the buzzer sound should be played
    # @param show_hide [Boolean] tell if the choice should be hidden during the failure show
    def show_switch_choice_failure(play_buzzer: true, show_hide: true)
      $game_system.se_play($data_system.buzzer_se) if play_buzzer
      if show_hide
        hide
        scene.visual.animations << animation_handler[:hide_show]
        scene.visual.wait_for_animation
      end
      (handler = scene.logic.switch_handler).can_switch?(scene.logic.battler(0, scene.player_actions.size))
      handler.process_prevention_reason
      show if show_hide
    end
  end
end
