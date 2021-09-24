module Yuki
  # Module that contain all the Animation System relying on "Groups" (allowing dynamic animation)
  #
  # All the animation managed by this module work with equation described in "Real Time".
  # Each groups are linked, this way the Animator swicth between groups once a group has terminated its animation.
  #
  # Example :
  module Animation
    # Abstract class of an Animation Group
    class Group
      # @return [Animator] Animator used to fetch the data source
      attr_accessor :animator

      # Return the next group
      # @return [Group, nil]
      def next
        nil
      end

      # Update the animation in this group
      def update() end

      # If the animation is done
      # @return [Boolean]
      def done?
        true
      end
    end

    # Parent class of SwitchGroup::Condition & SwitchGroup::Iteration
    class SwitchGroup < Group
      # Create a new Switch Group
      # @param data_source [Symbol] symbol used to fetch the data source for the SwitchGroup
      def initialize(data_source)
        @data_source = data_source
      end

      # Group performing a condition (true / false) and allowing to switch between two groups
      #
      # How to use it :
      # ```ruby
      #   my_condition = SwitchGroup::Condition.new(:my_source)
      #   my_condition.gtrue = group_if_my_source_is_true
      #   my_condition.gfalse = group_if_my_source_is_false
      # ```
      class Condition < SwitchGroup
        # @return [AnimationGroup] group executed if the source is true
        attr_accessor :gtrue
        # @return [AnimationGroup] group executed if the source is false
        attr_accessor :gfalse
        # Return the next group
        # @return [AnimationGroup, nil]
        def next
          return @gfalse unless @animator
          source = animator.data_sources[@data_source]
          source = source.call if source.is_a?(Proc)
          return source ? @gtrue : @gfalse
        end
      end

      # Group performing an iterative loop
      #
      # How to use it :
      # ```ruby
      #   my_loop = SwitchGroup::Iteration.new(:my_source, 0, 5)
      #   my_loop.gvalid = group_if_iteration_continues
      #   my_loop.gend = group_if_iteration_stops
      #   my_loop.end = Float::Infinity # We change the end of the iteration from 5 to infinity
      # ```
      # With this script `my_loop` will loop until data_source.call(i) returns false.
      # The loop can also end if data_source is an interger that is lower than `end`.
      # If we didn't changed `end` it would have do 5 iterations
      class Iteration < SwitchGroup
        # @return [Integer] begin of the loop
        attr_accessor :begin
        # @return [Integer] end of the loop
        attr_accessor :end
        # @return [AnimationGroup] group executed if the iteration continues
        attr_accessor :gvalid
        # @return [AnimationGroup] group executed if the iteration stops
        attr_accessor :gend
        # Create a new Iteration Group
        # @param data_source [Symbol] symbol used to fetch the data source for the SwitchGroup
        # @param begin_range [Integer] begin of the iteration
        # @param end_range [Numeric] end of the iteration
        def initialize(data_source, begin_range = 0, end_range = Float::INFINITY)
          super(data_source)
          @begin = begin_range
          @end = end_range
        end

        # Return the next group
        # @return [AnimationGroup, nil]
        def next
          return @gend unless @animator
          @counter ||= @begin
          source = animator.data_sources[@data_source]
          source = source.call(@counter) if source.is_a?(Proc)
          return @gend if source == false
          return @gend if source <= @counter
          return @gend if @end <= @counter
          @counter += 1
          return @gvalid
        end
      end
    end
  end
end
