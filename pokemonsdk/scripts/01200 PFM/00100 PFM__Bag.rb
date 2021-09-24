#encoding: utf-8

# Module that define inGame data / script interface
module PFM
  # InGame Bag management
  #
  # The global Bag object is stored in $bag and $pokemon_party.bag
  # @author Nuri Yuri
  class Bag
    # Last socket used in the bag
    # @return [Integer]
    attr_accessor :last_socket
    # Last index in the socket
    # @return [Integer]
    attr_accessor :last_index
    # If the bag is locked (and react as being empty)
    # @return [Boolean]
    attr_accessor :locked
    # Number of shortcut
    MAX_ShortCut = 4
    # Create a new Bag
    def initialize
      @items = Array.new($game_data_item.size,0)
      @orders = [[],[],[],[],[],[],[]]
      @last_socket = 1
      @last_index = 0
      @shortcut = Array.new(MAX_ShortCut, 0)
      @locked = false
    end
    # If the bag contain a specific item
    # @param id [Integer, Symbol] id of the item in the database
    # @return [Boolean]
    def has_item?(id)
      return false if @locked
      id = GameData::Item.get_id(id) if id.is_a?(Symbol)
      nb = @items[id].to_i
      return nb>0
    end
    # The quantity of an item in the bag
    # @param id [Integer, Symbol] id of the item in the database
    # @return [Integer]
    def item_quantity(id)
      return 0 if @locked
      id = GameData::Item.get_id(id) if id.is_a?(Symbol)
      nb = @items[id].to_i
      return nb
    end
    # Add items in the bag
    # @param id [Integer, Symbol] id of the item in the database
    # @param nb [Integer] number of item to add
    def add_item(id, nb)
      return if @locked
      return remove_item(id,-nb) if nb<0
      id = GameData::Item.get_id(id) if id.is_a?(Symbol)
      @items[id] = 0 unless @items[id] #Sécurité pas forcément utile pour qqch de bien codé
      @items[id] += nb
      socket = GameData::Item.socket(id)
      unless get_order(socket).include?(id)
        get_order(socket) << id if @items[id] > 0
      end
      $quests.add_item(id)
    end
    alias store_item add_item
    # Remove items from the bag
    # @param id [Integer, Symbol] id of the item in the database
    # @param nb [Integer] number of item to remove
    def remove_item(id, nb)
      return if @locked
      return add_item(id, -nb) if nb<0
      id = GameData::Item.get_id(id) if id.is_a?(Symbol)
      @items[id] = 0 unless @items[id] #Sécurité pas forcément utile pour qqch de bien codé
      @items[id] -= nb
      if(@items[id] <= 0)
        @items[id] = 0
        socket = GameData::Item.socket(id)
        get_order(socket).delete(id)
      end
    end
    alias drop_item remove_item
    # Get the order of items in a socket
    # @param socket [Integer] ID of the socket
    # @return [Array]
    def get_order(socket)
      return [] if @locked
      order = @orders[socket]
      order = @orders[socket] = [] unless order #Sécurité
      return order
    end
    # Reset the order of items in a socket
    # @param socket [Integer] ID of the socket
    def reset_order(socket)
      get_order(socket).clear
      arr=get_order(socket)
      @items.size.times do |i|
        arr<<i if(@items[i]>0 and GameData::Item.socket(i)==socket)
      end
      #>Tri en fonction des positions
      arr.sort! do |a,b|
        GameData::Item.position(a) <=> GameData::Item.position(b)
      end
    end
    alias sort_ids reset_order
    # Sort the item of a socket by their names
    # @param socket [Integer] ID of the socket
    def sort_alpha(socket)
      reset_order(socket)
      get_order(socket).sort! do |a,b|
        GameData::Item.name(a)<=>GameData::Item.name(b)
      end
    end
    # Define a shortcut
    # @param index [Integer] index of the item in the shortcut
    # @param id [Integer, Symbol] id of the item in the database
    def set_shortcut(index, id)
      @shortcut ||= Array.new(MAX_ShortCut, 0)
      id = GameData::Item.get_id(id) if id.is_a?(Symbol)
      @shortcut[index % MAX_ShortCut] = id
    end
    # Get the shortcuts
    # @return [Array<Integer>]
    def get_shortcuts
      @shortcut ||= Array.new(MAX_ShortCut, 0)
      return @shortcut
    end
  end
end
