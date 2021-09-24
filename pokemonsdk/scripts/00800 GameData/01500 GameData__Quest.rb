#encoding: utf-8

module GameData
  # Quest data structure
  # @author Nuri Yuri
  class Quest < Base
    # List of required items to find (IDs)
    # @return [Array<Integer>, nil]
    attr_accessor :items
    # On the same index as items, the amount of items required
    # @return [Array<Integer>, nil]
    attr_accessor :item_amount
    # List of NPC name the player has to speack to
    # @return [Array<String>, nil]
    attr_accessor :speak_to
    # List of Pokemon (ID) to see
    # @return [Array<Integer>, nil]
    attr_accessor :see_pokemon
    # List of Pokemon (ID) to beat
    # @return [Array<Integer>, nil]
    attr_accessor :beat_pokemon
    # On the same index as beat, the number of Pokemon to beat
    # @return [Array<Integer>, nil]
    attr_accessor :beat_pokemon_amount
    # List of Pokemon (ID) to catch
    # @return [Array<Integer>, nil]
    attr_accessor :catch_pokemon
    # On the same index as catch_pokemon, the number of Pokemon to catch
    # @return [Array<Integer>, nil]
    attr_accessor :catch_pokemon_amount
    # List of NPC name to beat
    # @return [Array<String>, nil]
    attr_accessor :beat_npc
    # On the same index, the number of time to beat the NPC
    # @return [Array<Integer>, nil]
    attr_accessor :beat_npc_amount
    # Amount of egg to get
    # @return [Integer, nil]
    attr_accessor :get_egg_amount
    # Amount of egg to hatch
    # @return [Integer, nil]
    attr_accessor :hatch_egg_amount
    # List of earnings
    # @return [Array<Hash>, nil]
    attr_accessor :earnings
    # If the quest is a primary quest
    # @return [Boolean]
    attr_accessor :primary
    # The goal order of the quest
    attr_writer :goal_order
    # The shown goal when the quest starts
    attr_writer :shown_goal
    # Get the goal order of the quest
    # @return [Array<Symbol>]
    def goal_order
      return @goal_order if @goal_order
      arr = @goal_order = []
      arr.concat(Array.new(@speak_to.size, :speak_to)) if @speak_to
      arr.concat(Array.new(@items.size, :items)) if @items
      arr.concat(Array.new(@see_pokemon.size, :see_pokemon)) if @see_pokemon
      arr.concat(Array.new(@beat_pokemon.size, :beat_pokemon)) if @beat_pokemon
      arr.concat(Array.new(@catch_pokemon.size, :catch_pokemon)) if @catch_pokemon
      arr.concat(Array.new(@beat_npc.size, :beat_npc)) if @beat_npc
      arr << :get_egg_amount if @get_egg_amount
      arr << :hatch_egg_amount if @hatch_egg_amount
      return arr
    end
    alias get_goal_order goal_order
    # Get the shown goal when the quest starts
    # @return [Array<Boolean>]
    def shown_goal
      return @shown_goal if @shown_goal
      return @shown_goal = Array.new(get_goal_order.size, true)
    end
    alias get_shown_goal shown_goal
    # If the quest is a primary quest
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean]
    def self.is_primary?(quest_id)
      if quest = $game_data_quest.fetch(quest_id, nil)
        return quest.primary
      end
      return false
    end
    # Return the quest data
    # @param quest_id [Integer] ID of the quest in the database
    # @return [GameData::Quest, nil
    def self.quest(quest_id)
      return $game_data_quest.fetch(quest_id, nil)
    end
    # If the quest require to get items
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean]
    def self.has_item?(quest_id)
      quest = $game_data_quest.fetch(quest_id, nil)
      return false unless quest and quest.items
      return quest.items.size > 0
    end
    # List of item to get for a quest
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Array<Integer>]
    def self.items(quest_id)
      quest = $game_data_quest.fetch(quest_id)
      return [] unless quest and quest.items
      return quest.items
    end
    # The quantity of item to get for a quest
    # @param quest_id [Integer] ID of the quest in the database
    # @param item_id [Integer] ID of the item in the database
    # @return [Integer]
    def self.item_amount(quest_id, item_id)
      quest = $game_data_quest.fetch(quest_id, nil)
      return 0 unless quest and quest.items and quest.item_amount
      index = quest.items.index(item_id)
      return 0 unless index
      return quest.item_amount[index].to_i
    end
    # Does the quest require to speak to a NPC
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean]
    def self.has_to_speak?(quest_id)
      quest = $game_data_quest.fetch(quest_id, nil)
      return false unless quest and quest.speak_to
      return quest.speak_to.size > 0
    end
    # List of NPC to speak to
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Array<String>]
    def self.speak_to(quest_id)
      quest = $game_data_quest.fetch(quest_id, nil)
      return [] unless quest and quest.speak_to
      return quest.speak_to
    end
    # Does the quest require to see Pokemon
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean]
    def self.has_to_see_pokemon?(quest_id)
      quest = $game_data_quest.fetch(quest_id, nil)
      return false unless quest and quest.see_pokemon
      return quest.see_pokemon.size > 0
    end
    # List of Pokemon to see
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Array<Integer]
    def self.see_pokemon(quest_id)
      quest = $game_data_quest.fetch(quest_id, nil)
      return [] unless quest and quest.see_pokemon
      return quest.see_pokemon
    end
    # Does the quest require to beat pokemon
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean]
    def self.has_to_beat_pokemon?(quest_id)
      quest = $game_data_quest.fetch(quest_id, nil)
      return false unless quest and quest.beat_pokemon
      return quest.beat_pokemon.size > 0
    end
    # List of Pokemon to beat
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Array<Integer]
    def self.beat_pokemon(quest_id)
      quest = $game_data_quest.fetch(quest_id)
      return [] unless quest and quest.beat_pokemon
      return quest.beat_pokemon
    end
    # How many time the Pokemon should be defeated
    # @param quest_id [Integer] ID of the quest in the database
    # @param pokemon_id [Integer] ID of the Pokemon in the database
    # @return [Integer]
    def self.beat_pokemon_amount(quest_id, pokemon_id)
      quest = $game_data_quest.fetch(quest_id, nil)
      return 0 unless quest and quest.beat_pokemon and quest.beat_pokemon_amount
      index = quest.beat_pokemon.index(pokemon_id)
      return 0 unless index
      return quest.beat_pokemon_amount[index].to_i
    end
    # Does the quest require to catch Pokemon
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean]
    def self.has_to_catch_pokemon?(quest_id)
      quest = $game_data_quest.fetch(quest_id, nil)
      return false unless quest and quest.catch_pokemon
      return quest.catch_pokemon.size > 0
    end
    # List of Pokemon to catch
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Array<Integer>]
    def self.catch_pokemon(quest_id)
      quest = $game_data_quest.fetch(quest_id)
      return [] unless quest and quest.catch_pokemon
      return quest.catch_pokemon
    end
    # Number of specific Pokemon to catch
    # @param quest_id [Integer] ID of the quest in the database
    # @param pokemon_id [Integer] ID of the Pokemon in the database
    # @return [Integer]
    def self.catch_pokemon_amount(quest_id, pokemon_id)
      quest = $game_data_quest.fetch(quest_id, nil)
      return 0 unless quest and quest.catch_pokemon and quest.catch_pokemon_amount
      index = quest.catch_pokemon.index(pokemon_id)
      return 0 unless index
      return quest.catch_pokemon_amount[index].to_i
    end
    # Does the quest require to beat NPC
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean]
    def self.has_to_beat_npc?(quest_id)
      quest = $game_data_quest.fetch(quest_id, nil)
      return false unless quest and quest.beat_npc
      return quest.beat_npc.size > 0
    end
    # List of NPC to beat (Names)
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Array<String>]
    def self.beat_npc(quest_id)
      quest = $game_data_quest.fetch(quest_id, nil)
      return [] unless quest and quest.beat_npc
      return quest.beat_npc
    end
    # List of number of time a NPC should be defeated
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Array<Integer>]
    def self.beat_npc_amount(quest_id)
      quest = $game_data_quest.fetch(quest_id, nil)
      return [] unless quest and quest.beat_npc_amount
      return quest.beat_npc_amount
    end
    # Does the quest require to get egg
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean]
    def self.has_to_get_egg?(quest_id)
      quest = $game_data_quest.fetch(quest_id, nil)
      return false unless quest and quest.get_egg_amount
      return quest.get_egg_amount > 0
    end
    # Number of egg to get
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Integer]
    def self.get_egg_amount(quest_id)
      quest = $game_data_quest.fetch(quest_id, nil)
      return 0 unless quest and quest.get_egg_amount
      return quest.get_egg_amount
    end
    # Does the quest require to hatch egg
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean]
    def self.has_to_hatch_egg?(quest_id)
      quest = $game_data_quest.fetch(quest_id, nil)
      return false unless quest and quest.hatch_egg_amount
      return quest.hatch_egg_amount > 0
    end
    # Number of egg to hatch
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Integer]
    def self.hatch_egg_amount(quest_id)
      quest = $game_data_quest.fetch(quest_id, nil)
      return 0 unless quest and quest.hatch_egg_amount
      return quest.hatch_egg_amount
    end
  end
end
