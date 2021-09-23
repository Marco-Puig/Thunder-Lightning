#encoding: utf-8

module PFM
  # Daycare management system
  #
  # The global Daycare manager is stored in $daycare and $pokemon_party.daycare
  # @author Nuri Yuri
  #
  # Daycare data Hash format
  #   pokemon: Array # The list of Pokemon in the daycare (PFM::Pokemon or nil)
  #   level: Array # The list of level the Pokemon had when sent to the daycare
  #   layable: Integer # ID of the Pokemon that can be in the egg
  #   rate: Integer # Chance the egg can be layed
  #   egg: Boolean # If an egg has been layed
  class Daycare
    # List of Pokemon that cannot breed (event if the conditions are valid)
    Not_Breeding = [489, 490]
    # Create the daycare manager
    def initialize
      #>Tableau des pensions
      @daycares = Array.new
    end
    # Update every daycare
    def update
      check_egg = ($pokemon_party.steps & 0xFF) == 0
      daycare = nil
      pokemon = nil
      @daycares.each do |daycare|
        next unless daycare
        daycare[:pokemon].each do |pokemon|
          exp_pokemon(pokemon)
        end
        if(check_egg and daycare[:layable] and daycare[:layable] != 0)
          try_to_lay(daycare)
        end
      end
    end
    # Store a Pokemon to a daycare
    # @param id [Integer] the ID of the daycare
    # @param pokemon [PFM::Pokemon] the pokemon to store in the daycare
    # @return [Boolean] if the pokemon could be stored in the daycare
    def store(id, pokemon)
      @daycares[id] = {:pokemon => [], :level => [], :layable => 0, :rate => 0, :egg => nil} unless @daycares[id]
      return false if full?(id)
      daycare = @daycares[id]
      daycare[:level][daycare[:pokemon].size] = pokemon.level
      daycare[:pokemon] << pokemon
      layable_check(daycare, daycare[:pokemon]) if daycare[:pokemon].size == 2
      pc "==== Pension Infos ====\nRate : #{daycare[:rate]}%\nPokémon : #{GameData::Text.get(0,daycare[:layable])}\n"
      return true
    end
    # Price to pay in order to withdraw a Pokemon
    # @param id [Integer] the ID of the daycare
    # @param index [Integer] the index of the Pokemon in the daycare
    # @return [Integer] the price to pay
    def price(id, index)
      return 0 unless @daycares[id] and @daycares[id][:pokemon][index]
      return 100*(@daycares[id][:pokemon][index].level - @daycares[id][:level][index] + 1)
    end
    # Get a Pokemon information in the daycare
    # @param id [Integer] the ID of the daycare
    # @param index [Integer] the index of the Pokemon in the daycare
    # @param prop [Symbol] the method to call of PFM::Pokemon to get the information
    # @param args [Array] the list of arguments of the property
    # @return [Object] the result
    def get_pokemon(id, index, prop, *args)
      return nil unless @daycares[id] and @daycares[id][:pokemon][index]
      return @daycares[id][:pokemon][index].send(prop, *args)
    end
    # Withdraw a Pokemon from a daycare
    # @param id [Integer] the ID of the daycare
    # @param index [Integer] the index of the Pokemon in the daycare
    # @return [PFM::Pokemon, nil]
    def retreive_pokemon(id, index)
      return nil unless @daycares[id] and @daycares[id][:pokemon][index]
      daycare = @daycares[id]
      pokemon = daycare[:pokemon][index]
      daycare[:pokemon][index] = nil
      daycare[:level][index] = nil
      daycare[:pokemon].compact!
      daycare[:level].compact!
      daycare[:rate] = 0
      daycare[:layable] = 0
      return pokemon
    end
    alias withdraw_pokemon retreive_pokemon
    # Get the egg rate of a daycare
    # @param id [Integer] the ID of the daycare
    # @return [Integer]
    def retreive_egg_rate(id)
      return @daycares[id][:rate].to_i
    end
    # Retreive the egg layed
    # @param id [Integer] the ID of the daycare
    # @return [PFM::Pokemon]
    def retreive_egg(id)
      daycare = @daycares[id]
      daycare[:egg] = nil
      layable_check(daycare, daycare[:pokemon])
      pc "==== Pension Infos ====\nRate : #{daycare[:rate]}%\nPokémon : #{GameData::Text.get(0,daycare[:layable])}\n"
      pokemon = PFM::Pokemon.new(daycare[:layable], 1)
      inherit(pokemon, daycare[:pokemon])
      pokemon.egg_init
      pokemon.memo_text = [28, 31]
      return pokemon
    end
    # If there's an egg in the daycare
    # @param id [Integer] the ID of the daycare
    # @return [Boolean]
    def has_egg?(id)
      return false unless @daycares[id]
      return true if(@daycares[id][:egg])
      return false
    end
    # If a daycare is full
    # @param id [Integer] the ID of the daycare
    # @return [Boolean]
    def full?(id)
      if(daycare = @daycares[id] and daycare[:pokemon].size > 1)
        return true
      end
      return false
    end
    # If a daycare is empty
    # @param id [Integer] the ID of the daycare
    # @return [Boolean]
    def empty?(id)
      if(daycare = @daycares[id] and daycare[:pokemon].size != 0)
        return false
      end
      return true
    end
    # Parse the daycare Pokemon text info
    # @param var_id [Integer] ID of the game variable where the ID of the daycare is stored
    # @param index [Integer] index of the Pokemon in the daycare
    def parse_poke(var_id, index)
      pokemon = @daycares[$game_variables[var_id]][:pokemon][index]
      ::PFM::Text.parse(36, 33 + (pokemon.gender == 0 ? 3 : pokemon.gender),
      ::PFM::Text::NUM3[1] => pokemon.level.to_s, ::PFM::Text::PKNAME[0] => pokemon.name)
    end
    # Check the layability of a daycare
    # @param daycare [Hash] the daycare informations Hash
    # @param parents [Array] the list of Pokemon in the daycar
    def layable_check(daycare, parents)
      #>Détection de la femelle par son genre
      female = parents[0].gender == 2 ? parents[0] : parents[1]
      #>Si la femelle détecté n'est pas une femmelle, on vérifie que c'est un métamorph pour inverser
      female = parents[0] if(female.gender == 0 and female.id == 132)
      #>Le mâle est l'autre Pokémon
      male = parents[1-parents.index(female)]
      #>Datas
      female_data = $game_data_pokemon[female.id][0]
      male_data = $game_data_pokemon[male.id][0]
      oval_charm = $bag.has_item?(631)
      #>Calcul des ratios
      rate = 0
      common_group = (female_data.breed_groupes - (female_data.breed_groupes - male_data.breed_groupes)).uniq
      if common_group.size > 0 #>Groupes en commun
        if male.trainer_id == female.trainer_id #>Même DO
          rate = (oval_charm ? 80 : 50)
        else
          rate = (oval_charm ? 88 : 70)
        end
      else #>Aucun groupes en commun
        if male.trainer_id == female.trainer_id #>Même DO
          rate = (oval_charm ? 40 : 20)
        else
          rate = (oval_charm ? 80 : 50)
        end
      end
      rate = 0 if male.gender != 0 and male.gender == female.gender
      rate = 0 if male_data.breed_groupes.include?(15) or female_data.breed_groupes.include?(15)
      daycare[:rate] = rate
      if rate != 0
        return if special_lay_check(daycare, female, male, female_data, male_data)
        daycare[:layable] = female_data.baby
        daycare[:rate] = 0 if daycare[:layable] == 0
      else
        daycare[:layable] = 0
      end
    end
    # Special check to lay an egg
    # @param daycare [Hash] the daycare information
    # @param female [PFM::Pokemon] the female
    # @param male [PFM::Pokemon] the male
    # @param female_data [GameData::Pokemon] the primitive data of the female (form 0)
    # @param male_data [GameData::Polemon] the primitive data of the male (form 0)
    # @return [Integer, false] the id of the Pokemon that will be in the egg or no special baby with these Pokemon
    def special_lay_check(daycare, female, male, female_data, male_data)
      male_id = male.id
      female_id = female.id
      #> Manaphy / Phione + Métamorph
      if male_id == 132 and (female_id == 489 or female_id == 490)
        return daycare[:layable] = 489
      #> Nidoran Male (normalement toujours pris en femelle) / Nidoran femelle
      elsif female_id == 32 or female_id == 29
        return daycare[:layable] = (rand(2) == 0 ? 32 : 29)
      #> Muciole / Lumivol
      elsif female_id == 313 or female_id == 314
        return daycare[:layable] = (rand(2) == 0 ? 313 : 314)
      #> Tauros / Ecremeuh
      elsif female_id == 128 or female_id == 241
        return daycare[:layable] = (rand(2) == 0 ? 128 : 241)
      #> Manaphy / Phione
      elsif(Not_Breeding.include?(female_id) or Not_Breeding.include?(male_id))
        daycare[:layable] = 0
        return daycare[:rate] = 0
      end
      #>Bébé par encens
      item_held = [male.item_holding] #[female.item_holding, male.item_holding]
      #> Maril / Encens Mer
      if(female_data.baby == 183 and item_held.include?(254))
        return daycare[:layable] = 298
      #> Qulbutoké / Encens Doux
      elsif(female_id == 202 and item_held.include?(255))
        return daycare[:layable] = 360
      #> Roselia / Encens Fleur
      elsif(female_data.baby == 315 and item_held.include?(318))
        return daycare[:layable] = 406
      #> Eoko / Encens Pur
      elsif(female_id == 358 and item_held.include?(320))
        return daycare[:layable] = 433
      #> Simularbre / Encens Roc
      elsif(female_id == 185 and item_held.include?(315))
        return daycare[:layable] = 438
      #> M. Mime / Encens Bizarre
      elsif(female_id == 122 and item_held.include?(314))
        return daycare[:layable] = 439
      #> Leveinard / Encens Veine
      elsif(female_data.baby == 113 and item_held.include?(319))
        return daycare[:layable] = 440
      #> Ronflex / Encens Plein
      elsif(female_id == 143 and item_held.include?(316))
        return daycare[:layable] = 446
      #> Demanta / Encens Vague
      elsif(female_id == 226 and item_held.include?(317))
        return daycare[:layable] = 458
      end
      return false
    end
    # Give 1 exp point to a pokemon 
    # @param pokemon [PFM::Pokemon] the pokemon to give one exp point
    def exp_pokemon(pokemon)
      if(pokemon.level < GameData::MAX_LEVEL)
        pokemon.exp += 1
        if(pokemon.exp >= pokemon.exp_lvl)
          pokemon.level_up_stat_refresh
          pokemon.check_skill_and_learn(true)
          pc "==== Pension Infos ====\nLevelUp : #{pokemon.given_name}\n"
        end
      end
    end
    # Attempt to lay an egg
    # @param daycare [Hash] the daycare informations Hash
    def try_to_lay(daycare)
      return if daycare[:egg]
      daycare[:egg] = true if(rand(100) < daycare[:rate])
      pc "==== Pension Infos ====\nLay attempt : #{!daycare[:egg] ? "Failure" : "Success"}\n"
    end
    # IV setter list
    IV_Set = [:iv_hp=, :iv_dfe=, :iv_atk=, :iv_spd=, :iv_ats=, :iv_dfs=]
    # IV getter list
    IV_Get = [:iv_hp, :iv_dfe, :iv_atk, :iv_spd, :iv_ats, :iv_dfs]
    # Make the pokemon inherit the gene of its parents
    # @param pokemon [PFM::Pokemon] the pokemon
    # @param parents [Array(PFM::Pokemon, PFM::Pokemon)] the parents
    def inherit(pokemon, parents)
      #>Détection de la femelle par son genre
      female = parents[0].gender == 2 ? parents[0] : parents[1]
      #>Si la femelle détecté est un mâle on corrige
      female = parents[0] if(female.gender == 1)
      #>Le mâle est l'autre Pokémon
      male = parents[1-parents.index(female)]
      #>Datas
      female_data = female.get_data
      male_data = male.get_data
      pokemon_data = pokemon.get_data
      #===
      #> Pokéball (celle de la femelle si non masterball)
      #===
      if female.captured_with != 1 and female.captured_with != 16
        pokemon.captured_with = female.captured_with
      end
      #===
      #> Sexe
      #===
      #===
      #> Nature (Transmission si parent portant pierre stase)
      #===
      pokemon.nature = male.nature_id if male.item_holding == 229
      pokemon.nature = female.nature_id if female.item_holding == 229
      #===
      #> Talent
      #===
      ability = female.ability
      abilities = female_data.abilities
      if(abilities.index(ability) == 2)
        pokemon.ability = ability if rand(100) < 60
      elsif(rand(100) < 80)
        pokemon.ability = ability
      end
      #===
      #> Attaques
      #===
      female_moveset = Array.new(female_data.move_set.size/2) { |i| female_data.move_set[i*2+1] }
      male_moveset = Array.new(male_data.move_set.size/2) { |i| male_data.move_set[i*2+1] }
      pokemon_moveset = Array.new(pokemon_data.move_set.size/2) { |i| pokemon_data.move_set[i*2+1] }
      #> attaques qu'il apprend en montant de niveau et que le père et la mère connaissent.
      common_skill = female_moveset - (female_moveset - male_moveset)
      common_skill = pokemon_moveset - (pokemon_moveset - common_skill)
      skill_id = nil
      common_skill.each do |skill_id|
        if(female.skill_learnt?(skill_id) and male.skill_learnt?(skill_id))
          if(pokemon.learn_skill(skill_id) == nil) #> skills_set plein et non appris
            pokemon.skills_set.shift
            pokemon.learn_skill(skill_id)
          end
        end
      end
      common_skill = pokemon_data.breed_moves
      #> attaques qu'il apprend uniquement par reproduction et que le père connaît.
      common_skill.each do |skill_id|
        if(male.skill_learnt?(skill_id))
          if(pokemon.learn_skill(skill_id) == nil) #> skills_set plein et non appris
            pokemon.skills_set.shift
            pokemon.learn_skill(skill_id)
          end
        end
      end
      #> attaques qu'il apprend uniquement par reproduction et que la mère connaît.
      common_skill.each do |skill_id|
        if(female.skill_learnt?(skill_id))
          if(pokemon.learn_skill(skill_id) == nil) #> skills_set plein et non appris
            pokemon.skills_set.shift
            pokemon.learn_skill(skill_id)
          end
        end
      end
      #===
      #> IVs
      #===
      #> Première salve : au hasard parmi les 6 stats ou machin pouvoir
      ivs_get = IV_Get.clone
      ivs_set = IV_Set.clone
      #> Noeud Destin
      if female.item_holding == 280 || male.item_holding == 280
        i = nil
        iv_indexes = Array.new(12) { |i| i }
        ivs_choosen = Array.new(5) do 
          i = iv_indexes[rand(iv_indexes.size)]
          iv_indexes.delete(i)
          i
        end
        ivs_choosen.sort.each do |i|
          from = (i/6) == 0 ? male : female
          pokemon.send(ivs_set[i%6], from.send(ivs_get[i%6]))
        end
      else
        from = parents[rand(2)]
        rng = rand(ivs_get.size)
        pokemon.send(ivs_set[rng], from.send(ivs_get[rng]))
        #> Deuxième salve : au hasard sans les hp
        ivs_get.shift
        ivs_set.shift
        from = parents[rand(2)]
        rng = rand(ivs_get.size)
        pokemon.send(ivs_set[rng], from.send(ivs_get[rng]))
        #>Troisième salve : au hasard sans les hp et la défense
        ivs_get.shift
        ivs_set.shift
        from = parents[rand(2)]
        rng = rand(ivs_get.size)
        pokemon.send(ivs_set[rng], from.send(ivs_get[rng]))
      end
      #> Pouvoirs
      ivs_get = IV_Get.clone
      ivs_set = IV_Set.clone
      power = [294, 290, 289, 293, 291, 292]
      if(rng = power.index(female.item_holding))
        pokemon.send(ivs_set[rng], female.send(ivs_get[rng]))
      end
      if(rng = power.index(male.item_holding))
         pokemon.send(ivs_set[rng], male.send(ivs_get[rng]))
      end
    end

  end
end
