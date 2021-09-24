module Battle
  class Move
    ATK_ABILITY_MODIFIER = Hash.new(:calc_ua_1)
    ATS_ABILITY_MODIFIER = Hash.new(:calc_ua_1)
    ATK_ITEM_MODIFIER = Hash.new(:calc_ua_1)
    ATS_ITEM_MODIFIER = Hash.new(:calc_ua_1)

    # Pure Power ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_am_pure_power(user, target)
      2
    end
    ATK_ABILITY_MODIFIER[:pure_power] = :calc_am_pure_power
    ATK_ABILITY_MODIFIER[:huge_power] = :calc_am_pure_power

    # Flower Gift ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_am_flower_gift(user, target)
      $env.sunny? ? 1.5 : 1
    end
    ATK_ABILITY_MODIFIER[:flower_gift] = :calc_am_flower_gift
    ATS_ABILITY_MODIFIER[:solar_power] = :calc_am_flower_gift

    # Guts ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_am_guts(user, target)
      return 1.5 if user.paralyzed? || user.poisoned? || user.toxic? || user.burn? || user.asleep?
      return 1
    end
    ATK_ABILITY_MODIFIER[:guts] = :calc_am_guts

    # Hustle ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_am_hustle(user, target)
      1.5
    end
    ATK_ABILITY_MODIFIER[:hustle] = :calc_am_hustle

    # Slow start ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_am_slow_start(user, target)
      0.5 if user.turn_count < 5
    end
    ATK_ABILITY_MODIFIER[:slow_start] = :calc_am_slow_start

    PLUS_MINUS_ABILITIES = %i[plus minus]
    # Plus/Minus ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_am_plus_minus(user, target)
      return 1 unless PLUS_MINUS_ABILITIES.include?(user.ability_db_symbol)
      # The partner should have the other ability
      partner_expectation = user.ability_db_symbol == :plus ? :minus : :plus
      # Try all the adjacent partner
      (user.position - 1).step(user.position + 1, 2) do |position|
        partner = logic.battler(user.bank, position)
        return 1.5 if partner&.ability_db_symbol == partner_expectation
      end
      # No partner with the right ability => 1
      return 1
    end
    ATS_ABILITY_MODIFIER[:plus] = :calc_am_plus_minus
    ATS_ABILITY_MODIFIER[:minus] = :calc_am_plus_minus

    # Choice Band item multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_im_choice_band(user, target)
      1.5
    end
    ATK_ITEM_MODIFIER[:choice_band] = :calc_im_choice_band
    ATS_ITEM_MODIFIER[:choice_specs] = :calc_im_choice_band

    THICK_CLUB_POKEMON = %i[cubone marowak]
    # Thick Club item multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_im_thick_club(user, target)
      THICK_CLUB_POKEMON.include?(user.db_symbol) ? 2 : 1
    end
    ATK_ITEM_MODIFIER[:thick_club] = :calc_im_thick_club

    SOUL_DEW_POKEMON = %i[latios latias]
    # Soul Dew item multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_im_soul_dew(user, target)
      SOUL_DEW_POKEMON.include?(user.db_symbol) ? 1.5 : 1
    end
    ATS_ITEM_MODIFIER[:soul_dew] = :calc_im_soul_dew

    # Deep Sea Tooth item multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_im_deep_sea_tooth(user, target)
      user.db_symbol == :clamperl ? 2 : 1
    end
    ATS_ITEM_MODIFIER[:deep_sea_tooth] = :calc_im_deep_sea_tooth
  end
end
