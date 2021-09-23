#encoding: utf-8

module GameData
  # Commonly used Colors
  # @author Nuri Yuri
  module Colors
    # Experience color (BattleBar)
    BattleBar_EXP = Color.new(16, 156, 206)
    # HP colors (red, orange, orange, green, green, green)
    BattleBar_HP_H = Array.new(6)
    BattleBar_HP_H[5] = BattleBar_HP_H[4] = BattleBar_HP_H[3] = Color.new(0, 255, 74)
    BattleBar_HP_H[2] = BattleBar_HP_H[1] = Color.new(234, 255, 0)
    BattleBar_HP_H[0] = Color.new(255, 0, 0)
    # HP colors shadow (red, orange, orange, green, green, green)
    BattleBar_HP_D = Array.new(6)
    BattleBar_HP_D[5] = BattleBar_HP_D[4] = BattleBar_HP_D[3] = Color.new(0, 189, 33)
    BattleBar_HP_D[2] = BattleBar_HP_D[1] = Color.new(173, 189, 0)
    BattleBar_HP_D[0] = Color.new(189, 0, 0)
    # Text color (inside)
    BattleBar_Text_IN = Color.new(255, 255, 255)
    # Text color (stroke)
    BattleBar_Text_OUT = Color.new(33, 33, 33)
    # Old constant that listed all the possible Text in color
    Text_In = Object.new
    # Return the number of Text in color
    # @return [Integer]
    def Text_In.size
      return 20
    end
    # White background shadow definition
    sh_color = Color.new(208, 208, 200)
    cnt_color = BattleBar_Text_OUT
    9.times do |i|
      Fonts.define_shadow_color(i, sh_color)
      Fonts.define_outline_color(i, cnt_color)
    end
    # Dark background shadow definition
    sh_color = Color.new(96, 96, 96)
    10.upto(18) do |i|
      Fonts.define_shadow_color(i, sh_color)
      Fonts.define_outline_color(i, cnt_color)
    end
    # White background front color definition
    # (default, blue, red, green, cyan, purple, yellow, gray, white, pure-white)
    Fonts.define_fill_color(0, Color.new(16, 24, 33))
    Fonts.define_fill_color(1, Color.new(48, 80, 200))
    Fonts.define_fill_color(2, Color.new(224, 8, 8))
    Fonts.define_fill_color(3, Color.new(48, 200, 80))
    Fonts.define_fill_color(4, Color.new(80, 184, 184))
    Fonts.define_fill_color(5, Color.new(184, 80, 184))
    Fonts.define_fill_color(6, Color.new(232, 216, 0))
    Fonts.define_fill_color(7, Color.new(96, 96, 96))
    Fonts.define_fill_color(8, Color.new(248, 248, 248))
    Fonts.define_fill_color(9, BattleBar_Text_IN)
    Fonts.define_shadow_color(9, BattleBar_Text_OUT)
    Fonts.define_outline_color(9, BattleBar_Text_OUT)
    # Dark background front color definition
    # (default, blue, red, green, cyan, purple, yellow, gray, white, pure-white)
    Fonts.define_fill_color(10, BattleBar_Text_IN)
    Fonts.define_fill_color(11, Color.new(148, 180, 240))
    Fonts.define_fill_color(12, Color.new(220, 109, 109))
    Fonts.define_fill_color(13, Color.new(109, 220, 32))
    Fonts.define_fill_color(14, Color.new(116, 199, 199))
    Fonts.define_fill_color(15, Color.new(199, 166, 199))
    Fonts.define_fill_color(16, Color.new(232, 216, 0))
    Fonts.define_fill_color(17, Color.new(208, 208, 200))
    Fonts.define_fill_color(18, Color.new(248, 248, 248))
    Fonts.define_fill_color(19, BattleBar_Text_OUT)
    Fonts.define_shadow_color(19, BattleBar_Text_IN)
    Fonts.define_outline_color(19, BattleBar_Text_IN)
    # PowerGreenSmall color definition
    Fonts.define_fill_color(20, Color.new(255, 255, 255))
    Fonts.define_shadow_color(20, Color.new(16, 32, 88))
    Fonts.define_outline_color(20, cnt_color)
    Fonts.define_fill_color(21, Color.new(255, 255, 255))
    Fonts.define_shadow_color(21, Color.new(79, 17, 41))
    Fonts.define_outline_color(21, cnt_color)
    # Nature color definition (best)
    sh_color = Color.new(208, 208, 200)
    Fonts.define_fill_color(22, Color.new(110, 27, 27))
    Fonts.define_shadow_color(22, sh_color)
    Fonts.define_outline_color(22, cnt_color)
    # Nature color definition (worst)
    Fonts.define_fill_color(23, Color.new(27, 27, 110))
    Fonts.define_shadow_color(23, sh_color)
    Fonts.define_outline_color(23, cnt_color)

    # Poison flash color
    PSN = Color.new(123, 55, 123, 128)
    # Transparent color
    Transparent = Color.new(0, 0, 0, 0)
  end
end
