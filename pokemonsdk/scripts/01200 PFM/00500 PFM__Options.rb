#encoding: utf-8

module PFM
  # The options data
  # 
  # The options are stored in $options and $pokemon_party.options
  # @author Nuri Yuri
  class Options
    # The volume of the BGM and ME
    # @return [Integer]
    attr_accessor :music_volume
    # The volume of the BGS and SE
    # @return [Integer]
    attr_accessor :sfx_volume
    # The audio library to use to play sound
    # @return [Symbol]
    attr_accessor :audio_lib
    # The input method to use to get inputs
    # @return [Symbol]
    attr_accessor :input_method
    # The list of virtual_key associated to in game inputs
    # @return [Array<Array<Integer>>]
    attr_accessor :personnal_inputs
    # The speed of the message display
    # @return [Integer]
    attr_accessor :message_speed
    # If the battle ask to switch pokemon or not
    # @return [Boolean]
    attr_accessor :battle_mode
    # If the battle show move animations
    # @return [Boolean]
    attr_accessor :show_animation
    # If the game pause when the window focus is lost
    # @return [Boolean]
    attr_accessor :pause_on_focus_loose
    # The lang id of the GameData::Text loads
    # @return [String]
    attr_accessor :language
    # Create a new Option object with a language
    # @param starting_language [String] the lang id the game will start
    def initialize(starting_language)
      @music_volume = 100
      @sfx_volume = 100
      @audio_lib = :FmodEx
      @input_method = :Windows
      @personnal_inputs = [[],[],[],[]]
      @message_speed = 3
      @battle_mode = true
      @show_animation = true
      @pause_on_focus_loose = true  
      @language = starting_language
    end
    # Change the game zoom
    # @param v [Integer] the new game zoom
    def set_zoom(v)
      if(v>0 and v <= 2)
#        $zoom_factor=v
#        Graphics.set_zoom_factor(v)
#        Kernel.set_int("PokemonSDK","Zoom",v)
      end
    end
    # Change the master volume
    # @param v [Integer] the new master volume
    def set_volume(v)
      if(v >= 0 and v <= 100)
        @music_volume = Audio.music_volume = v
#        Kernel.set_int("PokemonSDK", "Volume", v)
      end
    end
    # Change the SFX volume
    # @param v [Integer] the new sfx volume
    def set_sfx_volume(v)
      if(v >= 0 and v <= 100)
        @sfx_volume = Audio.sfx_volume = v
#        Kernel.set_int("PokemonSDK", "SFX", v)
      end
    end
    # Change the audio library
    # @param v [Symbol] the new audio lib to use
    def set_audio_lib(v)
      @audio_lib = v    
      #Audio.
    end    
    # Change the in game lang (reload the texts)
    # @param v [String] the new lang id
    def set_language(v)
      @language = v
#      Kernel.set_string("PokemonSDK","LANG", v)    
      GameData::Text.load
    end  
    # Change the message speed
    # @param v [Integer] the new message speed
    def set_message_speed(v)
      @message_speed = v
    end  
    # Change the battle mode
    # @param v [Boolean] if the battle ask to switch Pokemon
    def set_battle_mode(v)
      @battle_mode = v
    end
    # Change the show animation flag
    # @param v [Boolean] the new flag
    def set_show_animation(v)
      @show_animation = v
    end
    # Change the pause on focus loose flag
    # @param v [Boolean]
    def set_pause_on_focus_loose(v)
      @pause_on_focus_loose = v
    end    
  end
end
