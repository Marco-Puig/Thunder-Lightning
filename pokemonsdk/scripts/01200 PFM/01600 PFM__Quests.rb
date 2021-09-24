#encoding: utf-8

module PFM
  # The quest management
  # 
  # The main object is stored in $quests and $pokemon_party.quests
  class Quests
    # The list of active_quests
    # @return [Hash<Integer => Hash>]
    attr_accessor :active_quests
    # The list of finished_quests
    # @return [Hash<Integer => Hash>]
    attr_accessor :finished_quests
    # The list of failed_quests
    # @return [Hash<Integer => Hash>]
    attr_accessor :failed_quests
    # The signals that inform the game what quest started or has been finished
    # @return [Hash<start: Array<Integer>, finish: Array<Integer>, failed: Array<Integer>>]
    attr_accessor :signal
    # Create a new Quest management object
    def initialize
      @active_quests = {}
      @finished_quests = {}
      @failed_quests = {}
      @signal = {start: [], finish: [], failed: []} #Indicateur d'évènement (début / fin) de quêtes
    end
    # Convert the quest object for PSDK Alpha 23.0
    def __convert
      @failed_quests = {}
      @signal[:failed] = []
      #> Quest info conversion
      @active_quests.each do |quest_id, quest|
        quest_data = GameData::Quest.quest(quest_id)
        next unless quest_data && quest
        quest[:order] = quest_data.get_goal_order
        quest[:shown] = quest_data.get_shown_goal
      end
      @finished_quests.each do |quest_id, quest|
        quest_data = GameData::Quest.quest(quest_id)
        next unless quest_data && quest
        quest[:order] = quest_data.get_goal_order
        quest[:shown] = Array.new(quest[:order].size, true)
      end
    end
    # Start a new quest if possible
    # @param quest_id [Integer] the ID of the quest in the database
    # @return [Boolean] if the quest started
    def start(quest_id)
      return false if finished?(quest_id)
      return false if @active_quests.fetch(quest_id, nil) != nil
      quest_data = GameData::Quest.quest(quest_id)
      return false unless quest_data
      quest = @active_quests[quest_id] = {}
      quest[:items] = Array.new(quest_data.items.size, 0) if quest_data.items
      quest[:spoken] = Array.new(quest_data.speak_to.size, false) if quest_data.speak_to
      quest[:pokemon_seen] = Array.new(quest_data.see_pokemon.size, false) if quest_data.see_pokemon
      quest[:pokemon_beaten] = Array.new(quest_data.beat_pokemon.size, 0) if quest_data.beat_pokemon
      quest[:pokemon_catch] = Array.new(quest_data.catch_pokemon.size, 0) if quest_data.catch_pokemon
      quest[:npc_beaten] = Array.new(quest_data.beat_npc.size, 0) if quest_data.beat_npc
      quest[:egg_counter] = 0 if quest_data.get_egg_amount.to_i > 0
      quest[:egg_hatched] = 0 if quest_data.hatch_egg_amount.to_i > 0
      quest[:earnings] = false
      quest[:order] = quest_data.get_goal_order
      quest[:shown] = quest_data.get_shown_goal
      @signal[:start] << quest_id
      return true
    end
    # Show a goal of a quest
    # @param quest_id [Integer] the ID of the quest in the database
    # @param goal_index [Integer] the index of the goal in the goal order
    def show_goal(quest_id, goal_index)
      return if (quest = @active_quests.fetch(quest_id, nil)) == nil
      quest[:shown][goal_index] = true
    end
    # Tell if a goal is shown or not
    # @param quest_id [Integer] the ID of the quest in the database
    # @param goal_index [Integer] the index of the goal in the goal order
    # @return [Boolean]
    def goal_shown?(quest_id, goal_index)
      return false if (quest = @active_quests.fetch(quest_id, nil)) == nil
      return quest[:shown][goal_index]
    end
    # Get the goal data index (if array like items / speak_to return the index of the goal in the array info from data/quest data)
    # @param quest_id [Integer] the ID of the quest in the database
    # @param goal_index [Integer] the index of the goal in the goal order
    # @return [Integer]
    def get_goal_data_index(quest_id, goal_index)
      if (quest = @active_quests.fetch(quest_id, nil)) == nil
        if (quest = @finished_quests.fetch(quest_id, nil)) == nil
          return 0 if (quest = @failed_quests.fetch(quest_id, nil)) == nil
        end
      end
      goal_sym = quest[:order][goal_index]
      cnt = 0
      quest[:order].each_with_index do |sym, i|
        break if i >= goal_index
        cnt += 1 if sym == goal_sym
      end
      return cnt
    end
    # Get the goal type
    # @param quest_id [Integer] the ID of the quest in the database
    # @param goal_index [Integer] the index of the goal in the goal order
    # @return [Symbol]
    def get_goal_type(quest_id, goal_index)
      if (quest = @active_quests.fetch(quest_id, nil)) == nil
        if (quest = @finished_quests.fetch(quest_id, nil)) == nil
          return 0 if (quest = @failed_quests.fetch(quest_id, nil)) == nil
        end
      end
      return quest[:order][goal_index]
    end
    # Inform the manager that a NPC has been beaten
    # @param quest_id [Integer] the ID of the quest in the database
    # @param npc_name_index [Integer] the index of the name of the NPC in the quest data
    # @return [Boolean] if the quest has been updated
    def beat_npc(quest_id, npc_name_index)
      return false if (quest = @active_quests.fetch(quest_id, nil)) == nil
      return false unless quest[:npc_beaten]
      quest[:npc_beaten][npc_name_index] += 1
      check_quest(quest_id)
      return true
    end
    # Inform the manager that a NPC has been spoken to
    # @param quest_id [Integer] the ID of the quest in the database
    # @param npc_name_index [Integer] the index of the name of the NPC in the quest data
    # @return [Boolean] if the quest has been updated
    def speak_to_npc(quest_id, npc_name_index)
      return false if (quest = @active_quests.fetch(quest_id, nil)) == nil
      return false unless quest[:spoken]
      quest[:spoken][npc_name_index] = true
      check_quest(quest_id)
      return true
    end
    # Inform the manager that an item has been added to the bag of the Player
    # @param item_id [Integer] ID of the item in the database
    def add_item(item_id)
      quest_id = quest = quest_data = index = nil
      @active_quests.each do |quest_id, quest|
        if quest[:items]
          next unless quest_data = GameData::Quest.quest(quest_id)
          index = quest_data.items.index(item_id)
          quest[:items][index] += 1 if index
          check_quest(quest_id)
        end
      end
    end
    # Inform the manager that a Pokemon has been beaten
    # @param pokemon_id [Integer] ID of the Pokemon in the database
    def beat_pokemon(pokemon_id)
      quest_id = quest = quest_data = index = nil
      @active_quests.each do |quest_id, quest|
        if quest[:pokemon_beaten]
          next unless quest_data = GameData::Quest.quest(quest_id)
          index = quest_data.beat_pokemon.index(pokemon_id)
          quest[:pokemon_beaten][index] += 1 if index
          check_quest(quest_id)
        end
      end
    end
    # Inform the manager that a Pokemon has been captured
    # @param pokemon [PFM::Pokemon] the Pokemon captured
    def catch_pokemon(pokemon)
      quest_id = quest = quest_data = index = nil
      @active_quests.each do |quest_id, quest|
        if quest[:pokemon_catch]
          next unless quest_data = GameData::Quest.quest(quest_id)
          #index = quest_data.catch_pokemon.index(pokemon_id)
          quest_data.catch_pokemon.each_with_index do |pkm, index|
            if pkm.class == ::Hash
              next unless check_pokemon_criterion(pkm, pokemon)
            else
              next unless pokemon.id == pkm
            end
            quest[:pokemon_catch][index] += 1
          end
          check_quest(quest_id)
        end
      end
    end
    # Check the specific pokemon criterion in catch_pokemon
    # @param pkm [Hash] the criterions of the Pokemon
    #
    #   The criterions are :
    #     nature: opt Integer # ID of the nature of the Pokemon
    #     type: opt Integer # One required type id
    #     min_level: opt Integer # The minimum level the Pokemon should have
    #     max_level: opt Integer # The maximum level the Pokemon should have
    #     level: opt Integer # The level the Pokemon must be
    # @param pokemon [PFM::Pokemon] the Pokemon that should be check with the criterions
    # @return [Boolean] if the Pokemon pokemon check the criterions
    def check_pokemon_criterion(pkm, pokemon)
      return false if pkm[:nature] and pokemon.nature_id != pkm[:nature]
      return false if pkm[:type] and pokemon.type1 != pkm[:type] and pokemon.type2 != pkm[:type]
      return false if pkm[:min_level] and pokemon.level < pkm[:min_level]
      return false if pkm[:max_level] and pokemon.level > pkm[:max_level]
      return false if pkm[:level] and pokemon.level != pkm[:level]

      return true
    end
    # Inform the manager that a Pokemon has been seen
    # @param pokemon_id [Integer] ID of the Pokemon in the database
    def see_pokemon(pokemon_id)
      quest_id = quest = quest_data = index = nil
      @active_quests.each do |quest_id, quest|
        if quest[:pokemon_seen]
          next unless quest_data = GameData::Quest.quest(quest_id)
          index = quest_data.see_pokemon.index(pokemon_id)
          quest[:pokemon_seen][index] = true if index
          check_quest(quest_id)
        end
      end
    end
    # Inform the manager an egg has been found
    def get_egg
      quest_id = quest = quest_data = index = nil
      @active_quests.each do |quest_id, quest|
        if quest[:egg_counter]
          next unless quest_data = GameData::Quest.quest(quest_id)
          quest[:egg_counter] += 1
          check_quest(quest_id)
        end
      end
    end
    # Inform the manager an egg has hatched
    def hatch_egg
      quest_id = quest = quest_data = index = nil
      @active_quests.each do |quest_id, quest|
        if quest[:egg_hatched]
          next unless quest_data = GameData::Quest.quest(quest_id)
          quest[:egg_hatched] += 1
          check_quest(quest_id)
        end
      end
    end
    # Check the signals and display them
    def check_up_signal
      if @signal[:start].size > 0
        #> Afficher l'interface de démarrage de quête avec la liste @signal[:start]
        @signal[:start].each do |quest_id|
