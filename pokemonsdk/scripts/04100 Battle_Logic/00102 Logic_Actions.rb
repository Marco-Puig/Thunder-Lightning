module Battle
  class Logic
    # Add actions to process in the next step
    # @param actions [Array<Hash>] the list of the actions
    def add_actions(actions)
      # Remove the empty action (dead pokemon)
      actions.delete_if(&:empty?)
      # Merge the actions
      @actions.concat(actions)
    end

    # Execute the next action
    # @return [Boolean] if there was an action or not
    def perform_next_action
      return false if @actions.empty?
      action = @actions.pop
      # TODO : call the right handler
      return true
    end

    # Sort the actions
    # @note The last action in the stack is the first action to pop out from the stack
    def sort_actions

    end
  end
end
