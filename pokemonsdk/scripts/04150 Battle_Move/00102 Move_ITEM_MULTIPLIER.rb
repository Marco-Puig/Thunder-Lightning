module Battle
  class Move
    # List of multiplier for the items
    ITEM_MULTIPLIER = Hash.new(:calc_item_no_multplier)

    # Default item multiplier
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_item_no_multplier(user, target)
      1
    end

    # Calc the Muscle Band multiplier
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_muscle_band_multiplier(user, target)
      physical? ? 1.1 : 1
    end
    ITEM_MULTIPLIER[:muscle_band] = :calc_muscle_band_multiplier

    # Calc the Wise Glasses multiplier
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_wise_glasses_multiplier(user, target)
      special? ? 1.1 : 1
    end
    ITEM_MULTIPLIER[:wise_glasses] = :calc_wise_glasses_multiplier

    ADAMANT_ORB_TYPES = [15, 16]
    # Calc the Adamant Orb multiplier
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_adamant_orb_multiplier(user, target)
      return 1 unless user.db_symbol == :dialga
      return ADAMANT_ORB_TYPES.include?(type) ? 1.2 : 1
    end
    ITEM_MULTIPLIER[:adamant_orb] = :calc_adamant_orb_multiplier

    LUSTROUS_ORB_TYPES = [15, 3]
    # Calc the Lustrous Orb multiplier
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_lustrous_orb_multiplier(user, target)
      return 1 unless user.db_symbol == :palkia
      return LUSTROUS_ORB_TYPES.include?(type) ? 1.2 : 1
    end
    ITEM_MULTIPLIER[:lustrous_orb] = :calc_lustrous_orb_multiplier

    GRISEOUS_ORB_TYPES = [15, 14]
    # Calc the Griseous Orb multiplier
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_griseous_orb_multiplier(user, target)
      return 1 unless user.db_symbol == :giratina
      return GRISEOUS_ORB_TYPES.include?(type) ? 1.2 : 1
    end
    ITEM_MULTIPLIER[:griseous_orb] = :calc_griseous_orb_multiplier
    
    # @return [Hash{Symbol => Integer}] list of item_db_symbol to type boosting item
    BOOSTING_TYPE_ITEMS = {
      sea_incense: 3,
      odd_incense: 11,
      rock_incense: 13,
      wave_incense: 3,
      rose_incense: 5,
      flame_plate: 2,
      splash_plate: 3,
      zap_plate: 4,
      meadow_plate: 5,
      icicle_plate: 6,
      fist_plate: 7,
      toxic_plate: 8,
      earth_plate: 9,
      sky_plate: 10,
      mind_plate: 11,
      insect_plate: 12,
      stone_plate: 13,
      spooky_plate: 14,
      draco_plate: 15,
      dread_plate: 17,
      iron_plate: 16,
      pixie_plate: 18
    }
    # Calc the item boost multiplier
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Numeric]
    def calc_item_boost_type_multiplier(user, target)
      BOOSTING_TYPE_ITEMS[user.item_db_symbol] == type ? 1.2 : 1
    end
    BOOSTING_TYPE_ITEMS.each_key { |item| ITEM_MULTIPLIER[item] = :calc_item_boost_type_multiplier }
  end
end