#          Yuki.send_notification("Nouvelle quête !", text_get(45, quest_id))
        end
      end
      if @signal[:finish].size > 0
        #> Pareil mais fin de quête avec @signal[:finish]
        @signal[:finish].each do |quest_id|
#          Yuki.send_notification("Quête terminée !", text_get(45, quest_id))
            if @active_quests.fetch(quest_id, nil)
                 @finished_quests[quest_id] = @active_quests.delete(quest_id)
            end
        end
      end
      @signal[:start].clear
      @signal[:finish].clear
    end
    # Check if a quest is done or not
    # @param quest_id [Integer] ID of the quest in the database
    def check_quest(quest_id)
      quest = @active_quests.fetch(quest_id, nil)
      quest_data = GameData::Quest.quest(quest_id)
      return unless quest and quest_data
      #> Vérification des objets
      if infos = quest[:items] and quest_data.item_amount
        quest_data.item_amount.each_with_index do |amount, index|
          return if infos[index] < amount
        end
      end
      #> Vérification des personne avec qui parler
      if infos = quest[:spoken]
        return if infos.include?(false)
      end
      #> Vérification des Pokémon vus
      if infos = quest[:pokemon_seen]
        return if infos.include?(false)
      end
      #> Vérification des Pokémon battus
      if infos = quest[:pokemon_beaten] and quest_data.beat_pokemon_amount
        quest_data.beat_pokemon_amount.each_with_index do |amount, index|
          return if infos[index] < amount
        end
      end
      #> Vérification des Pokémon capturés
      if infos = quest[:pokemon_catch] and quest_data.catch_pokemon_amount
        quest_data.catch_pokemon_amount.each_with_index do |amount, index|
          return if infos[index] < amount
        end
      end
      #> Vérification des NPC battus
      if infos = quest[:npc_beaten]
        quest_data.beat_npc_amount.each_with_index do |amount, index|
          return if infos[index] < amount
        end
      end
      #> Vérification des oeufs obtenus
      if infos = quest[:egg_counter] and quest_data.get_egg_amount
        return if infos < quest_data.get_egg_amount
      end
      #> Vérification des oeufs éclos
      if infos = quest[:egg_hatched] and quest_data.hatch_egg_amount
        return if infos < quest_data.hatch_egg_amount
      end
      @signal[:finish] << quest_id
    end
    # Is a quest finished ?
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean]
    def finished?(quest_id)
      return @finished_quests.fetch(quest_id, nil) != nil
    end
    # Is a quest failed ?
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean]
    def failed?(quest_id)
      return @failed_quests.fetch(quest_id, nil) != nil
    end
    # Get the earnings of a quest
    # @param quest_id [Integer] ID of the quest in the database
    # @return [Boolean] if the earning were givent to the player
    def get_earnings(quest_id)
      return false unless @finished_quests.fetch(quest_id, nil)
      quest_data = GameData::Quest.quest(quest_id)
      return false unless quest_data
      quest_data.earnings.each do |earning|
        if(earning[:money])
          $pokemon_party.add_money(earning[:money])
        elsif(earning[:item])
          $bag.add_item(earning[:item], earning[:item_amount])
        end
      end
      return @finished_quests.fetch(quest_id, nil)[:earnings] = true
    end
    # Does the earning of a quest has been taken
    # @param quest_id [Integer] ID of the quest in the database
    def earnings_got?(quest_id)
      return false unless @finished_quests.fetch(quest_id, nil)
      return @finished_quests.fetch(quest_id, nil)[:earnings]
    end
  end
end
