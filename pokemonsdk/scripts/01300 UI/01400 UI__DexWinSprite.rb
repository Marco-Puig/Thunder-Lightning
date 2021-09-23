module UI
  # Dex sprite that show the Pokemon sprite with its name
  class DexWinSprite < SpriteStack
    # Create a new dex win sprite
    def initialize(viewport)
      # Create the sprite stack at coordinate 3, 11 using the RPG::Cache.pokedex as image source
      super(viewport, 3, 11, default_cache: :pokedex)

      # Show the background of the DexWinSprite
      add_background('WinSprite')
      # Show the Battler face of the Pokemon (Warning: PokemonFaceSprite use the bottom center as sprite origin)
      add_sprite(60, 124, NO_INITIAL_IMAGE, type: PokemonFaceSprite)
      # Show the name of the Pokemon in bold upper-case
      pokemon_name = add_text(3, 6, 116, 19, :name_upper, 1, type: SymText, color: 10)
      pokemon_name.bold = true
    end
  end
end
