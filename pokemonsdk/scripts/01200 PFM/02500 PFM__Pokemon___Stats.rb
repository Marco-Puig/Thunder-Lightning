#encoding: utf-8

module PFM
  class Pokemon
    # Return the base HP
    # @return [Integer]
    def base_hp
      return $game_data_pokemon[@id][@form].base_hp
    end
    # Return the base ATK
    # @return [Integer]
    def base_atk
      return $game_data_pokemon[@id][@form].base_atk
    end
    # Return the base DFE
    # @return [Integer]
    def base_dfe
      return $game_data_pokemon[@id][@form].base_dfe
    end
    # Return the base SPD
    # @return [Integer]
    def base_spd
      return $game_data_pokemon[@id][@form].base_spd
    end
    # Return the base ATS
    # @return [Integer]
    def base_ats
      return $game_data_pokemon[@id][@form].base_ats
    end
    # Return the base DFS
    # @return [Integer]
    def base_dfs
      return $game_data_pokemon[@id][@form].base_dfs
    end
    # Return the max HP of the Pokemon
    # @return [Integer]
    def max_hp
      return 1 if @id==292 #Si le Pokémon est Munja
      return ((@iv_hp + 2*self.base_hp + @ev_hp/4)*@level)/100+10+@level
    end
    # Return the current atk
    # @return [Integer]
    def atk
      n = battle_effect.atk
      return (n*atk_modifier).to_i if n
      n=((@iv_atk + 2*self.base_atk + @ev_atk/4)*@level)/100+5
      return ((n*atk_modifier*self.nature[1])/100).to_i
    end
    # Return the current dfe
    # @return [Integer]
    def dfe
      n = battle_effect.dfe
      return (n*dfe_modifier).to_i if n
      n=((@iv_dfe + 2*self.base_dfe + @ev_dfe/4)*@level)/100+5
      return ((n*dfe_modifier*self.nature[2])/100).to_i
    end
    # Return the current spd
    # @return [Integer]
    def spd
      n = battle_effect.spd
      return (n*spd_modifier).to_i if n
      n=(((@iv_spd + 2*self.base_spd + @ev_spd/4)*@level)/100+5)*spd_modifier
      return ((n*self.nature[3])/100).to_i
    end
    # Return the current ats
    # @return [Integer]
    def ats
      n = battle_effect.ats
      return (n*ats_modifier).to_i if n
      n=((@iv_ats + 2*self.base_ats + @ev_ats/4)*@level)/100+5
      return ((n*ats_modifier*self.nature[4])/100).to_i
    end
    # Return the current dfs
    # @return [Integer]
    def dfs
      n = battle_effect.dfs
      return (n*dfs_modifier).to_i if n
      n=((@iv_dfs + 2*self.base_dfs + @ev_dfs/4)*@level)/100+5
      return ((n*dfs_modifier*self.nature[5])/100).to_i
    end
    # Reset the battle stat stage and stuff related to battle
    def reset_stat_stage
      @battle_stage=Array.new(7,0)
      @critical_modifier = 0
      @ability_used=false
      @ability_current=@ability
      @confuse=false
      @state_count=0
      #>Reset des skills
      @skills_set.each_index do |i|
        @skills_set[i].reset if @skills_set[i]
        @skills_set[i]=nil if(@skills_set[i].id==0)
      end
      @skills_set.compact!
      if(@sub_id)
        @id=@sub_id
        @shiny=@sub_shiny
        @form=@sub_form
        @sub_id=nil
        @sub_shiny=nil
        @sub_form=nil
        self.hp = (self.max_hp*self.hp_rate).to_i
      end
      @battle_item = @item_holding
      @battle_item_data=[]
      @type1 = @type2 = @type3 = nil #Reset du type 3
      @last_skill = 0
      @skill_use_times = 0
      #>Formes recalibrés en début de combat
      if(@id == 421) #>Ceriflor
        @form = form_generation(-1)
      end
      @status_count = 0 if toxic?
    end
    # Return the atk stage
    # @return [Integer]
    def atk_stage
      return @battle_stage[0]
    end
    # Return the dfe stage
    # @return [Integer]
    def dfe_stage
      return @battle_stage[1]
    end
    # Return the spd stage
    # @return [Integer]
    def spd_stage
      return @battle_stage[2]
    end
    # Return the ats stage
    # @return [Integer]
    def ats_stage
      return @battle_stage[3]
    end
    # Return the dfs stage
    # @return [Integer]
    def dfs_stage
      return @battle_stage[4]
    end
    # Return the evasion stage
    # @return [Integer]
    def eva_stage
      return @battle_stage[5]
    end
    # Return the accuracy stage
    # @return [Integer]
    def acc_stage
      return @battle_stage[6]
    end
    # Change a stat stage
    # @param stat_id [Integer] id of the stat : 0 = atk, 1 = dfe, 2 = spd, 3 = ats, 4 = dfs, 5 = eva, 6 = acc
    # @param amount [Integer] the amount to change on the stat stage
    # @return [Integer] the difference between the current and the last stage value
    def change_stat(stat_id, amount)
      last_value = @battle_stage[stat_id]
      @battle_stage[stat_id] += amount
      if @battle_stage[stat_id] > 6
        @battle_stage[stat_id]=6
      elsif @battle_stage[stat_id] < -6
        @battle_stage[stat_id]=-6
      end
      return @battle_stage[stat_id]-last_value
    end
    # Change the atk stage
    # @param amount [Integer] the amount to change on the stat stage
    # @return [Integer] the difference between the current and the last stage value
    def change_atk(amount)
      return change_stat(0, amount)
    end
    # Change the dfe stage
    # @param amount [Integer] the amount to change on the stat stage
    # @return [Integer] the difference between the current and the last stage value
    def change_dfe(amount)
      return change_stat(1, amount)
    end
    # Change the spd stage
    # @param amount [Integer] the amount to change on the stat stage
    # @return [Integer] the difference between the current and the last stage value
    def change_spd(amount)
      return change_stat(2, amount)
    end
    # Change the ats stage
    # @param amount [Integer] the amount to change on the stat stage
    # @return [Integer] the difference between the current and the last stage value
    def change_ats(amount)
      return change_stat(3, amount)
    end
    # Change the dfs stage
    # @param amount [Integer] the amount to change on the stat stage
    # @return [Integer] the difference between the current and the last stage value
    def change_dfs(amount)
      return change_stat(4, amount)
    end
    # Change the eva stage
    # @param amount [Integer] the amount to change on the stat stage
    # @return [Integer] the difference between the current and the last stage value
    def change_eva(amount)
      return change_stat(5, amount)
    end
    # Change the acc stage
    # @param amount [Integer] the amount to change on the stat stage
    # @return [Integer] the difference between the current and the last stage value
    def change_acc(amount)
      return change_stat(6, amount)
    end
    # Return the stage modifier (multiplier)
    # @param stage [Integer] the value of the stage
    # @return [Float] the multiplier
    def modifier_stage(stage)
      if stage >= 0
        return (2+stage)/2.0
      else
        return 2.0/(2-stage)
      end
    end
    # Return the atk modifier
    # @return [Float] the multiplier
    def atk_modifier
      n=modifier_stage(atk_stage)
      return n
    end
    # Return the dfe modifier
    # @return [Float] the multiplier
    def dfe_modifier
      n=modifier_stage(dfe_stage)
      return n
    end
    # Return the spd modifier
    # @return [Float] the multiplier
    def spd_modifier
      n=modifier_stage(spd_stage)
      return n
    end
    # Return the ats modifier
    # @return [Float] the multiplier
    def ats_modifier
      n=modifier_stage(ats_stage)
      return n
    end
    # Return the dfs modifier
    # @return [Float] the multiplier
    def dfs_modifier
      n=modifier_stage(dfs_stage)
      return n
    end
    # Change the IV and update the statistics
    # @param list [Array<Integer>] list of new IV [hp, atk, dfe, spd, ats, dfs]
    def dv_modifier(list)
      @iv_hp = get_dv_value(list[0], @iv_hp)
      @iv_atk = get_dv_value(list[1], @iv_atk)
      @iv_dfe = get_dv_value(list[2], @iv_dfe)
      @iv_spd = get_dv_value(list[3], @iv_spd)
      @iv_ats = get_dv_value(list[4], @iv_ats)
      @iv_dfs = get_dv_value(list[5], @iv_dfs)
      @hp = max_hp
    end
    # Get the adjusted IV
    # @param value [Integer] the new value
    # @param old [Integer] the old value
    # @return [Integer] something between old and 31 (value in most case)
    def get_dv_value(value, old)
      if value < 0
        return old
      elsif value > 31
        return 31
      end
      return value
    end
    # Return the atk stat without battle modifier
    # @return [Integer]
    def atk_basis
      n=((@iv_atk + 2*self.base_atk + @ev_atk/4)*@level)/100+5
      n=(n*self.nature[1])/100
      return n.to_i
    end
    # Return the dfe stat without battle modifier
    # @return [Integer]
    def dfe_basis
      n=((@iv_dfe + 2*self.base_dfe + @ev_dfe/4)*@level)/100+5
      n=(n*self.nature[2])/100
      return n.to_i
    end
    # Return the spd stat without battle modifier
    # @return [Integer]
    def spd_basis
      n=((@iv_spd + 2*self.base_spd + @ev_spd/4)*@level)/100+5
      n=(n*self.nature[3])/100
      return n.to_i
    end
    # Return the ats stat without battle modifier
    # @return [Integer]
    def ats_basis
      n=((@iv_ats + 2*self.base_ats + @ev_ats/4)*@level)/100+5
      n=(n*self.nature[4])/100
      return n.to_i
    end
    # Return the dfs stat without battle modifier
    # @return [Integer]
    def dfs_basis
      n=((@iv_dfs + 2*self.base_dfs + @ev_dfs/4)*@level)/100+5
      n=(n*self.nature[5])/100
      return n.to_i
    end
    # Change the HP value of the Pokemon
    # @note If v <= 0, the pokemon status become 0
    # @param v [Integer] the new HP value
    def hp=(v)
      if(v<=0)
        @hp=0
        @hp_rate = 0
        @status=0
      elsif(v >= max_hp)
        @hp = max_hp
        @hp_rate = 1
      else
        @hp=v
        @hp_rate = v / max_hp.to_f
      end
    end

    # Return the EV HP text
    # @return [String]
    def ev_hp_text
      format(ev_text, ev_hp)
    end

    # Return the EV ATK text
    # @return [String]
    def ev_atk_text
      format(ev_text, ev_atk)
    end

    # Return the EV DFE text
    # @return [String]
    def ev_dfe_text
      format(ev_text, ev_dfe)
    end

    # Return the EV SPD text
    # @return [String]
    def ev_spd_text
      format(ev_text, ev_spd)
    end

    # Return the EV ATS text
    # @return [String]
    def ev_ats_text
      format(ev_text, ev_ats)
    end

    # Return the EV DFS text
    # @return [String]
    def ev_dfs_text
      format(ev_text, ev_dfs)
    end

    # Return the IV HP text
    # @return [String]
    def iv_hp_text
      format(iv_text, iv_hp)
    end

    # Return the IV ATK text
    # @return [String]
    def iv_atk_text
      format(iv_text, iv_atk)
    end

    # Return the IV DFE text
    # @return [String]
    def iv_dfe_text
      format(iv_text, iv_dfe)
    end

    # Return the IV SPD text
    # @return [String]
    def iv_spd_text
      format(iv_text, iv_spd)
    end

    # Return the IV ATS text
    # @return [String]
    def iv_ats_text
      format(iv_text, iv_ats)
    end

    # Return the IV DFS text
    # @return [String]
    def iv_dfs_text
      format(iv_text, iv_dfs)
    end

    private

    # Return the text "EV: %d"
    # @return [String]
    def ev_text
      'EV: %d'
    end

    # Return the text "IV: %d"
    # @return [String]
    def iv_text
      'IV: %d'
    end
  end
end
