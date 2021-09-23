#encoding: utf-8

module GamePlay
  # Helper that allow sprites to be dragged
  # @note Draggable stuff should respond to simple_mouse_in? and set_position
  class DragSprite
    # Return the sprite that is being dragged
    # @return [#simple_mouse_in?]
    attr_reader :dragging
    # Create the DragSprite interface
    def initialize
      @dragging = nil
      @last_x = 0
      @last_y = 0
      @sprites_to_drag = {}
    end
    # Update the draging process
    def update
      if sprite = @dragging
        return end_drag(sprite) unless Mouse.press?(:left)
        update_drag(sprite)
      else
        return unless Mouse.trigger?(:left)
        proc_to_call = nil
        @sprites_to_drag.each do |sprite, procs|
          if sprite.simple_mouse_in? #> Start draging if mouse inside sprite
            next if @dragging and @dragging.z >= sprite.z
            proc_to_call = procs[:start_drag]
            #> Save the sprite
            @dragging = sprite
          end
        end
        if @dragging
          proc_to_call.call(@dragging) if proc_to_call
          #> Save the @last_x and @last_y
          @last_x = Mouse.x
          @last_y = Mouse.y
        end
      end
    end
    # Add a sprite to drag
    # @param sprite [#simple_mouse_in?] The sprite to drag
    # @param start_drag [Proc(sprite)] the proc to call when the sprite start being dragged
    # @param update_drag [Proc(sprite)] the proc to call when the sprite is being dragged
    # @param end_drag [Proc(sprite)] the proc to call when the sprite stop being dragged
    def add(sprite, start_drag: nil, update_drag: nil, end_drag: nil)
      @sprites_to_drag[sprite] = {start_drag: start_drag, update_drag: update_drag, end_drag: end_drag}
    end
    private
    # End the drag process
    # @param sprite [#simple_mouse_in?]
    def end_drag(sprite)
      @dragging = nil
      return unless procs = @sprites_to_drag[sprite]
      if proc_to_call = procs[:end_drag]
        proc_to_call.call(sprite)
      end
    end
    # Update the drag process of a sprite
    # @param sprite [#set_position]
    def update_drag(sprite)
      return @dragging = nil unless procs = @sprites_to_drag[sprite]
      mx = Mouse.x
      my = Mouse.y
      mx = mx < 0 ? 0 : (mx >= Graphics.width ? Graphics.width-1 : mx)
      my = my < 0 ? 0 : (my >= Graphics.height ? Graphics.height-1 : my)
      dx = mx - @last_x
      dy = my - @last_y
      @last_x = mx
      @last_y = my
      return if dx == 0 and dy == 0
      sprite.set_position(sprite.x + dx, sprite.y + dy)
      if proc_to_call = procs[:update_drag]
        proc_to_call.call(sprite)
      end
    end
  end
end
