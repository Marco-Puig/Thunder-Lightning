#encoding: utf-8

#noyard
module GamePlay
  class Evolve < Base
    BackNames=["back_building","back_grass","back_tall_grass","back_taller_grass",
    "back_cave","back_mount","back_sand","back_pond","back_sea","back_under_water",
    "back_snow","back_ice"]
    EvolveMusic = "Audio/BGM/PkmRS-Evolving.mid"
    EvolvedMusic = "Audio/BGM/XY_Trainer_Battle_Victory.ogg"
    attr_accessor :evolved
    def initialize(pkmn, id, forced = false)
      super()
      @pokemon = pkmn
      @clone = pkmn.clone
      @clone.id = id
      @clone.form_calibrate(:evolve)
      #check_alola_evolve(@clone)
      @forced = forced
      #> Génération du Background
      @viewport = Viewport.create(:main, @message_window.z - 1)
      #> Background
      id_bg = $env.get_zone_type(true)
      if(id_bg == 0)
        id_bg = 1 if $env.grass?
      else
        id_bg += 1
      end
      @background = Sprite.new(@viewport).set_bitmap(BackNames[id_bg], :battleback) # background(BackNames[id_bg], :battleback)
      @sprite_pokemon = Sprite::WithColor.new(@viewport).set_bitmap(pkmn.battler_face)
      @sprite_pokemon.set_position(160, 120).set_origin_div(2, 2) # sprite(nil, 160, 120, 1, bitmap: pkmn.battler_face, 
      #  ox_div: 2, oy_div: 2)
      #> Sprite du Pokémon évolué
      @sprite_clone = Sprite::WithColor.new(@viewport).set_bitmap(@clone.battler_face)
      @sprite_clone.opacity = 0
      @sprite_clone.set_position(160, 120).set_origin_div(2, 2) # sprite(nil, 160, 120, 2, bitmap: @clone.battler_face, 
      @sprite_clone.set_color([1, 1, 1, 1])
      #  ox_div: 2, oy_div: 2, opacity: 0, tone: [255, 255, 255, 255])
      @evolved = false
      @counter = 0
      $game_system.bgm_memorize2
      Audio.bgm_stop
    end

    def update
      super()
      return if $game_temp.message_window_showing
      if @counter == 0
        Audio.bgm_play(EvolveMusic)
        @message_window.auto_skip = true
        @message_window.stay_visible = true
        display_message(parse_text(31, 0, ::PFM::Text::PKNICK[0] => @pokemon.given_name))
      elsif @counter >= LastStep
        @message_window.stay_visible = false
        Audio.bgm_play(EvolvedMusic)
        display_message(parse_text(31, 2, ::PFM::Text::PKNICK[0] => @pokemon.given_name,
        ::PFM::Text::PKNAME[1] => @clone.name))
        while $game_temp.message_window_showing
          @message_window.update
          Graphics.update
        end
        @pokemon.id = @clone.id
        @pokemon.form = @clone.form
        #check_alola_evolve(@pokemon)
        @pokemon.check_skill_and_learn(false, -1)
        #===
        #> Munja évolution de Ningale
        #===
        if @clone.id == 291 and $actors.size < 6 and $bag.has_item?(4)
          $actors << PFM::Pokemon.new(292)
          $bag.remove_item(4)
          $pokedex.mark_seen(292, forced: true)
          $pokedex.mark_captured(292)
        end
        Audio.bgm_stop
        $game_system.bgm_restore2
        @running = false
        @evolved = true
        $pokedex.mark_seen(@pokemon.id, @pokemon.form, forced: true)
        $pokedex.mark_captured(@pokemon.id)
      else
        if(@counter < SecondStep and (!@forced and Input.trigger?(:B)))
          release_animation
          @message_window.stay_visible = false
          display_message(parse_text(31, 1, ::PFM::Text::PKNICK[0] => @pokemon.given_name))
          @running = false
          $game_system.bgm_restore2
          return
        else
          update_animation
        end
      end
      @counter += 1
    end

    FirstStep = 60
    SecondStep = FirstStep + 420
    LastStep = SecondStep + 60
    PI2 = Math::PI*2
    def update_animation
      if @counter < FirstStep
        value = 255 * @counter / FirstStep
        @sprite_pokemon.set_color(Color.new(value, value, value, value))
        value /= 5
        @viewport.tone.set(value, value, value, 0)
      elsif @counter < SecondStep
        value = (Math.cos((@counter-FirstStep)*PI2/120)+1)*128
        @sprite_pokemon.opacity = value
        @sprite_clone.opacity = 255-value
      elsif @counter < LastStep
        value = (60 - (@counter - SecondStep)) * 255 / 60
        @viewport.tone.set(value, value, value, 0)
        @sprite_clone.set_color(Color.new(value, value, value, value))
      end
    end

    def release_animation
      @sprite_clone.opacity = 0
      @sprite_pokemon.opacity = 255
      @sprite_pokemon.set_color([0, 0, 0, 0])
      @viewport.tone.set(0, 0, 0, 0)
    end
  end
end
