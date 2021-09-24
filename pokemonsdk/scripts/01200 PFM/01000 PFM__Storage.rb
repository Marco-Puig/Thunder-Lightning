#encoding: utf-8

module PFM
  # Player PC storage
  #
  # The main object is stored in $storage and $pokemon_party.storage
  # @author Nuri Yuri
  class Storage
    # Maximum amount of box
    MAX_BOXES = 31
    # Number of box theme (background : Graphics/PC/f_id, title : Graphics/PC/title_id
    NB_THEMES = 32
    # The party of the other actor (friend)
    # @return [Array<PFM::Pokemon>]
    attr_accessor :other_party
    # The id of the current box
    # @return [Integer]
    attr_accessor :current_box
    # Create a new storage
    def initialize
      @boxes = Array.new(MAX_BOXES) { Array.new(30) }
      @names = Array.new(MAX_BOXES) { |i| ::GameData::Text.get(16, i) }
      @themes = Array.new(MAX_BOXES) { |i| i+1 }
      $game_variables[Yuki::Var::Boxes_Current] = @current_box = 0
      @other_party = Array.new
    end
    # Store a pokemon to the PC
    # @param pkmn [PFM::Pokemon] the Pokemon to store
    # @return [Boolean] if the Pokemon has been stored
    def store(pkmn)
      start=@current_box
      while(true)
        box=@boxes[@current_box]
        box.size.times do |i|
          if(!box[i])
            box[i]=pkmn
            pkmn.cure
            pkmn.hp = pkmn.max_hp
            $game_variables[Yuki::Var::Boxes_Current]=@current_box
            return true
          end
        end
        @current_box+=1
        @current_box=0 if @current_box>=@boxes.size
        return false if start==@current_box
      end
    end
    # Retreive a box content
    # @param id [Integer] the id of the box
    # @return [Array<30 PFM::Pokemon, nil>]
    def get_box(id)
      return @boxes[id]
    end
    # Return a box name
    # @param id [Integer] the id of the box
    # @return [String]
    def get_box_name(id)
      return @names[id]
    end
    # Change the name of a box
    # @param id [Integer] the id of the box
    # @param name [String] the new name
    def set_box_name(id,name)
      @names[id] = name.to_s
    end
    # Get a box theme
    # @param id [Integer] the id of the box
    # @return [Integer] the id of the box theme
    def get_box_theme(id)
      return @themes[id]
    end
    # Change the theme of a box
    # @param id [Integer] the id of the box
    # @param theme [Integer] the id of the box theme
    def set_box_theme(id, theme)
      @themes[id] = theme.to_i
    end 
    # Remove a Pokemon in the current box
    # @param index [Integer] index of the Pokemon in the current box
    # @return [PFM::Pokemon, nil] the pokemon removed
    def remove(index)
      pkmn = @boxes[@current_box][index]
      @boxes[@current_box][index] = nil
      return pkmn
    end     
    # Is the entity at an index of the current box a Pokemon ?
    # @param index [Integer] index of the entity in the current box
    # @return [Boolean]
    def isPokemon?(index)
      return @boxes[@current_box][index].class == ::PFM::Pokemon
    end    
    # Return the Pokemon at an index in the current box
    # @param index [Integer] index of the Pokemon in the current box
    # @return [PFM::Pokemon, nil]
    def info(index)
      return @boxes[@current_box][index]
    end    
    # Store a Pokemon at a specific index in the current box
    # @param pkmn [PFM::Pokemon] the Pokemon to store
    # @param index [Integer] index of the Pokemon in the current box
    # @note The pokemon is healed when stored
    def store_box(pkmn, index)
      @boxes[@current_box][index] = pkmn
      pkmn.cure
      pkmn.hp = pkmn.max_hp
    end
    # Return the amount of box in the storage
    # @return [Integer]
    def max_box
      return @boxes.size
    end
    # Check if there's a Pokemon alive in the box (egg or not)
    # @return [Boolean]
    def any_pokemon_alive
      @boxes.each do |box|
        box.each do |pkmn|
          return true if pkmn and pkmn.hp > 0
        end
      end
      return false
    end
    # Count the number of Pokemon available in the box
    # @param dead [Boolean] if the counter exclude the "dead" Pokemon
    # @return [Integer]
    def count_pokemon(dead = true)
      counter = 0
      @boxes.each do |box|
        box.each do |pokemon|
          if(pokemon and (dead or !pokemon.dead?))
            counter+=1
          end
        end
      end
      return counter
    end
    # Yield a block on each Pokemon of storage
    def each_pokemon
      @boxes.each do |box|
        box.each do |pkmn|
          return yield(pkmn) if pkmn
        end
      end
    end
  end
end
