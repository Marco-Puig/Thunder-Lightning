#encoding: utf-8

module GameData
  # Item Data structure
  # @author Nuri Yuri
  class Item < Base
    # Default icon name
    NoIcon="return"
    # Name of the item icon in Graphics/Icons/
    # @return [String]
    attr_accessor :icon
    # Price of the item
    # @return [Integer]
    attr_accessor :price
    # Socket id of the item
    # @return [Integer]
    attr_accessor :socket
    # Sort position in the bag, the lesser the position is, the topper it item is shown
    # @return [Integer]
    attr_accessor :position
    # If the item can be used in Battle
    # @return [Boolean]
    attr_accessor :battle_usable
    # If the item can be used in Map
    # @return [Boolean]
    attr_accessor :map_usable
    # If the item has limited uses (can be thrown)
    # @return [Boolean]
    attr_accessor :limited
    # If the item can be held by a Pokemon
    # @return [Boolean]
    attr_accessor :holdable
    # Power of the item when thrown to an other pokemon
    # @return [Integer]
    attr_accessor :fling_power
    # Heal related data of the item
    # @return [GameData::ItemHeal, nil]
    attr_accessor :heal_data
    # Ball related data of the item
    # @return [GameData::BallData, nil]
    attr_accessor :ball_data
    # Miscellaneous data of the item
    # @return [GameData::ItemMisc, nil]
    attr_accessor :misc_data
    # Safely return the name of an item
    # @param id [Integer] id of the item in the database
    # @return [String]
    def self.name(id)
      if(id.between?(1, LastID))
        return Text.get(12,id)
      end
      return Text.get(12,0)
    end
    # Safely return the description of an item
    # @param id [Integer] id of the item in the database
    # @return [String]
    def self.descr(id)
      if(id.between?(1, LastID))
        return Text.get(13,id)
      end
      return Text.get(13,0)
    end
    # Safely return the icon of an item
    # @param id [Integer] id of the item in the database
    # @return [String]
    def self.icon(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].icon
      end
      return NoIcon
    end
    # Safely return the price of an item
    # @param id [Integer] id of the item in the database
    # @return [Integer]
    def self.price(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].price
      end
      return 0
    end
    # Safely return the socket id of an item
    # @param id [Integer] id of the item in the database
    # @return [Integer]
    def self.socket(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].socket
      end
      return 0
    end
    # Safely return the battle_usable value of an item
    # @param id [Integer] id of the item in the database
    # @return [Boolean]
    def self.battle_usable?(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].battle_usable
      end
      return false
    end
    # Safely return the map_usable value of an item
    # @param id [Integer] id of the item in the database
    # @return [Boolean]
    def self.map_usable?(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].map_usable
      end
      return false
    end
    # Safely return the limited_use value of an item
    # @param id [Integer] id of the item in the database
    # @return [Boolean]
    def self.limited_use?(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].limited
      end
      return true
    end
    # Safely return the holdable value of an item
    # @param id [Integer] id of the item in the database
    # @return [Boolean]
    def self.holdable?(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].holdable
      end
      return false
    end
    # Safely return the sort position of an item
    # @param id [Integer] id of the item in the database
    # @return [Integer]
    def self.position(id)
      if(id.between?(1, LastID) and $game_data_item[id].position)
        return $game_data_item[id].position
      end
      return 99999
    end
    # Safely return the heal_data value of an item
    # @param id [Integer] id of the item in the database
    # @return [GameData::ItemHeal, nil]
    def self.heal_data(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].heal_data
      end
      return nil
    end
    # Safely return the ball_data value of an item
    # @param id [Integer] id of the item in the database
    # @return [GameData::BallData, nil]
    def self.ball_data(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].ball_data
      end
      return nil
    end
    # Safely return the misc_data of an item
    # @param id [Integer] id of the item in the database
    # @return [GameData::ItemMisc, nil]
    def self.misc_data(id)
      if(id.between?(1, LastID))
        return $game_data_item[id].misc_data
      end
      return nil
    end
    # Safely return the db_symbol of an item
    # @param id [Integer] id of the item in the database
    # @return [Symbol]
    def self.db_symbol(id)
      if(id.between?(1, LastID))
        return ($game_data_item[id].db_symbol || :__undef__)
      end
      return :__undef__
    end
    # Find an item using symbol
    # @param symbol [Symbol]
    # @return [GameData::Item]
    def self.find_using_symbol(symbol)
      data = $game_data_item.find { |data| data.db_symbol == symbol }
      return $game_data_item[0] unless data
      data
    end
    # Get id using symbol
    # @param symbol [Symbol]
    # @return [Integer]
    def self.get_id(symbol)
      data = $game_data_item.index { |data| data.db_symbol == symbol }
      data.to_i
    end
    # Convert a collection to symbolized collection
    # @param collection [Enumerable]
    # @param keys [Boolean] if hash keys are converted
    # @param values [Boolean] if hash values are converted
    # @return [Enumerable] the collection
    def self.convert_to_symbols(collection, keys: false, values: false)
      if collection.is_a?(Hash)
        new_collection = {}
        collection.each do |key, value|
          key = self.db_symbol(key) if keys and key.is_a?(Integer)
          if value.is_a?(Enumerable)
            value = self.convert_to_symbols(value, keys: keys, values: values)
          else
            value = self.db_symbol(value) if values and value.is_a?(Integer)
          end
          new_collection[key] = value
        end
        collection = new_collection
      else
        collection.each_with_index do |value, index|
          if value.is_a?(Enumerable)
            collection[index] = self.convert_to_symbols(value, keys: keys, values: values)
          else
            collection[index] = self.db_symbol(value) if value.is_a?(Integer)
          end
        end
      end
      collection
    end
  end
end
