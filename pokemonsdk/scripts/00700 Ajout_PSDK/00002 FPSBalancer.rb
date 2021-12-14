module Graphics
  # Class helping to balance FPS on FPS based things
  class FPSBalancer
    # Tell if the system tolerate 10% error in order to avoid unecessary skip
    TEN_TOLERANCE = true
    @globally_enabled = true
    @last_f3_up = Time.new - 10
    # Create a new FPSBalancer
    def initialize
      # Accumulator to help FPS balancing
      @delta_accumulator = 0
      # Tell the number of frame to execute
      @frame_to_execute = 0
    end

    # Update the metrics of the FPSBalancer
    def update
      expected_delta = (1.0 / Graphics.frame_rate)
      delta = Graphics.delta
      delta = expected_delta if TEN_TOLERANCE && (delta / expected_delta) <= 0.1
      @delta_accumulator += delta
      @frame_to_execute = (real_frame_to_execute = (@delta_accumulator / expected_delta).floor).clamp(0, 10)
      @delta_accumulator -= (real_frame_to_execute * expected_delta)
      if Sf::Keyboard.press?(Sf::Keyboard::F3)
        FPSBalancer.last_f3_up = Graphics.current_time
      elsif FPSBalancer.last_f3_up == Graphics.last_time
        FPSBalancer.globally_enabled = !FPSBalancer.globally_enabled
        FPSBalancer.last_f3_up -= 1
      end
    end

    # Run code according to FPS Balancing (block will be executed only if it's ok)
    # @param block [Proc] code to execute as much as needed
    def run(&block)
      return unless block_given?
      return block.call unless FPSBalancer.globally_enabled

      @frame_to_execute.times(&block)
    end

    # Tell if the balancer is skipping frames
    def skipping?
      FPSBalancer.globally_enabled && @frame_to_execute == 0
    end

    class << self
      # Get if the FPS balancing is globally enabled
      # @return [Boolean]
      attr_accessor :globally_enabled
      # Get last time F3 was pressed
      # @return [Time]
      attr_accessor :last_f3_up
      # Get the global balancer
      # @return [FPSBalancer]
      attr_reader :global
    end

    module Marker
      # Function telling the object is supposed to be frame balanced
      def frame_balanced?
        return true
      end
    end

    @global = new
  end

  class << self
    alias original_update update
    # Update with fps balancing
    def update
      FPSBalancer.global.update
      if FPSBalancer.global.skipping? && !frozen? && $scene.is_a?(FPSBalancer::Marker)
        fps_update if respond_to?(:fps_update, true)
        update_no_input
        fps_gpu_update if respond_to?(:fps_gpu_update, true)
      else
        original_update
      end
    end
  end
end
