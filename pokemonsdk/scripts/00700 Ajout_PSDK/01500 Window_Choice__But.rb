#encoding: utf-8

class Window_Choice
  # Display a Choice "Window" but showing buttons instead of the common window
  class But < Window_Choice
    # Window Builder of this kind of choice window
    WindowBuilder = [0, 0, 0, 0, 0, 0]
    # Overwrite the windowskin setter
    # @param v [LiteRGSS::Bitmap] ignored
    def windowskin=(v)
      @cursor_rect.x += 2
      self.window_builder = WindowBuilder
      super(RPG::Cache.interface("team/But_Choice"))
    end
    # Overwrite the drawing function of Game_Window to produce the expected result
    def yuri_draw_blt_window
      sbmp=@windowskin
      bmp=@window.bitmap
      rect = sbmp.rect
      (bmp.height / (h = sbmp.height)).times do |i|
        bmp.blt(0, h * i, sbmp, rect)
      end
    end
  end
end
