module Battle
  class Move
    DFE_ABILITY_MODIFIER = Hash.new(:calc_ua_1)
    DFS_ABILITY_MODIFIER = Hash.new(:calc_ua_1)
    DFE_ITEM_MODIFIER = Hash.new(:calc_ua_1)
    DFS_ITEM_MODIFIER = Hash.new(:calc_ua_1)

    # Flower gift
    DFS_ABILITY_MODIFIER[:flower_gift] = :calc_am_flower_gift

    # Metal Powder item multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_def_mod_metal_powder(user, target)
      return 1 unless target.db_symbol == :ditto
      target.moveset.each do |move|
        return 1 if move.db_symbol == :transform && move.used
      end
      return 1.5
    end
    DFE_ITEM_MODIFIER[:metal_powder] = :calc_def_mod_metal_powder
    DFS_ITEM_MODIFIER[:metal_powder] = :calc_def_mod_metal_powder

    # Marvel Scale ability multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_def_mod_marvel_scale(user, target)
      return 1.5 if target.paralyzed? || target.poisoned? || target.toxic? || target.burn? || target.asleep? || target.frozen?
      return 1
    end
    DFE_ABILITY_MODIFIER[:marvel_scale] = :calc_def_mod_marvel_scale

    # Deep Sea Scale item multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_def_mod_deep_sea_scale(user, target)
      target.db_symbol == :clamperl ? 2 : 1
    end
    DFS_ITEM_MODIFIER[:deep_sea_scale] = :calc_def_mod_deep_sea_scale

    # Soul Dew item multiplier
    # @param user [PFM::PokemonBattler]
    # @param target [PFM::PokemonBattler]
    # @return [Numeric]
    def calc_def_mod_soul_dew(user, target)
      SOUL_DEW_POKEMON.include?(target.db_symbol) ? 1.5 : 1
    end
    DFS_ITEM_MODIFIER[:soul_dew] = :calc_def_mod_soul_dew
  end
end
