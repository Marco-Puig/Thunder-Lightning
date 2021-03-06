#encoding: utf-8

module GameData
  # The base class of any GameData object
  class Base
    # The id of the object
    # @return [Integer] /!\ can be nil if the data was not correctly defined.
    attr_accessor :id
    # The db_symbol of the object
    # @return [Symbol] /!\ can be nil if the data was not properly defined
    attr_accessor :db_symbol
  end
end
