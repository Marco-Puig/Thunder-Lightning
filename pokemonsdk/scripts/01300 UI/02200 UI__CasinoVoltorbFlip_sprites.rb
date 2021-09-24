module UI
  module VoltorbFlip
    # Object that show a text using a method of the data object sent
    class Texts < SpriteStack
      def initialize(viewport)
          super(viewport)
          @font_id = 20

          @title = add_text(0, 0, 320, 35, '', 1, color: 10)
          @title.bold = true
          @title.size = 22

          @coin_case = add_text(227, 172, 81, 24, '', 2, color: 7)
          @coin_case.bold = true
          @coin_case.size = 22

          @coin_gain = add_text(248, 203, 60, 24, '', 2, color: 7)
          @coin_gain.bold = true
          @coin_gain.size = 22

          @level = add_text(203, 203, 24, 24, '', color: 7)
          @level.bold = true
          @level.size = 22
      end

      def title=(value)
          @title.text = value.upcase
      end

      def coin_case=(value)
          @coin_case.text = "%07d" % value.to_i
      end

      def coin_gain=(value)
          @coin_gain.text = "%05d" % value.to_i
      end

      def level=(value)
        @level.text = ext_text(9000, 145) % value # "N#{value}"
      end
    end

    class Cursor < Sprite
      # The X coords on the board of the cursor
      # @return [Integer]
      attr_reader :board_x
      # The Y coords on the board of the cursor
      # @return [Integer]
      attr_reader :board_y
      # The cursor mode :normal, :memo
      # @return [Symbol]
      attr_reader :mode

      def initialize(viewport)
        super(viewport)
        set_bitmap('voltorbflip/markers', :interface)
        self.mode = :normal
        @move_count = false
        @board_x = 0
        @board_y = 0
        self.x, self.y = get_board_position(@board_x, @board_y)
      end

      # Update the cursor mouvement, return true if the mouvement has been updated
      # @return [Boolean]
      def update_move
        return false unless @move_count

        self.x = @move_data[0] + (@move_data[2] - @move_data[0]) * @move_count / ::GamePlay::Casino::VoltorbFlip::CursorMoveDuration
        self.y = @move_data[1] + (@move_data[3] - @move_data[1]) * @move_count / ::GamePlay::Casino::VoltorbFlip::CursorMoveDuration
        @move_count = false if (@move_count += 1) > ::GamePlay::Casino::VoltorbFlip::CursorMoveDuration
        return true
      end

      # Convert board coord in pixel coords
      def get_board_position(x, y)
        if y > 4 # Quit button
          return ::GamePlay::Casino::VoltorbFlip::QuitDispX,
                 ::GamePlay::Casino::VoltorbFlip::QuitDispY
        elsif x > 4 # Memo
          return  ::GamePlay::Casino::VoltorbFlip::MemoDispX,
                  ::GamePlay::Casino::VoltorbFlip::MemoDispY + y * ::GamePlay::Casino::VoltorbFlip::MemoTileSize
        else # Board
          return  ::GamePlay::Casino::VoltorbFlip::BoardDispX + x * ::GamePlay::Casino::VoltorbFlip::TileOffset,
                  ::GamePlay::Casino::VoltorbFlip::BoardDispY + y * ::GamePlay::Casino::VoltorbFlip::TileOffset
        end
      end

      # Start the cursor mouvement
      # @param dx [Integer] the number of case to move in x
      # @param dy [Integer] the number of case to move in y
      def move_on_board(dx, dy)
        # Update board coords
        if @board_y == 5 && dx != 0
          @board_x = (dx < 0 ? 4 : 5)
          @board_y = 4
        else
          @board_x += dx
          @board_y += dy
        end
        # Correct boundaries
        @board_x = 0 if @board_x < 0
        @board_y = 0 if @board_y < 0
        @board_x = 5 if @board_x > 5
        @board_y = 5 if @board_y > 5
        # Init mouvement
        @move_count = 0
        @move_data = [x, y, *get_board_position(@board_x, @board_y)]
      end

      def moveto(bx, by)
        self.x, self.y = get_board_position(@board_x = bx, @board_y = by)
      end

      def mode=(value)
        @mode = value
        if value == :memo
          set_rect_div(1, 0, 6, 1)
        else
          set_rect_div(0, 0, 6, 1)
        end
      end
    end

    class MemoTile < Sprite
      def initialize(viewport, index)
        super(viewport)
        @index = index
        set_bitmap('voltorbflip/memo_tiles', :interface)
        disable
      end

      def enabled?
        return src_rect.y > 0
      end

      def enable
        set_rect_div(@index, 1, 4, 2)
      end

      def disable
        set_rect_div(@index, 0, 4, 2)
      end
    end

    class BoardTile < SpriteStack
      attr_reader :content

      def initialize(viewport)
        super(viewport, default_cache: :interface)
        @tile_back = push(14, 14, 'voltorbflip/tiles')
        @tile_back.ox = 14
        @tile_back.oy = 14
        @tile_back.set_rect_div(0, 0, 5, 1)

        @tile_front = push(14, 14, 'voltorbflip/tiles')
        @tile_front.ox = 14
        @tile_front.oy = 14
        @tile_front.set_rect_div(0, 0, 5, 1)
        @tile_front.visible = false

        @markers = []
        4.times do |i|
          @markers.push((s = push(-3, -3, 'voltorbflip/markers')))
          s.set_rect_div(2 + i, 0, 6, 1)
          s.visible = false
        end
      end

      def simple_mouse_in?(mx, my)
        return @tile_back.simple_mouse_in?(mx + @tile_back.ox, my + @tile_back.oy)
      end

      def content=(value)
        @content = value
        @tile_front.set_rect_div(value == :voltorb ? 1 : value + 1, 0, 5, 1)
      end

      def toggle_memo(i)
        @markers[i].visible = !@markers[i].visible
      end

      def reveal
        return unless @tile_back.visible
        @animation = :reveal
        @animation_counter = 0
        @tile_back.visible = true
        @tile_front.visible = false
        @markers.each { |m| m.visible = false }
      end

      def revealed?
        return @tile_front.visible
      end

      def hide
        return unless @tile_front.visible
        @animation = :hide
        @animation_counter = 0
        @tile_back.visible = false
        @tile_front.visible = true
        @markers.each { |m| m.visible = false }
      end

      def hided?
        return @tile_back.visible
      end

      def update_animation
        case @animation
        when :reveal
          return update_reveal_animation

        when :hide
          return update_hide_animation
        end
        return false
      end

      def update_reveal_animation
        case @animation_counter
        when 0, 1, 2, 3, 4, 5, 6, 7
          @tile_back.zoom_x -= 1 / 8.0 #0.25
        when 8
          @tile_back.visible = false
          @tile_back.zoom_x = 1
          @tile_front.visible = true
          @tile_front.zoom_x = 0
        when 9, 10, 11, 12, 13, 14, 15
          @tile_front.zoom_x += 1 / 8.0
        when 16
          @tile_front.zoom_x = 1
          @animation_counter = 0
          @animation = nil
          return self
        end
        @animation_counter += 1
        return !@animation.nil?
      end

      def update_hide_animation
        case @animation_counter
        when 0, 1, 2, 3, 4, 5, 6, 7
          @tile_front.zoom_x -= 1 / 8.0 #0.25
        when 8
          @tile_front.visible = false
          @tile_front.zoom_x = 1
          @tile_back.visible = true
          @tile_back.zoom_x = 0
        when 9, 10, 11, 12, 13, 14, 15
          @tile_back.zoom_x += 1 / 8.0
        when 16
          @tile_back.zoom_x = 1
          @animation_counter = 0
          @animation = nil
          return self
        end
        @animation_counter += 1
        return !@animation.nil?
      end
    end

    class BoardCounter < SpriteStack
      def initialize(index, column, viewport)
        super(viewport, default_cache: :interface)
        @tiles = []
        if column
          cx = GamePlay::Casino::VoltorbFlip::ColumnCoinDispX + index * GamePlay::Casino::VoltorbFlip::TileOffset
          cy = GamePlay::Casino::VoltorbFlip::ColumnCoinDispY
        else
          cx = GamePlay::Casino::VoltorbFlip::RowCoinDispX
          cy = GamePlay::Casino::VoltorbFlip::RowCoinDispY + index * GamePlay::Casino::VoltorbFlip::TileOffset
        end 
        @coin_counter_1 = push(cx, cy, 'voltorbflip/numbers')
        @coin_counter_2 = push(cx + 7, cy, 'voltorbflip/numbers')
        @voltorb_counter = push(cx + 7, cy + 13, 'voltorbflip/numbers')
        @coin_counter_1.set_rect_div(0, 0, 10, 1)
        @coin_counter_2.set_rect_div(0, 0, 10, 1)
        @voltorb_counter.set_rect_div(0, 0, 10, 1)
      end

      def voltorb_count
        return @counter[0]
      end

      def add_tile(tile)
        @tiles.push tile
      end
      
      def update_display
        # Initialize
        counter = [0,0]
        # Count each tile content [voltorb, point]
        @tiles.each do |tile|
          if tile.content == :voltorb
            counter[0] += 1
          else
            counter[1] += tile.content
          end
        end

        # Display the numbers
        @coin_counter_1.set_rect_div(counter[1] / 10, 0, 10, 1)
        @coin_counter_2.set_rect_div(counter[1] - (counter[1] / 10) * 10, 0, 10, 1)
        @voltorb_counter.set_rect_div(counter[0], 0, 10, 1)
        @counter = counter
      end
    end

    class Animation < SpriteStack
      def initialize(viewport)
        super(viewport)
        @animation = nil
        @sprite = push(0, 0, '')
      end

      def animate(tile)
        if (@animation = tile.content) == :voltorb
          @sprite.set_bitmap('voltorbflip_explode', :animation)
          @sprite.set_rect_div(0, 0, 8, 1)
          @sprite.ox = 4
          @sprite.oy = 5
        else
          @sprite.set_bitmap('voltorbflip_number', :animation)
          @sprite.set_rect_div(0, 0, 4, 1)
          @sprite.ox = 1
          @sprite.oy = 2
        end
        @counter = 0
        @sprite.x = tile.x
        @sprite.y = tile.y
        @sprite.ox += @sprite.src_rect.width / 4
        @sprite.oy += @sprite.src_rect.height / 4
        @sprite.visible = true
      end
 
      def update_animation
        case @animation
        when :voltorb
          case @counter
          when 1
            $game_system.bgm_memorize
            $game_system.bgm_fade(0.5)
          when 12
            Audio.se_play('Audio/SE/voltorbflip/volt_boom', 120)
            @sprite.set_rect_div(@counter / 6, 0, 8, 1)
          when 6, 18, 24, 30, 36
            @sprite.set_rect_div(@counter / 6, 0, 8, 1)
          when 42
            @sprite.visible = false
            @animation = nil
          end
          @counter += 1
          return true

        when 1, 2, 3
          case @counter
          when 0
            Audio.se_play('Audio/SE/voltorbflip/volt_card_play', 120)
          when 6, 12, 18
            @sprite.set_rect_div(@counter / 6, 0, 4, 1)
          when 24
            @sprite.visible = false
            @animation = nil
          end
          @counter += 1
          return true
        end
        return false
      end
    end
  end
end
