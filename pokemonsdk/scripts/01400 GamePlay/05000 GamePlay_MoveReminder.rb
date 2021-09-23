module GamePlay
  # Move reminder Scene
  class Move_Reminder < Base
    BACKGROUND = 'MR_UI'
    CURSOR = 'ball_selec'
    # @return [Boolean] if the pokemon learnt a move
    attr_reader :return_data
    # Create a new Move_Reminder Scene
    # @param pokemon [PFM::Pokemon] pokemon that should learn a move
    # @param mode [Integer] Define the moves you can see :
    #   1 = breed_moves + learnt + potentially_learnt
    #   2 = all moves
    #   other = learnt + potentially_learnt
    def initialize(pokemon, mode = 0)
      super
      @index = 0
      @pokemon = pokemon
      @move_set = pokemon.remindable_skills(mode)
      @viewport = Viewport.create(:main, 1000)
      @ui = UI::Summary_Remind.new(@viewport, pokemon)
      @ui.mode = mode
      @ui.update_skills
      @last_index = @ui.learnable_skills.size - 1
    end

    # Update the scene
    def update
      if index_changed(:@index, :UP, :DOWN, @last_index)
        @ui.index = @index
      elsif Input.trigger?(:A)
        action_a
      elsif Input.trigger?(:B)
        $game_system.se_play($data_system.cancel_se)
        @return_data = false
        @running = false
      end
    end

    private

    # Call the Skill Learn UI when the player press A
    def action_a
      $game_system.se_play($data_system.decision_se)
      scene = GamePlay::Skill_Learn.new(@pokemon, @ui.learnable_skills[@index].id)
      scene.main
      if scene.learnt
        @return_data = true
        @running = false
      else
        Graphics.transition
      end
    end
  end
end
