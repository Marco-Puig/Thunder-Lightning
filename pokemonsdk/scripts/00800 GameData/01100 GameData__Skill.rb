#encoding: utf-8

module GameData
  # Data structure of Pokemon moves
  # @author Nuri Yuri
  class Skill < Base
    # ID of the common event called when used on map
    # @return [Integer]
    attr_accessor :map_use
    # Symbol of the method to call in the Battle Engine to perform the move
    # @return [Symbol, nil]
    attr_accessor :be_method
    # Type of the move
    # @return [Integer]
    attr_accessor :type
    # Power of the move
    # @return [Integer]
    attr_accessor :power
    # Accuracy of the move
    # @return [Integer]
    attr_accessor :accuracy
    # Maximum amount of PP the move has when unused
    # @return [Integer]
    attr_accessor :pp_max
    # The Pokemon targeted by the move
    # @return [Symbol]
    attr_accessor :target
    # Kind of move 1 = Physical, 2 = Special, 3 = Status
    # @return [Integer]
    attr_accessor :atk_class
    # If the move is a direct move or not
    # @return [Boolean]
    attr_accessor :direct
    # Critical rate indicator : 0 => 0, 1 => 6.25%, 2 => 12.5%, 3 => 25%, 4 => 33%, 5 => 50%, 6 => 100%
    # @return [Integer]
    attr_accessor :critical_rate
    # Priority of the move
    # @return [Integer]
    attr_accessor :priority
    # If the move is affected by Detect or Protect
    # @return [Boolean]
    attr_accessor :blocable
    # If the move is affected by Snatch
    # @return [Boolean]
    attr_accessor :snatchable
    # If the move can be used by Mirror Move
    # @return [Boolean]
    attr_accessor :mirror_move
    # If the move is affected by Gravity
    # @return [Boolean]
    attr_accessor :gravity
    # If the move is affected by Magic Coat
    # @return [Boolean]
    attr_accessor :magic_coat_affected
    # If the move unfreeze the opponent Pokemon
    # @return [Boolean]
    attr_accessor :unfreeze
    # If the move is a sound attack
    # @return [Boolean]
    attr_accessor :sound_attack
    # If the move triggers King's Rock
    # @return [Boolean]
    attr_accessor :king_rock_utility
    # Chance (in percent) the effect (stat/status) triggers
    # @return [Integer]
    attr_accessor :effect_chance
    # Stat change effect
    # @return [Array(Integer, Integer, Integer, Integer, Integer, Integer, Integer)]
    attr_accessor :battle_stage_mod
    # The status effect
    # @return [Integer, nil]
    attr_accessor :status
    # List of moves that works when the Pokemon is asleep
    SleepingAttack = %i[snore sleep_talk]
    # Out of reach moves
    #   OutOfReach[sb_symbol] => oor_type
    OutOfReach = { dig: 1, fly: 2, dive: 3, bounce: 4, phantom_force: 5, shadow_force: 5, sky_drop: 6 }
    # List of move that can hit a Pokemon when he's out of reach
    #   OutOfReach_hit[oor_type] = [move db_symbol list]
    OutOfReach_hit = [
      [], # Nothing
      %i[earthquake toxic], # Dig
      %i[gust twister sky_uppercut toxic smack_down], # Fly
      [:surf], # Dive
      %i[gust sky_uppercut twister smack_down], # Bounce
      [], # Phantom force / Shadow Force
      [:smack_down] # Sky drop
    ]
    # List of specific announcement for 2 turn moves
    #   Announce_2turns[db_symbol] = text_id
    Announce_2turns = { dig: 538, fly: 529, dive: 535, bounce: 544,
                        phantom_force: 541, shadow_force: 541, solar_beam: 553,
                        skull_bash: 556, razor_wind: 547, freeze_shock: 866,
                        ice_burn: 869, geomancy: 1213, sky_attack: 550,
                        focus_punch: 1213 }
    # List of Punch moves
    Punching_Moves = %i[dynamic_punch mach_punch hammer_arm focus_punch bullet_punch
                        power-up_punch comet_punch needle_arm fire_punch meteor_mash
                        shadow_punch thunder_punch ice_punch sky_uppercut mega_punch
                        dizzy_punch drain_punch karate_chop]
    # Is the move a punch move ?
    # @return [Boolean]
    def punching?
      return Punching_Moves.include?(@db_symbol)
    end
    # Safely return the name of a move
    # @param id [Integer] id of the move in the database
    # @return [String]
    def self.name(id)
      if(id > 0 and id < $game_data_skill.size)
        return Text.get(6,id)
      end
      return "???"
    end
    # Safely tell if a move works when the Pokemon is asleep
    # @param id [Symbol, Integer] db_symbol or id of the move in the database
    # @return [Boolean]
    def self.is_sleeping_attack?(id)
      id = self.db_symbol(id) if id.is_a?(Integer)
      SleepingAttack.include?(id)
    end
    # Safely return the out of reach type of a move
    # @param id [Symbol, Integer] db_symbol or id of the move in the database
    # @return [Integer, nil] nil if not an oor move
    def self.get_out_of_reach_type(id)
      id = self.db_symbol(id) if id.is_a?(Integer)
      return OutOfReach[id]
    end
    # Tell if the move can hit de out of reach Pokemon
    # @param oor [Integer] out of reach type
    # @param id [Symbol, Integer] db_symbol or id of the move in the database
    # @return [Boolean]
    def self.can_hit_out_of_reach?(oor, id)
      return false if oor >= OutOfReach_hit.size or oor < 0
      id = self.db_symbol(id) if id.is_a?(Integer)
      return OutOfReach_hit[oor].include?(id)
    end
    # Return the id of the 2 turn announce text
    # @param id [Symbol, Integer] db_symbol or id of the move in the database
    # @return [Integer, nil]
    def self.get_2turns_announce(id)
      id = self.db_symbol(id) if id.is_a?(Integer)
      return Announce_2turns[id]
    end
    # Create a new GameData::Skill object
    def initialize(map_use, be_method, type, power, accuracy, pp_max, target, 
      atk_class, direct, critical_rate, priority, blocable, snatchable, gravity,
      magic_coat_affected, mirror_move, unfreeze, sound_attack, 
      king_rock_utility, effect_chance, battle_stage_mod, status)
      @map_use = map_use
      @be_method = be_method
      @type = type
      @power = power
      @accuracy = accuracy
      @pp_max = pp_max
      @target = target
      @atk_class = atk_class
      @direct = direct
      @critical_rate = critical_rate
      @priority = priority
      @blocable = blocable
      @snatchable = snatchable
      @gravity = gravity
      @magic_coat_affected = magic_coat_affected
      @mirror_move = mirror_move
      @unfreeze = unfreeze
      @sound_attack = sound_attack
      @king_rock_utility = king_rock_utility
      @effect_chance = effect_chance
      @battle_stage_mod = battle_stage_mod
      @status = status
    end
    # Safely return the map_use info of a move
    # @param id [Integer] id of the move in the database
    # @return [Integer]
    def self.map_use(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].map_use
      end
      return $game_data_skill[0].map_use
    end
    # Safely return the be_method of a move
    # @param id [Integer] id of the move in the database
    # @return [Symbol]
    def self.be_method(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].be_method
      end
      return $game_data_skill[0].be_method
    end
    # Safely return the type of a move
    # @param id [Integer] id of the move in the database
    # @return [Integer]
    def self.type(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].type
      end
      return $game_data_skill[0].type
    end
    # Safely return the power of a move
    # @param id [Integer] id of the move in the database
    # @return [Integer]
    def self.power(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].power
      end
      return $game_data_skill[0].power
    end
    # Safely return the accuracy of a move
    # @param id [Integer] id of the move in the database
    # @return [Integer]
    def self.accuracy(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].accuracy
      end
      return $game_data_skill[0].accuracy
    end
    # Safely return the pp_max of a move
    # @param id [Integer] id of the move in the database
    # @return [Integer]
    def self.pp_max(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].pp_max
      end
      return $game_data_skill[0].pp_max
    end
    # Safely return the target of a move
    # @param id [Integer] id of the move in the database
    # @return [Symbol]
    def self.target(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].target
      end
      return $game_data_skill[0].target
    end
    # Safely return the atk_class of a move
    # @param id [Integer] id of the move in the database
    # @return [Integer]
    def self.atk_class(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].atk_class
      end
      return $game_data_skill[0].atk_class
    end
    # Safely return the direct attribute of a move
    # @param id [Integer] id of the move in the database
    # @return [Boolean]
    def self.direct(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].direct
      end
      return $game_data_skill[0].direct
    end
    # Safely return the critical_rate attribute of a move
    # @param id [Integer] id of the move in the database
    # @return [Integer]
    def self.critical_rate(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].critical_rate
      end
      return $game_data_skill[0].critical_rate
    end
    # Safely return the priority attribute of a move
    # @param id [Integer] id of the move in the database
    # @return [Integer]
    def self.priority(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].priority
      end
      return $game_data_skill[0].priority
    end
    # Safely return the blocable attribute of a move
    # @param id [Integer] id of the move in the database
    # @return [Boolean]
    def self.blocable(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].blocable
      end
      return $game_data_skill[0].blocable
    end
    # Safely return the snatchable attribute of a move
    # @param id [Integer] id of the move in the database
    # @return [Boolean]
    def self.snatchable(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].snatchable
      end
      return $game_data_skill[0].snatchable
    end
    # Safely return the gravity attribute of a move
    # @param id [Integer] id of the move in the database
    # @return [Boolean]
    def self.gravity(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].gravity
      end
      return $game_data_skill[0].gravity
    end
    # Safely return the magic_coat_affected attribute of a move
    # @param id [Integer] id of the move in the database
    # @return [Boolean]
    def self.magic_coat_affected(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].magic_coat_affected
      end
      return $game_data_skill[0].magic_coat_affected
    end
    # Safely return the mirror_move attribute of a move
    # @param id [Integer] id of the move in the database
    # @return [Boolean]
    def self.mirror_move(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].mirror_move
      end
      return $game_data_skill[0].mirror_move
    end
    # Safely return the unfreeze attribute of a move
    # @param id [Integer] id of the move in the database
    # @return [Boolean]
    def self.unfreeze(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].unfreeze
      end
      return $game_data_skill[0].unfreeze
    end
    # Safely return the sound_attack attribute of a move
    # @param id [Integer] id of the move in the database
    # @return [Boolean]
    def self.sound_attack(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].sound_attack
      end
      return $game_data_skill[0].sound_attack
    end
    # Safely return the king_rock_utility attribute of a move
    # @param id [Integer] id of the move in the database
    # @return [Boolean]
    def self.king_rock_utility(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].king_rock_utility
      end
      return $game_data_skill[0].king_rock_utility
    end
    # Safely return the effect_chance attribute of a move
    # @param id [Integer] id of the move in the database
    # @return [Integer]
    def self.effect_chance(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].effect_chance
      end
      return $game_data_skill[0].effect_chance
    end
    # Safely return the battle_stage_mod attribute of a move
    # @param id [Integer] id of the move in the database
    # @return [Array]
    def self.battle_stage_mod(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].battle_stage_mod
      end
      return $game_data_skill[0].battle_stage_mod
    end
    # Safely return the status attribute of a move
    # @param id [Integer] id of the move in the database
    # @return [Integer, nil]
    def self.status(id)
      if id.between?(1, LastID)
        return $game_data_skill[id].status
      end
      return $game_data_skill[0].status
    end
    # Tell if a move is a puch move
    # @param id [Symbol, Integer] id of the move in the database or db_symbol
    # @return [Boolean]
    def self.punching?(id)
      id = self.db_symbol(id) if id.is_a?(Integer)
      return Punching_Moves.include?(id)
    end
    # Safely return the db_symbol of an item
    # @param id [Integer] id of the item in the database
    # @return [Symbol]
    def self.db_symbol(id)
      if(id.between?(1, LastID))
        return ($game_data_skill[id].db_symbol || :__undef__)
      end
      return :__undef__
    end
    # Find a skill using symbol
    # @param symbol [Symbol]
    # @return [GameData::Skill]
    def self.find_using_symbol(symbol)
      skill = $game_data_skill.find { |data| data.db_symbol == symbol }
      return $game_data_skill[0] unless skill
      skill
    end
    # Get id using symbol
    # @param symbol [Symbol]
    # @return [Integer]
    def self.get_id(symbol)
      skill = $game_data_skill.index { |data| data.db_symbol == symbol }
      skill.to_i
    end
    # Convert a collection to symbolized collection
    # @param collection [Enumerable]
    # @param keys [Boolean] if hash keys are converted
    # @param values [Boolean] if hash values are converted
    # @return [Enumerable] the collection
    def self.convert_to_symbols(collection, keys: false, values: false)
      if collection.is_a?(Hash)
        new_collection = {}
        collection.each do |key, value|
          key = self.db_symbol(key) if keys and key.is_a?(Integer)
          if value.is_a?(Enumerable)
            value = self.convert_to_symbols(value, keys: keys, values: values)
          else
            value = self.db_symbol(value) if values and value.is_a?(Integer)
          end
          new_collection[key] = value
        end
        collection = new_collection
      else
        collection.each_with_index do |value, index|
          if value.is_a?(Enumerable)
            collection[index] = self.convert_to_symbols(value, keys: keys, values: values)
          else
            collection[index] = self.db_symbol(value) if value.is_a?(Integer)
          end
        end
      end
      collection
    end
  end
end
