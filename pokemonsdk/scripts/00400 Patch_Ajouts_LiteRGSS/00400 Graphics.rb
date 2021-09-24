# Module that manage the general graphic display
module Graphics
  @update = method(:update)
  @stop = method(:stop)
  @start = method(:start)
  @freeze = method(:freeze)
  @transition = method(:transition)
  @on_start = []
  @last_scene = nil
  @fps_balancing = true

  module_function

  # Define a block that should be called when Graphics.start has been called
  # @param block [Proc] the block to call
  def on_start(&block)
    @on_start << block
  end

  # Start the Graphic module (show the Window and call some things)
  def start
    @start.call
    @on_start.each(&:call)
    @on_start.clear
    io_initialize
    frame_reset
    @no_mouse = (Config.const_defined?(:DisableMouse) and Config::DisableMouse and !PARGV[:tags])
    init_sprite
  end

  # Update the screen with the current frame state
  def update
    ::Scheduler.start(:on_update)
    if @last_scene != $scene
      sort_z
      @last_scene = $scene
    end
    # Internal update management
    update_manage
    unless @no_mouse
      Mouse.moved = (@mouse.x != Mouse.x || @mouse.y != Mouse.y)
      @mouse.x = Mouse.x
      @mouse.y = Mouse.y
    end
    Audio.update
    update_cmd_eval if @__cmd_to_eval
  rescue LiteRGSS::Error
    puts 'Graphics stopped but did not raised the `LiteRGSS::Graphics::ClosedWindowError` exception'
    raise LiteRGSS::Graphics::ClosedWindowError, 'Temporary fix'
  end

  # Stop the Graphic display
  def stop
    dispose_fps_text
    @mouse.dispose unless !@mouse || @mouse.disposed?
    @cmd_thread&.kill
    @stop.call
  rescue LiteRGSS::Graphics::StoppedError
    puts 'Graphics already stopped.'
  end

  # Make the Game wait n frames
  # @param n [Integer]
  # @yield [] a block performing action after each Graphics.update (optionnal)
  def wait(n)
    n.times do
      update
      yield if block_given?
    end
  end

  # Make the Graphics freeze
  def freeze
    @mouse.visible = false unless @no_mouse
    set_fps_color(1)
    wait(6)
    @freeze.call
  end

  # Perform a Transition
  # @param args [Array<Integer, LiteRGSS::Bitmap>] number of frame to perform the transition and the bitmap to use if needed
  def transition(*args)
    Scheduler.start(:on_transition)
    sort_z
    @transition.call(*args)
    set_fps_color(9)
    @mouse.visible = true unless @no_mouse
    @ruby_time = Time.new
  end

  # Init the Sprite used by the Graphics module
  def init_sprite
    return if @mouse && !@mouse.disposed?
    init_fps_text
    return if @no_mouse
    @mouse = Sprite.new
    @mouse.z = 200_001
    if Config.const_defined?(:MouseSkin) and RPG::Cache.windowskin_exist?(Config::MouseSkin)
      @mouse.bitmap = RPG::Cache.windowskin(Config::MouseSkin)
    else
      @mouse.bitmap = Bitmap.new(10, 10)
      @mouse.bitmap.fill_rect(0, 0, 5, 5, Color.new(0, 0, 0, 255))
      @mouse.bitmap.fill_rect(1, 1, 4, 4, Color.new(255, 255, 255, 255))
      @mouse.bitmap.update
    end
  end

  # Sort the Graphical element by their z coordinate (in the Graphic Stack)
  def sort_z
    @__elementtable.sort! do |a, b|
      s = a.z <=> b.z
      next(a.__index__ <=> b.__index__) if s == 0
      next(s)
    end
    reload_stack
  end

  # Eval a command from the console
  def update_cmd_eval
    cmd = @__cmd_to_eval
    @__cmd_to_eval = nil
    begin
      puts Object.instance_eval(cmd)
    rescue Exception
      print "\r"
      puts "#{$!.class} : #{$!.message}"
      puts $!.backtrace
    end
    @cmd_thread&.wakeup
  end

  # Initialize the IO related stuff of Graphics
  def io_initialize
    STDOUT.sync = true unless STDOUT.tty?
    return if $RELEASE
    @cmd_thread = create_command_thread
  rescue StandardError
    puts 'Failed to initialize IO related things'
  end

  # Create the Command thread
  def create_command_thread
    Thread.new do
      loop do
        log_info('Type help to get a list of the commands you can use.')
        print 'Commande : '
        @__cmd_to_eval = STDIN.gets.chomp
        sleep
      rescue StandardError
        @cmd_thread = nil
        @__cmd_to_eval = nil
        break
      end
    end
  end
end
