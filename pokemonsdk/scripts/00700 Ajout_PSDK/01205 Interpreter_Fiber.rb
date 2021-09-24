class Interpreter
  # Show a message with eventually a choice
  # @param string [String] message to show
  # @param cancel_type [Integer] option used to cancel (1 indexed position, 0 means no cancel)
  # @param choices [Array<String>] all the possible choice
  # @note This function should only be called from text events!
  # @example Simple message
  #   message("It's a message!")
  # @example Message from CSV files
  #   message(ext_text(csv_id, index))
  # @example Message with choice
  #   choice_result = message("You are wonkru or you are the enemy of wonkru!\nChoose !", 1, 'Wonkru', '*Knifed*')
  # @return [Integer] the choosen choice (0 indexed this time)
  def message(string, cancel_type = 0, *choices)
    choice_result = 0
    # Return false to the interpreter while the last message is shown
    Fiber.yield(false) while $game_temp.message_text
    $game_player.look_to(@event_id) unless $game_switches[::Yuki::Sw::MSG_Noturn]
    # Give info to allow the interpreter to work correctly
    @message_waiting = true
    $game_temp.message_proc = proc { @message_waiting = false }
    # Give the message info to the message engine
    $game_temp.message_text = string
    # Give the choice info
    if choices.any?
      $game_temp.choice_cancel_type = cancel_type
      $game_temp.choices = choices
      $game_temp.choice_max = choices.size
      $game_temp.choice_proc = proc { |n| choice_result = n }
    end
    # Give the control back to the interpreter
    Fiber.yield(true)
    # Return the result to the event
    return choice_result
  end
end
