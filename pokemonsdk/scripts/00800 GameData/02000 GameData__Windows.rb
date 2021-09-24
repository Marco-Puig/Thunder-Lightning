#encoding: utf-8

module GameData
  # Window Builders
  # 
  # Every constants should be Array of integer like this
  #    ConstName = [middle_tile_x, middle_tile_y, middle_tile_width, middle_tile_height, contents_offset_x, contents_offset_y]
  module Windows
    MessageWindow = [16,16, 8,8, 16,8]#[16,27, 24,13, 14,14] # Message Window
    MessageHGSS = [14,7, 8,8, 16,8] # HGSS Message Window
  end
end
