#encoding: utf-8

if PARGV[:"animation-editor"]
  # This is the configuration module of PSDK. 
  # In this script you can change the configuration values.
  # 
  # You can access to the configuration value by writing ::Config::ValueName
  # @example Setting the level of a Pokemon to the max level
  #   pokemon.level = ::Config::Pokemon_Max_Level
  module Config
    remove_const :Title
    remove_const :ScreenWidth
    remove_const :ScreenHeight
    remove_const :ScreenScale
    # Title of the Game
    Title = "PSDK :: Animation Editor"
    # The width of the screen [Integer]
    ScreenWidth = 1280
    # The height of the screen [Integer]
    ScreenHeight = 720
    # The screen scale
    ScreenScale = 1
  end
  require "plugins/animator.rb"
end
