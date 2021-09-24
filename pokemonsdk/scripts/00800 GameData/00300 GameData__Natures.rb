#encoding: utf-8

module GameData
  # A module that help to retreive nature informations
  # @author Nuri Yuri
  module Natures
    module_function
    # Safely returns a nature info
    # @param nature_id [Integer] id of the nature
    # @return [Array<Integer>]
    def [](nature_id)
      if(nature_id>=0 and nature_id<$game_data_natures.size)
        return $game_data_natures[nature_id]
      end
      return $game_data_natures[0]
    end
    # Return the number of defined natures
    # @return [Integer]
    def size
      return $game_data_natures.size
    end
  end
end
