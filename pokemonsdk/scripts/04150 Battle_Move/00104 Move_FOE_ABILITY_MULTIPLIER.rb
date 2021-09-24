module Battle
  class Move
    FOE_ABILITY_MULTIPLIER = Hash.new(:calc_ua_1)

    THICK_FAT_TYPES = [2, 6]
    # Thick Fat foe ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_fa_thick_fat(user, target)
      THICK_FAT_TYPES.include?(type) ? 0.5 : 1
    end
    USER_ABILITY_MULTIPLIER[:thick_fat] = :calc_fa_thick_fat

    # Heatproof foe ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_fa_heatproof(user, target)
      type == 2 ? 0.5 : 1
    end
    USER_ABILITY_MULTIPLIER[:heatproof] = :calc_fa_heatproof

    # Dry Skin foe ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_fa_dry_skin(user, target)
      type == 2 ? 1.25 : 1
    end
    USER_ABILITY_MULTIPLIER[:dry_skin] = :calc_fa_dry_skin
  end
end
