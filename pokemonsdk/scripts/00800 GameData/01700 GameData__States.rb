#encoding: utf-8

module GameData
  # Natural state ID
  module States
    Poison = Poisoned = 1 # Poisoned state
    Paralyze = Paralyzed = 2 # Paralyzed state
    Burn = 3 # Burn state
    Sleep = Asleep = 4 # Asleep state
    Freeze = Frozen = 5 # Frozen state
    Confuse = Confused = 6 # Confused State /!\ only in items/skills
    Toxic = 8 # Toxic state
    Death = KO = 9 # K.O. state
  end
end
