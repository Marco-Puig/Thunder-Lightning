module UI
  class List
    class ListItem < SpriteStack
      # Class that handle an simple text item
      # @author Leikt
      class SimpleText < ListItem
        # Default item height
        # @return [Integer]
        DEFAULT_HEIGHT = 20

        # Default item width
        # @return [Integer]
        DEFAULT_WIDTH = 20

        # Intialize the item
        # @param viewport [Viewport] the viewport to display
        # @param params [Hash] the item generation parameters
        def initialize(viewport, params)
          super(viewport, params)
          @main = add_text 5, 1, @width - 5, @height - 1, ''
        end

        # Change the text value
        # @param value [String] the new value
        def data=(value)
          @main.text = value.to_s
        end
      end

      # Class that handle an vertical list item display with item count
      # @author Leikt
      class LineItem < ListItem
        # Default item height
        # @return [Integer]
        DEFAULT_HEIGHT = 25

        # Default item width
        # @return [Integer]
        DEFAULT_WIDTH = 100

        # Initialize the item
        # @param viewport [Viewport] the viewport to display
        # @param params [Hash] the item generation parameters
        def initialize(viewport, params)
          super(viewport, params)
          @icon = push 0, -2, '', type: ItemSprite
          @text = add_text(32, 0, @width - 32, @height, '')
          @count = add_text(@width - 5 - 20, 0, 0, @height, '', 2)
        end

        # Change the item icon value
        # @param value [Array<Integer, Integer>] Array [item_id, count]
        def data=(values)
          if values && (id = values[0])
            @icon.visible = true
            @icon.data = id
            if id > 0
              # Display item name and count
              @text.text = generate_name(id)
              @count.text = "x#{values[1]}"
            else
              # Display 'return' button
              @text.text = text_get(22, 7)
              @count.text = ''
            end
          else
            # Do not sho anything
            @icon.visible = false
            @text.text = ''
            @count.text = ''
          end
        end

        # Decorate the name of the item if it's a CT / CS
        # @param id [Integer] the item id
        # @return [String]
        def generate_name(id)
          base = GameData::Item.name(id)
          if (data = GameData::Item.misc_data(id)) && (data&.ct_id || data&.cs_id)
            return base + format(' - %<skill>s', skill: GameData::Skill.name(data.skill_learn.to_i))
          end

          return base
        end
      end

      # Class that handle an horizontal list pokemon icon display
      # @author Leikt
      class ColumnPokemonIcon < ListItem
        # Default item height
        # @return [Integer]
        DEFAULT_HEIGHT = 32

        # Default item width
        # @return [Integer]
        DEFAULT_WIDTH = 32

        # Initialize the item
        # @param viewport [Viewport] the viewport to display
        # @param params [Hash] the item generation parameters
        def initialize(viewport, params)
          super(viewport, params)
          @icon = push @width / 2, @height / 2, '', type: PokemonIconSprite
        end

        # Change the item icon value
        # @param value [PFM::Pokemon] the pokemon to display
        def data=(value)
          @icon.data = value
        end
      end
    end
  end
end
