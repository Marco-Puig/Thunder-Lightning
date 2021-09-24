#encoding: utf-8

module GameData
  # Module that helps you to retrieve safely texts related to Pokémon's Ability
  # @author Nuri Yuri
  module Abilities
    # List of Abilities db_symbols
    @db_symbols = []
    module_function
    # Returns the name of an ability
    # @param id [Integer] id of the ability in the database.
    # @return [String] the name of the ability or the name of the first ability.
    # @note The description is fetched from the 5th text file.
    def name(id)
      if id >= 0 and id < $game_data_abilities.size
        return GameData::Text.get(4, $game_data_abilities[id])
      else
        GameData::Text.get(4, 0)
      end
    end
    # Returns the description of an ability
    # @param id [Integer] id of the ability in the database.
    # @return [String] the description of the ability or the description of the first ability.
    # @note The description is fetched from the 5th text file.
    def descr(id)
      if id >= 0 and id < $game_data_abilities.size
        return GameData::Text.get(5, $game_data_abilities[id])
      else
        GameData::Text.get(5, 0)
      end
    end
    # Returns the symbol of an ability
    # @param id [Integer] id of the ability in the database
    # @return [Symbol] the db_symbol of the ability
    def db_symbol(id)
      @db_symbols.fetch(id, :__undef__)
    end
    # Loads the symbols
    # @param sym_tbl [Array<Symbol>]
    def load_symbols(sym_tbl)
      @db_symbols.clear
      @db_symbols.concat(sym_tbl)
    end
    # Find an ability id using symbol
    # @param symbol [Symbol]
    # @return [Integer, nil] nil = not found
    def find_using_symbol(symbol)
      @db_symbols.index(symbol)
    end
    # Convert a collection to symbolized collection
    # @param collection [Enumerable]
    # @param keys [Boolean] if hash keys are converted
    # @param values [Boolean] if hash values are converted
    # @return [Enumerable] the collection
    def convert_to_symbols(collection, keys: false, values: false)
      if collection.is_a?(Hash)
        new_collection = {}
        collection.each do |key, value|
          key = db_symbol(key) if keys and key.is_a?(Integer)
          if value.is_a?(Enumerable)
            value = convert_to_symbols(value, keys: keys, values: values)
          else
            value = db_symbol(value) if values and value.is_a?(Integer)
          end
          new_collection[key] = value
        end
        collection = new_collection
      else
        collection.each_with_index do |value, index|
          if value.is_a?(Enumerable)
            collection[index] = convert_to_symbols(value, keys: keys, values: values)
          else
            collection[index] = db_symbol(value) if value.is_a?(Integer)
          end
        end
      end
      collection
    end
  end
end
