module RPG
  # Script that cache bitmaps when they are reusable.
  # @author Nuri Yuri
  module Cache
    # Array of load methods to call when the game starts
    LOADS = []
    # Common filename of the image to load
    Common_filename = 'Graphics/%s/%s'
    # Common filename with .png
    Common_filename_format = format('%s.png', Common_filename)
    # Notification message when an image couldn't be loaded properly
    Notification_title = 'Failed to load graphic'
    # Size of array description with 8bit encoded bitmaps
    Sizeof_8bit_bitmap_data = 5

    module_function

    # Gets the default bitmap
    # @note Should be used in scripts that require a bitmap be doesn't perform anything on the bitmap
    def default_bitmap
      @default_bitmap = Bitmap.new(16, 16) if @default_bitmap && @default_bitmap.disposed?
      @default_bitmap
    end

    # Dispose every bitmap of a cache table
    # @param cache_tab [Hash{String => Bitmap}] cache table where bitmaps should be disposed
    def dispose_bitmaps_from_cache_tab(cache_tab)
      cache_tab.each_value { |bitmap| bitmap.dispose if bitmap && !bitmap.disposed? }
      cache_tab.clear
    end

    # Test if a file exist
    # @param filename [String] filename of the image
    # @param path [String] path of the image inside Graphics/
    # @param file_data [Yuki::VD] "virtual directory"
    # @return [Boolean] if the image exist or not
    def test_file_existence(filename, path, file_data = nil)
      return true if file_data && file_data.exists?(filename.downcase)
      return true if File.exist?(format(Common_filename_format, path, filename).downcase)
      false
    end

    # Loads an image (from cache, disk or virtual directory)
    # @param cache_tab [Hash{String => Bitmap}] cache table where bitmaps are being stored
    # @param filename [String] filename of the image
    # @param path [String] path of the image inside Graphics/
    # @param file_data [Yuki::VD] "virtual directory"
    # @return [Bitmap]
    # @note This function displays a desktop notification if the image is not found. The resultat bitmap is an empty 16x16 bitmap in this case.
    def load_image(cache_tab, filename, path, file_data = nil)
      complete_filename = format(Common_filename, path, filename).downcase
      return bitmap = Bitmap.new(16, 16) if File.directory?(complete_filename) || filename.empty?
      bitmap = cache_tab.fetch(filename, nil)
      if !bitmap || bitmap.disposed?
        bitmap = Bitmap.new(complete_filename) if File.exist?(complete_filename + '.png') || !file_data.exists?(filename.downcase)
        bitmap = load_image_from_file_data(filename, file_data) if (!bitmap || bitmap.disposed?) && file_data
        bitmap ||= Bitmap.new(16, 16)
      end
      return bitmap
    rescue StandardError
      log_error "#{Notification_title} #{complete_filename}"
      return bitmap = Bitmap.new("\x89PNG\r\n\x1A\n\x00\x00\x00\rIHDR\x00\x00\x00 \x00\x00\x00 \x02\x03\x00\x00\x00\x0E\x14\x92g\x00\x00\x00\tPLTE\x00\x00\x00\xFF\xFF\xFF\xFF\x00\x00\xCD^\xB7\x9C\x00\x00\x00>IDATx\x01\x85\xCF1\x0E\x00 \bCQ\x17\xEF\xE7\xD2\x85\xFB\xB1\xF4\x94&$Fm\a\xFE\xF4\x06B`x\x13\xD5z\xC0\xEA\a H \x04\x91\x02\xD2\x01E\x9E\xCD\x17\xD1\xC3/\xECg\xECSk\x03[\xAFg\x99\xE2\xED\xCFV\x00\x00\x00\x00IEND\xAEB`\x82", true)
    ensure
      cache_tab[filename] = bitmap
    end

    # Loads an image from virtual directory with the right encoding
    # @param filename [String] filename of the image
    # @param file_data [Yuki::VD] "virtual directory"
    # @return [Bitmap] the image loaded from the virtual directory
    def load_image_from_file_data(filename, file_data)
      bitmap_data = file_data.read_data(filename.downcase)
      if bitmap_data
        bitmap = Bitmap.new(bitmap_data, true)
=begin
        bitmap_data = ::Marshal.load(bitmap_data)
        if(bitmap_data.size == Sizeof_8bit_bitmap_data)
          bitmap = ::Bitmap.load_8bits(*bitmap_data)
        else
          bitmap = ::Bitmap.load_32bits(*bitmap_data)
        end
