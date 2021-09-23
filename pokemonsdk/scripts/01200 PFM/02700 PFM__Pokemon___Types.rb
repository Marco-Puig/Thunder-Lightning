#encoding: utf-8

module PFM
  class Pokemon
    # Return the current first type of the Pokemon
    # @return [Integer]
    def type1
      return @type1 if @type1
      return $game_data_pokemon[@id][@form].type1
    end
    # Return the current second type of the Pokemon
    # @return [Integer]
    def type2
      return @type2 if @type2
      return $game_data_pokemon[@id][@form].type2
    end
    # Return the current third type of the Pokemon
    # @return [Integer]
    def type3
      return @type3 if @type3
      return 0
    end
    # Is the Pokemon type normal ?
    # @return [Boolean]
    def type_normal?
      return (self.type1==1 or self.type2==1 or self.type3==1)
    end
    # Is the Pokemon type fire ?
    # @return [Boolean]
    def type_fire?
      return (self.type1==2 or self.type2==2 or self.type3==2)
    end
    alias type_feu? type_fire?
    # Is the Pokemon type water ?
    # @return [Boolean]
    def type_water?
      return (self.type1==3 or self.type2==3 or self.type3==3)
    end
    alias type_eau? type_water?
    # Is the Pokemon type electric ?
    # @return [Boolean]
    def type_electric?
      return (self.type1==4 or self.type2==4 or self.type3==4)
    end
    alias type_electrique? type_electric?
    # Is the Pokemon type grass ?
    # @return [Boolean]
    def type_grass?
      return (self.type1==5 or self.type2==5 or self.type3==5)
    end
    alias type_plante? type_grass?
    # Is the Pokemon type ice ?
    # @return [Boolean]
    def type_ice?
      return (self.type1==6 or self.type2==6 or self.type3==6)
    end
    alias type_glace? type_ice?
    # Is the Pokemon type fighting ?
    # @return [Boolean]
    def type_fighting?
      return (self.type1==7 or self.type2==7 or self.type3==7)
    end
    alias type_combat? type_fighting?
    # Is the Pokemon type poison ?
    # @return [Boolean]
    def type_poison?
      return (self.type1==8 or self.type2==8 or self.type3==8)
    end
    # Is the Pokemon type ground ?
    # @return [Boolean]
    def type_ground?
      return (self.type1==9 or self.type2==9 or self.type3==9)
    end
    alias type_sol? type_ground?
    # Is the Pokemon type fly ?
    # @return [Boolean]
    def type_fly?
      return (self.type1==10 or self.type2==10 or self.type3==10)
    end
    alias type_vol? type_fly?
    # Is the Pokemon type psy ?
    # @return [Boolean]
    def type_psychic?
      return (self.type1==11 or self.type2==11 or self.type3==11)
    end
    alias type_psy? type_psychic?
    # Is the Pokemon type insect/bug ?
    # @return [Boolean]
    def type_insect?
      return (self.type1==12 or self.type2==12 or self.type3==12)
    end
    # Is the Pokemon type rock ?
    # @return [Boolean]
    def type_rock?
      return (self.type1==13 or self.type2==13 or self.type3==13)
    end
    alias type_roche? type_rock?
    # Is the Pokemon type ghost ?
    # @return [Boolean]
    def type_ghost?
      return (self.type1==14 or self.type2==14 or self.type3==14)
    end
    alias type_spectre? type_ghost?
    # Is the Pokemon type dragon ?
    # @return [Boolean]
    def type_dragon?
      return (self.type1==15 or self.type2==15 or self.type3==15)
    end
    # Is the Pokemon type steel ?
    # @return [Boolean]
    def type_steel?
      return (self.type1==16 or self.type2==16 or self.type3==16)
    end
    alias type_acier? type_steel?
    # Is the Pokemon type dark ?
    # @return [Boolean]
    def type_dark?
      return (self.type1==17 or self.type2==17 or self.type3==17)
    end
    alias type_tenebre? type_dark?
    # Is the Pokemon type fairy ?
    # @return [Boolean]
    def type_fairy?
      return (self.type1==18 or self.type2==18 or self.type3==18)
    end
    alias type_fee? type_fairy?
    # Check the Pokemon type by the type ID
    # @param t_id [Integer] ID of the type in the database
    # @return [Boolean]
    def type?(t_id)
      return (self.type1==t_id or self.type2==t_id or self.type3==t_id)
    end
  end
end
