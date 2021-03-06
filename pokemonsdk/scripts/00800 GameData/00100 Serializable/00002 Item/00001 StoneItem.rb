module GameData
  # Item that describe an item that is used as a Stone on Pokemon
  class StoneItem < Item
  end
end

safe_code('Register StoneItem ItemDescriptor') do
  PFM::ItemDescriptor.define_chen_prevension(GameData::StoneItem) do
    next $game_temp.in_battle
  end

  PFM::ItemDescriptor.define_on_pokemon_usability(GameData::StoneItem) do |item, pokemon|
    next false if pokemon.egg?

    next pokemon.evolve_check(:stone, item.id)
  end

  PFM::ItemDescriptor.define_on_pokemon_use(GameData::StoneItem) do |item, pokemon, scene|
    id, form = pokemon.evolve_check(:stone, item.id)
    scene.call_scene(GamePlay::Evolve, pokemon, id, form, true) do |evolve_scene|
      scene.running = false
      $bag.add_item(item.id, 1) unless GamePlay::Evolve.from(evolve_scene).evolved
    end
  end
end
