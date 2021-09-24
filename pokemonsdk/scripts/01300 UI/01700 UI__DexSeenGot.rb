module UI
  # Dex sprite that show the Pokemon location
  class DexSeenGot < SpriteStack
    # Create a new dex win sprite
    def initialize(viewport)
      # Create the sprite stack at coordinate 0, 152 using the RPG::Cache.pokedex as image source
      super(viewport, 0, 152, default_cache: :pokedex)

      # Show the background image
      add_background('WinNum')
      # Show the "Seen: " text
      seen_text = add_text(2, 0, 79, 26, ext_text(9000, 20), color: 10)
      seen_text.bold = true
      # Show the number of Pokemon Seen
      add_text(seen_text.real_width + 4, 0, 79, 26, :pokemon_seen, 0, type: SymText, color: 10)
      # Show the "Got: " text
      got_text = add_text(2, 28, 79, 26, ext_text(9000, 21), color: 10)
      got_text.bold = true
      # Show the number of Pokemon Got
      add_text(got_text.real_width + 4, 28, 79, 26, :pokemon_captured, 0, type: SymText, color: 10)

      # Define the Pokedex as text source
      self.data = $pokedex
    end
  end
end
