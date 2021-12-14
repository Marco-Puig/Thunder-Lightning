module Battle
  class Move
    # Return the chance of hit of the move
    # @param user [PFM::PokemonBattler] user of the move
    # @param target [PFM::PokemonBattler] target of the move
    # @return [Float]
    def chance_of_hit(user, target)
      log_data("# chance_of_hit(#{user}, #{target}) for #{db_symbol}")
      return 100 if user.effects.get(:lock_on)&.target == target
      return 100 if user.has_ability?(:no_guard) || target.has_ability?(:no_guard)
      return 100 if status? && accuracy <= 0

      factor = logic.each_effects(user, target).reduce(1) { |product, e| product * e.chance_of_hit_multiplier(user, target, self) }
      factor *= accuracy_mod(user)
      factor *= evasion_mod(target)
      log_data("result = #{factor * 100}")
      return factor * 100
    end

    # Return the accuracy modifier of the user
    # @param user [PFM::PokemonBattler]
    # @return [Float]
    def accuracy_mod(user)
      return user.stat_multiplier_acceva(user.acc_stage)
    end

    # Return the evasion modifier of the target
    # @param target [PFM::PokemonBattler]
    # @return [Float]
    def evasion_mod(target)
      return target.stat_multiplier_acceva(-target.eva_stage) # <=> 1 / ...
    end
  end
end
