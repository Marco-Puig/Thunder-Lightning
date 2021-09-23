module UI
  class List
    # Class that handle the list items, sprite and texts
    # @author Leikt
    class ListItem < SpriteStack
      # Initialize the list item
      # @param viewport [Viewport] the viewport to display
      # @param params [Hash] the item generation parameters
      def initialize(viewport, params)
        super(viewport)
        @width = self.class.retrieve_width(params)
        @height = self.class.retrieve_height(params)
        @modifier = params[:modifier]
      end

      # Retrieve item width from the given param
      # @param param [Hash] the param of the item for the list
      # @author Leikt
      def self.retrieve_width(param)
        return param.fetch(:width,
                           param[:list_direction] == :horizontal ?
                           self::DEFAULT_WIDTH :
                           param.fetch(:list_width, self::DEFAULT_WIDTH))
      end

      # Retrieve item height from the given param
      # @param param [Hash] the param of the item for the list
      # @author Leikt
      def self.retrieve_height(param)
        return param.fetch(:height,
                           param[:list_direction] == :vertical ?
                           self::DEFAULT_HEIGHT :
                           param.fetch(:list_height, self::DEFAULT_HEIGHT))
      end

      # Test if the mouse is in the item
      # @param mouse_x [Integer] the mouse x screen coord
      # @param mouse_y [Integer] the mouse y screen coord
      # @return [Boolean]
      # @author Leikt
      def simple_mouse_in?(mouse_x = Mouse.x, mouse_y = Mouse.y)
        coords = @viewport.translate_mouse_coords(mouse_x, mouse_y)
        return coords[0].between?(@x, @x + @width) &&
               coords[1].between?(@y, @y + @height)
      end

      # Use the proc to modify the x and y value
      def call_modifier(hash)
        @modifier&.call(self, hash)
      end
    end
  end
end
