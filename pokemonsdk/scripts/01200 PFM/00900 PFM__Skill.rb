#encoding: utf-8

module PFM
  # The InGame skill/move information of a Pokemon
  # @author Nuri Yuri
  class Skill
    # The maximum number of PP the skill has
    # @return [Integer]
    attr_accessor :ppmax
    # The current number of PP the skill has
    # @return [Integer]
    attr_accessor :pp
    # If the move has been used
    # @return [Boolean]
    attr_accessor :used
    # The alternative Power information of the skill (dynamic power)
    # @return [Integer, nil]
    attr_accessor :power2
    # The alternatif type information of the skill (dynamic type)
    # @return [Integer, nil] ID of the type
    attr_accessor :type2
    # The alternative accuracy information of the skill (dynamic accuracy)
    # @return [Integer, nil]
    attr_accessor :accuracy2
    # ID of the skill in the Database
    # @return [Integer]
    attr_reader :id
    # Create a new Skill information
    # @param id [Integer] ID of the skill/move in the database
    def initialize(id)
      data=$game_data_skill[id]
      @id=id
      unless data
        @ppmax = 0
        @pp = 0
        return
      end
      @ppmax=data.pp_max
      @pp=@ppmax
      @used=false
      #>Données de switch de l'attaque
      @id_bis=id
      @pp_max_bis=nil
      @pp_bis=nil
      #>Données de modification de l'attaque
      @power2=nil
      @type2=nil
      @accuracy2=nil
    end
    # Reset the skill/move information
    def reset
      @id=@id_bis
      @pp=@pp_bis if @pp_bis
      @ppmax=@pp_max_bis if @pp_max_bis
      @used=false
      @pp_bis=nil
      @pp_max_bis=nil
      @power2=nil
      @type2=nil
      @accuracy2=nil
    end
    # Change the skill information (copy, sketch, Z-move etc...)
    # @param id [Integer] ID of the skill in the database
    # @param pp [Integer, nil] the number of pp of the skill, nil = no change about PPs
    # @param sketch [Boolean] if the skill informations are definitely changed
    def switch(id, pp = 10, sketch = false)
      return initialize(id) if sketch
      data = $game_data_skill[id]
      @id_bis = @id
      @pp_bis = @pp if pp
      @pp_max_bis = @ppmax
      @id=id
      unless data
        @pp = @ppmax = 0
        return
      end
      if pp
        pp = data.pp_max if(data.pp_max < pp)
        @pp = pp
        @ppmax = pp
      end
      @used = false
    end
    # Return the db_symbol of the skill
    # @return [Symbol]
    def db_symbol
      GameData::Skill.db_symbol(@id)
    end
    # Return the name of the skill
    # @return [String]
    def name
      return GameData::Text.get(6,@id)#$game_data_skill[@id].name
    end
    # Return the symbol of the method to call in BattleEngine
    # @return [Symbol]
    def symbol
      return $game_data_skill[@id].be_method
    end
    # Return the actual power of the skill
    # @return [Integer]
    def power
      return (@power2 ? @power2 : $game_data_skill[@id].power)
    end
    # Return the text of the power of the skill
    # @return [String]
    def power_text
      power = $game_data_skill[@id].power
      if power == 0
        return text_get(11,12)
      end
      return power.to_s
    end
    # Return the text of the PP of the skill
    # @return [String]
    def pp_text
      "#@pp / #@ppmax"
    end
    # Return the base power (Data power) of the skill
    # @return [Integer]
    def base_power
      return $game_data_skill[@id].power
    end
    # Return the actual type ID of the skill
    # @return [Integer]
    def type
      return (@type2 ? @type2 : $game_data_skill[@id].type)
    end
    # Return the actual accuracy of the skill
    # @return [Integer]
    def accuracy
      return (@accuracy2 ? @accuracy2 : $game_data_skill[@id].accuracy)
    end
    # Return the accuracy text of the skill
    # @return [String]
    def accuracy_text
      acc = $game_data_skill[@id].accuracy
      if acc == 0
        return text_get(11,12)
      end
      return acc.to_s
    end
    # Return the chance of effect of the skill
    # @return [Integer]
    def effect_chance
      return $game_data_skill[@id].effect_chance
    end
    # Return the status effect the skill can inflict
    # @return [Integer, nil]
    def status_effect
      return $game_data_skill[@id].status
    end
    # Return the stat tage modifier the skill can apply
    # @return [Array<Integer>]
    def battle_stage_mod
      return $game_data_skill[@id].battle_stage_mod
    end
    # Return the target symbol the skill can aim
    # @return [Symbol]
    def target
      return $game_data_skill[@id].target
    end
    # Is the skill affected by gravity
    # @return [Boolean]
    def gravity_affected?
      return $game_data_skill[@id].gravity
    end
    # Return the skill description
    # @return [String]
    def description
      return GameData::Text.get(7,@id)#$game_data_skill[@id].descr
    end
    # Is the skill direct ?
    # @return [Boolean]
    def direct?
      return $game_data_skill[@id].direct
    end
    # Is the skill affected by Mirror Move
    # @return [Boolean]
    def mirror_move?
      return $game_data_skill[@id].mirror_move
    end
    # Return the priority of the skill
    # @return [Integer]
    def priority
      return $game_data_skill[@id].priority
    end
    # Return the ID of the common event to call on Map use
    # @return [Integer]
    def map_use
      return $game_data_skill[@id].map_use
    end
    # Is the skill blocable by Protect and skill like that ?
    # @return [Boolean]
    def blocable?
      return $game_data_skill[@id].blocable
    end
    # Is the skill physical ?
    # @return [Boolean]
    def physical?
      return $game_data_skill[@id].atk_class==1
    end
    # Is the skill special ?
    # @return [Boolean]
    def special?
      return $game_data_skill[@id].atk_class==2
    end
    # Is the skill status ?
    # @return [Boolean]
    def status?
      return $game_data_skill[@id].atk_class==3
    end
    # Return the class of the skill
    # @return [Integer] 1, 2, 3
    def atk_class
      return $game_data_skill[@id].atk_class
    end
    # Is the skill type normal ?
    # @return [Boolean]
    def type_normal?
      return self.type==1
    end
    # Is the skill type fire ?
    # @return [Boolean]
    def type_fire?
      return self.type==2
    end
    alias type_feu? type_fire?
    # Is the skill type water ?
    # @return [Boolean]
    def type_water?
      return self.type==3
    end
    alias type_eau? type_water?
    # Is the skill type electric ?
    # @return [Boolean]
    def type_electric?
      return self.type==4
    end
    alias type_electrique? type_electric?
    # Is the skill type grass ?
    # @return [Boolean]
    def type_grass?
      return self.type==5
    end
    alias type_plante? type_grass?
    # Is the skill type ice ?
    # @return [Boolean]
    def type_ice?
      return self.type==6
    end
    alias type_glace? type_ice?
    # Is the skill type fighting ?
    # @return [Boolean]
    def type_fighting?
      return self.type==7
    end
    alias type_combat? type_fighting?
    # Is the skill type poison ?
    # @return [Boolean]
    def type_poison?
      return self.type==8
    end
    # Is the skill type ground ?
    # @return [Boolean]
    def type_ground?
      return self.type==9
    end
    alias type_sol? type_ground?
    # Is the skill type fly ?
    # @return [Boolean]
    def type_fly?
      return self.type==10
    end
    alias type_vol? type_fly?
    # Is the skill type psy ?
    # @return [Boolean]
    def type_psychic?
      return self.type==11
    end
    alias type_psy? type_psychic?
    # Is the skill type insect/bug ?
    # @return [Boolean]
    def type_insect?
      return self.type==12
    end
    # Is the skill type rock ?
    # @return [Boolean]
    def type_rock?
      return self.type==13
    end
    alias type_roche? type_rock?
    # Is the skill type ghost ?
    # @return [Boolean]
    def type_ghost?
      return self.type==14
    end
    alias type_spectre? type_ghost?
    # Is the skill type dragon ?
    # @return [Boolean]
    def type_dragon?
      return self.type==15
    end
    # Is the skill type steel ?
    # @return [Boolean]
    def type_steel?
      return self.type==16
    end
    alias type_acier? type_steel?
    # Is the skill type dark ?
    # @return [Boolean]
    def type_dark?
      return self.type==17
    end
    alias type_tenebre? type_dark?
    # Is the skill type fairy ?
    # @return [Boolean]
    def type_fairy?
      return self.type==18
    end
    alias type_fee? type_fairy?
    # Does the skill has recoil ?
    # @return [Boolean]
    def recoil?
      return $game_data_skill[@id].be_method == :s_recoil
    end
    # Is the skill a punching move ?
    # @return [Boolean]
    def punching?
      return $game_data_skill[@id].punching?
    end
    # Return the critical rate of the skill
    # @return [Integer]
    def critical_rate
      return $game_data_skill[@id].critical_rate
    end
    # Is the skill a sound attack ?
    # @return [Boolean]
    def sound_attack?
      return $game_data_skill[@id].sound_attack
    end
    # Does the skill unfreeze
    # @return [Boolean]
    def unfreeze?
      return $game_data_skill[@id].unfreeze
    end
    # Does the skill trigger the king rock
    # @return [Boolean]
    def king_rock_utility 
      return $game_data_skill[@id].king_rock_utility 
    end
    # Is the skill snatchable ?
    # @return [Boolean]
    def snatchable
      return $game_data_skill[@id].snatchable
    end
    # Is the skill affected by magic coat ?
    # @return [Boolean]
    def magic_coat_affected
      return $game_data_skill[@id].magic_coat_affected
    end
    # Change the PP
    # @param v [Integer] the new pp value
    def pp=(v)
      @pp = v
      @pp = @ppmax if(@pp > @ppmax)
      @pp = 0 if @pp < 0
    end
    # Convert skill to string
    # @return [String]
    def to_s
      return "<S:#{self.name}_#{self.power}_#{self.accuracy}>"
    end
    # List of symbol describe a one target aim
    OneTarget = [:any_other_pokemon, :random_foe, :adjacent_pokemon, :adjacent_foe, :user, :user_or_adjacent_ally, :adjacent_ally]
    # Does the skill aim only one Pokemon
    # @return [Boolean]
    def is_one_target?
      return OneTarget.include?(self.target)
    end
    # List of symbol that doesn't show any choice of target
    TargetNoAsk = [:adjacent_all_foe, :all_foe, :adjacent_all_pokemon, :all_pokemon, :user, :all_ally, :random_foe]
    # Does the skill doesn't show a target choice
    # @return [Boolean]
    def is_no_choice_skill?
      return TargetNoAsk.include?(self.target)
    end
  end
end
