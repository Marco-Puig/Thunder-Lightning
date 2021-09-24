module Battle
  class Scene
    # Register an event for the battle
    # @param name [Symbol] name of the event
    # @param block [Proc] code of the event
    def register_event(name, &block)
      @battle_events[name] = block
      log_debug("Battle event #{name} registered")
    end

    private

    # Call a named event to let the Maker put some personnal configuration of the battle
    # @param name [Symbol] name of the event
    # @param *args [Array] arguments of the event if any
    def call_event(name, *args)
      return unless (event = @battle_events[name]) && event.is_a?(Proc)
      log_debug("Calling #{name} battle event.")
      event.call(*args)
    end

    # Load the battle event
    # @note events are stored inside Data/Events/Battle/{id} name.rb (if not compiled)
    #   or inside Data/Events/Battle/{id}.yarb (if compiled) is a 5 digit number (zero padding at the begining)
    # @param id [Integer] id of the battle
    def load_events(id)
      return if id < 0
      id = format('%05d', id)
      PSDK_CONFIG.release? ? load_ruby_events(id) : load_yarb_events(id)
    end

    if PSDK_CONFIG.release?
      # Load the events from a YARB file
      # @param id [String] the id of the event (00051 for 51)
      def load_yarb_events(id)
        filename = "Data/Events/Battle/#{id}.yarb"
        return unless File.exist?(filename)
        RubyVM::InstructionSequence.load_from_binary(File.binread(filename)).eval
      end
    else
      # Load the events from a ruby file
      # @param id [String] the id of the event (00051 for 51)
      def load_ruby_events(id)
        filename = Dir["Data/Events/Battle/#{id} *.rb"].first
        return unless filename && File.exist?(filename)
        log_debug("Load battle events from #{filename}")
        eval(File.read(filename))
      end
    end
  end
end