=end
      end
      bitmap
    end
    # Meta defintion of the cache loading without hue (shiny processing)
    Cache_meta_without_hue = <<-CACHE_META_PROGRAMMATION
      LOADS << :load_%<cache_name>s
      %<cache_constant>s_Path = '%<cache_path>s'
      module_function

      def load_%<cache_name>s(flush_it = false)
        unless flush_it
          @%<cache_name>s_cache = Hash.new
          @%<cache_name>s_data = Yuki::VD.new(PSDK_PATH + "/master/%<cache_name>s", :read)
        else
          dispose_bitmaps_from_cache_tab(@%<cache_name>s_cache)
        end
      end

      def %<cache_name>s_exist?(filename)
        test_file_existence(filename, %<cache_constant>s_Path, @%<cache_name>s_data)
      end

      def %<cache_name>s(filename, _hue = 0)
        load_image(@%<cache_name>s_cache, filename, %<cache_constant>s_Path, @%<cache_name>s_data)
      end

      def extract_%<cache_name>s(path = '')
        path += %<cache_constant>s_Path
        ori = Dir.pwd
        Dir.mkdir!(path.downcase)
        Dir.chdir(path.downcase)
        @%<cache_name>s_data.get_filenames.each do |filename|
          if filename.include?('/')
            dirname = File.dirname(filename)
            Dir.mkdir!(dirname) unless Dir.exist?(dirname)
          end
          was_cached = @%<cache_name>s_cache[filename] != nil
          bmp = %<cache_name>s(filename)
          bmp.to_png_file(filename + '.png')
          bmp.dispose unless was_cached
        end
      ensure
        Dir.chdir(ori)
      end
    CACHE_META_PROGRAMMATION
    # Meta definition of the cache loading with hue (shiny processing)
    Cache_meta_with_hue = <<-CACHE_META_PROGRAMMATION
      LOADS << :load_%<cache_name>s
      %<cache_constant>s_Path = [%<cache_path>s]
      module_function

      def load_%<cache_name>s(flush_it = false)
        unless flush_it
          @%<cache_name>s_cache = Array.new(%<cache_constant>s_Path.size) { Hash.new }
          @%<cache_name>s_data = [
            Yuki::VD.new(PSDK_PATH + "/master/%<cache_name>s", :read),
            Yuki::VD.new(PSDK_PATH + "/master/%<cache_name>s_s", :read)]
        else
          @%<cache_name>s_cache.each { |cache_tab| dispose_bitmaps_from_cache_tab(cache_tab) }
        end
      end

      def %<cache_name>s_exist?(filename, hue = 0)
        test_file_existence(filename, %<cache_constant>s_Path.fetch(hue), @%<cache_name>s_data[hue])
      end

      def %<cache_name>s(filename, hue = 0)
        load_image(@%<cache_name>s_cache.fetch(hue), filename, %<cache_constant>s_Path.fetch(hue), @%<cache_name>s_data[hue])
      end

      def extract_%<cache_name>s(path = '', hue = 0)
        path += %<cache_constant>s_Path[hue]
        ori = Dir.pwd
        Dir.mkdir!(path.downcase)
        Dir.chdir(path.downcase)
        @%<cache_name>s_data[hue].get_filenames.each do |filename|
          if filename.include?('/')
            dirname = File.dirname(filename)
            Dir.mkdir!(dirname) unless Dir.exist?(dirname)
          end
          was_cached = @%<cache_name>s_cache[hue][filename] != nil
          bmp = %<cache_name>s(filename, hue)
          bmp.to_png_file(filename + '.png')
          bmp.dispose unless was_cached
        end
      ensure
        Dir.chdir(ori)
      end
    CACHE_META_PROGRAMMATION
    # Execute a meta code generation (undef when done)
    def meta_exec(line, name, constant, path, meta_code = Cache_meta_without_hue)
      module_eval(
        format(
          meta_code,
          cache_name: name,
          cache_constant: constant,
          cache_path: path
        ),
        __FILE__,
        line
      )
    end
    # @!macro [attach] meta_exec
    #   Loads a bitmap from cache or Graphics/$4 directory
    #   @!method $2(filename, hue = 0)
    #   @param filename [String] name of the image in Graphics/$4
    #   @param hue [Integer] hue if the cache has hue (shiny processing)
    #   @return [Bitmap] the bitmap corresponding to the image
    meta_exec(__LINE__, 'animation', 'Animations', 'Animations')
    meta_exec(__LINE__, 'autotile', 'Autotiles', 'Autotiles')
    meta_exec(__LINE__, 'ball', 'Ball', 'Ball')
    meta_exec(__LINE__, 'battleback', 'BattleBacks', 'BattleBacks')
    meta_exec(__LINE__, 'battler', 'Battlers', 'Battlers')
    meta_exec(__LINE__, 'character', 'Characters', 'Characters')
    meta_exec(__LINE__, 'fog', 'Fogs', 'Fogs')
    meta_exec(__LINE__, 'icon', 'Icons', 'Icons')
    meta_exec(__LINE__, 'interface', 'Interface', 'Interface')
    meta_exec(__LINE__, 'panorama', 'Panoramas', 'Panoramas')
    meta_exec(__LINE__, 'particle', 'Particles', 'Particles')
    meta_exec(__LINE__, 'pc', 'PC', 'PC')
    meta_exec(__LINE__, 'picture', 'Pictures', 'Pictures')
    meta_exec(__LINE__, 'pokedex', 'Pokedex', 'Pokedex')
    meta_exec(__LINE__, 'title', 'Titles', 'Titles')
    meta_exec(__LINE__, 'tileset', 'Tilesets', 'Tilesets')
    meta_exec(__LINE__, 'transition', 'Transitions', 'Transitions')
    meta_exec(__LINE__, 'windowskin', 'Windowskins', 'Windowskins')
    meta_exec(__LINE__, 'foot_print', 'Pokedex_FootPrints', 'Pokedex/FootPrints')
    meta_exec(__LINE__, 'b_icon', 'Pokedex_PokeIcon', 'Pokedex/PokeIcon')

    meta_exec(
      __LINE__,
      'poke_front',
      'Pokedex_PokeFront',
      "'Pokedex/PokeFront', 'Pokedex/PokeFrontShiny'",
      Cache_meta_with_hue
    )
    meta_exec(
      __LINE__,
      'poke_back',
      'Pokedex_PokeBack',
      "'Pokedex/PokeBack', 'Pokedex/PokeBackShiny'",
      Cache_meta_with_hue
    )
  end
end
# Tells what to do on Start
Graphics.on_start do
  # puts 'Loading cache...'
  # t = Time.new
  RPG::Cache::LOADS.each do |k|
    RPG::Cache.send(k)
  end
  # puts format('Time to load cache : %<time>ss', time: (Time.new - t))
  RPG::Cache.instance_eval do
    undef meta_exec
    remove_const :Cache_meta_without_hue
    remove_const :Cache_meta_with_hue
  end
end
