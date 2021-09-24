#encoding: utf-8

module GameData
  # Constants used by PFM::PokemonParty
  module PokemonParty
    # The list of ability that decrease the encounter frequency
    DecFreqEnc = %i[white_smoke quick_feet stench]
    # The list of ability that increase the encounter frequency
    IncFreqEnc = %i[no_guard illuminate arena_trap]
    # Ability that decrese the encounter during hail weather
    HailDecreasingFreqEnc = [:snow_cloak]
    # Ability that decrese the encounter during sandstorm weather
    SandstormDecreasingFreqEnc = [:sand_veil]
    # Abilities that increase the hatch speed
    HatchSpeedIncreasingAbilities = %i[magma_armor flame_body]

  end
end
