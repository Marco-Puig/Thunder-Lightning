module GamePlay
  class Bag < Base
    #> Inclusions
    include ::Util::Item
    #> Définition des Constantes
    Bag_Dir="Graphics/bag/"
    ESPACE=" "
    GIVE="Donner"
    USE="Utiliser"
    THROW="Jeter"
    SELECT="Selectionner"
    SELL="Vendre"
    CANCEL="Annuler"
    MOVE="Deplacer"
    SORT_ALPHA="Tri Alphabetique"
    SORT_ID="Tri par défauts"
    Socket_Names=[nil.to_s,"Objets","Pokéball","CT/CS","Baies","Objets Rare","Médicaments", "Cristaux Z", "Motism'Aura"]
    SOCKET_NAMES = [
      nil.to_s,
      [:text_get, 15, 0], # Items
      [:text_get, 12, 4], # Pokéball
      [:text_get, 15, 2], # CT / CS
      [:text_get, 15, 3], # Berries
      [:text_get, 15, 4], # Key Items
      [:text_get, 15, 1] # Medicine
    ]
    Bag_IMG=["bag","bag_girl"]
    LineJump="\n"
    Battle_Socket=[1,2,4,6]
    include Text::Util
    attr_accessor :return_data #ID de l'objet retourné
    #===
    #>Initialisation du sac
    #===
    def initialize(mode=:menu)
      super()
      @mode = mode
      @return_data = -1
      @moving = false
      _adjust_socket(mode)
      _calibrate_item_list
      @viewport = Viewport.create(:main, 10000)
      @background = Sprite.new(@viewport)
      @bag = Sprite.new(@viewport).set_bitmap(Bag_IMG[$trainer.playing_girl ? 1 : 0], :interface)
      @bag.set_position(80, 75)
      @bag.set_origin_div(2, 12) # sprite(Bag_IMG[$trainer.playing_girl ? 1 : 0], 80, 75, 1, ox_div: 2, oy_div: 12)
      _bag_src_rect_gen
      @icon = Sprite.new(@viewport).set_position(24, 124) # sprite(nil, 24, 124, 2)
      @selector = SpriteSheet.new(@viewport, 1, 2).set_bitmap('bag_selector', :interface) # sprite_sheet("Bag_selector", 154, 124, 2, 1, 2)
      @selector.set_position(154, 124)
      @texts = UI::SpriteStack.new(@viewport) # init_text(0, @viewport)
      @socket_text = @texts.add_text(26, 12, 113, 23, ' ', 1, 1, color: 9)
      @quantity_text = []
      @name_text = Array.new(11) do |cnt|
        @quantity_text << @texts.add_text(158, 29 + cnt * 16, 140, 16, ' ', 2, color: 18)
        @texts.add_text(158, 29 + cnt * 16, 140, 16, ' ', color: 18)
      end
      @descr_text = @texts.add_text(3, 153, 132, 16, ' ', color: 18)
    end

    def main_begin
      _draw_stuff
      super
    end

    def main_end
      super
      @item_names.clear
      @item_names = nil
      $bag.last_socket = @socket
      $bag.last_index = @index
    end

    def update
      return unless super
      if(repeat?(:UP))
        @index-=1
        @index=@item_ids.size if @index<0
        return _draw_stuff
      elsif(repeat?(:DOWN))
        @index+=1
        @index=0 if @index>@item_ids.size
        return _draw_stuff
      elsif(repeat?(:RIGHT) and @mode!=:berry and !@moving)
        @socket += 1
        @socket = 1 if @socket >= SOCKET_NAMES.size
        @item_ids=$bag.get_order(@socket)
        @item_names.clear
        @item_names=_item_name_list_gen
        _bag_src_rect_gen
        @index=0
        return _draw_stuff
      elsif(repeat?(:LEFT) and @mode!=:berry and !@moving)
        @socket-=1
        @socket = SOCKET_NAMES.size - 1 if @socket < 1
        @item_ids=$bag.get_order(@socket)
        @item_names.clear
        @item_names=_item_name_list_gen
        _bag_src_rect_gen
        @index=0
        return _draw_stuff
      end
      if(trigger?(:B))
        @return_data=-1
        return _close_bag
      elsif(trigger?(:A))
        $game_system.se_play($data_system.decision_se)
        if(@index==@item_ids.size)
          return if @moving
          @return_data=-1
          return _close_bag
        else
          return _action_on_item
        end
      end
    end

    def _action_on_item
      @return_data=@item_ids[@index]
      if(@moving)
        #>Si get_order change, il faut changer ce code !
        origin = @item_ids.index(@moving)
        @item_ids[origin]=nil
        @item_ids.insert(@index + ((@index-origin > 0) ? 1 : 0),@moving)
        @item_ids.compact!
        @selector.sy = 0#@selector.src_rect.y = 0 #@selector.color=Color.new(0,0,0,0)
        @item_names=_item_name_list_gen
        _draw_stuff
        @moving=false
        return
      end
      case @mode
      when :menu
        choix=_bag_window(text_get(22,0),text_get(22,3),text_get(22,177),text_get(22,81),text_get(22,84),text_get(22,1))
        if(choix==0)
          return _use_item
        elsif(choix==1)
          return _give_item
        elsif(choix==2)
          @moving=@return_data
          @selector.sy = 1#@selector.src_rect.y = @selector.src_rect.height#@selector.color=Color.new(0,160,0,255)
          return
        elsif(choix==3)
          $bag.sort_alpha(@socket)
          @item_names.clear
          @item_names=_item_name_list_gen
          return _draw_stuff
        elsif(choix==4)
          $bag.reset_order(@socket)
          @item_names.clear
          @item_names=_item_name_list_gen
          return _draw_stuff
        elsif(choix==5)
          return _throw_item
        end
      when :map,:berry
        return _close_bag if(_bag_window(text_get(22,0))==0)
      when :hold
        return _close_bag if(_bag_window(text_get(22,3))==0)
      when :shop
        if(_bag_window(text_get(11,1))==0)
          sell_item
        end
      end
    end
    #===
    #>Quand on ferme le sac
    #===
    def _close_bag
      case @mode
      when :menu #Ouverture depuis le menu
        @running = false#$scene=Scene_Map.new #Remplacer par le menu
      when :map,:berry, :shop #Ouverture depuis un évent
        return_to_scene(Scene_Map)#$scene=Scene_Map.new
      when :hold #Requette d'ouverture depuis l'équipe
        @running = false #$scene=nil
      end
    end
    #===
    #>Dessin de la scène
    #===

    def current_socket_name
      socket_name = SOCKET_NAMES[@socket]
      return socket_name if socket_name.is_a?(String)
      return send(*socket_name)
    end

    def _draw_stuff
      @socket_text.text = current_socket_name # Socket_Names[@socket]
      size = @item_ids.size
      #>Calibrage de l'index initial
      if(@index > 4)
        if(size > 10 and @index > (size - 5))
          ini_index = size - 10
        else
          ini_index = @index - 5
        end
      else
        ini_index = 0
      end
      cnt = -1
      ini_index.step(ini_index + 10) do |i|
        cnt += 1
        @selector.y = 28 + cnt*16 if(i == @index)
        @quantity_text[cnt].visible = false
        @name_text[cnt].visible = i <= size
        if i >= size
          @name_text[cnt].text = text_get(22, 7) if i == size
          next
        end
        @name_text[cnt].text = @item_names[i]
        if GameData::Item.limited_use?(@item_ids[i])
          @quantity_text[cnt].visible = true
          @quantity_text[cnt].text = $bag.item_quantity(@item_ids[i]).to_s
        end
      end
      @icon.bitmap = RPG::Cache.icon(GameData::Item.icon(@item_ids[@index].to_i))
      @icon.ox = @icon.bitmap.width / 2
      @icon.oy = @icon.bitmap.height / 2
      #>Dessin de la description
      return @descr_text.text = " " unless @item_ids[@index]
      @descr_text.multiline_text = GameData::Item.descr(@item_ids[@index])
    end
    #===
    #>Génération de la liste de nom d'items
    #===
    def _item_name_list_gen
      arr=Array.new(@item_ids.size)
      arr.size.times do |i|
        if(data=GameData::Item.misc_data(@item_ids[i]))
          if(data.ct_id)
            arr[i]=sprintf("CT%02d %s",data.ct_id,GameData::Skill.name(data.skill_learn.to_i))
          elsif(data.cs_id)
            arr[i]=sprintf("CS%02d %s",data.cs_id,GameData::Skill.name(data.skill_learn.to_i))
          else
            arr[i]=GameData::Item.name(@item_ids[i])
          end
        else
          arr[i]=GameData::Item.name(@item_ids[i])
        end
      end
      return arr
    end
    #===
    #> Correction de la socket en fonction des conditions
    #===
    def _adjust_socket(mode)
      if(mode==:battle)
        @socket = $bag.last_socket
        if(Battle_Socket.include?(@socket))
          @index = $bag.last_index
        else
          @socket = 1
          @index = 0
        end
      elsif(mode != :berry)
        @socket = $bag.last_socket
        @index = $bag.last_index
      else #Si on cherche à planter des baies, on bloque sur la poche 4
        @socket = 4
        @index = 0
      end
    end
    #===
    #>Génération du src_rect du sac
    #===
    def _bag_src_rect_gen
      @background.bitmap=RPG::Cache.interface("Bag_Background#{@socket}")
      height=@bag.bitmap.height/8 #8poches
      y=(@socket-1)*height
      @bag.src_rect.set(0,y,@bag.bitmap.width,height)
    end
    #===
    #>Fenêtre d'action du sac
    #===
    def _bag_window(*args)
      window=Window_Choice.new(105,args+[text_get(22,7)])
      window.z=@viewport.z+1
      window.x=213
      window.y=238-window.height
      Graphics.sort_z
      give = text_get(22,3)
      throw = text_get(22,1)
      use = text_get(22,0)
      item_id=@item_ids[@index]
      disabled=[]
      args.each_index do |i|
        cmd=args[i]
        if((cmd==give and !GameData::Item.holdable?(item_id)) or
           (cmd==throw and !GameData::Item.limited_use?(item_id)) or
           (cmd==use and (!GameData::Item.map_usable?(item_id) or 
           (@mode == :berry and !GameData::ItemMisc.berry(item_id)))))
          window.colors[i]=7
          disabled<<i
        end
      end
      window.refresh
      loop do
        Graphics.update
        window.update
        if window.validated?
          if(disabled.include?(window.index))
            $game_system.se_play($data_system.buzzer_se)
          else
            $game_system.se_play($data_system.decision_se)
            break
          end
        elsif(trigger?(:B))
          window.index=args.size
          break
        end
      end
      index=window.index
      window.dispose
      return index
    end
    #===
    #>Utilisation d'un objet
    #===
    def _use_item
      item_id = @item_ids[@index]
      extend_data = util_item_useitem(item_id)
      return extend_data unless extend_data
      _calibrate_item_list
      _draw_stuff
      return extend_data
    end
    #===
    #>Donner un objet
    #===
    def _give_item
      return if $pokemon_party.empty?
      call_scene(Party_Menu, $actors, :hold, @item_ids[@index])
      _calibrate_item_list
      _draw_stuff
    end
    #===
    #>Jeter un objet
    #===
    def _throw_item
      $game_temp.num_input_variable_id = ::Yuki::Var::EnteredNumber
      $game_temp.num_input_digits_max = $bag.item_quantity(@return_data).to_s.size
      $game_temp.num_input_start = $bag.item_quantity(@return_data)
      display_message(parse_text(22, 38, ::PFM::Text::ITEM2[0] => GameData::Item.name(@return_data)))
      value = $game_variables[::Yuki::Var::EnteredNumber]
      if(value > 0)
        _calibrate_item_list
        _draw_stuff
        display_message(parse_text(22, 39, ::PFM::Text::ITEM2[0] => GameData::Item.name(@return_data),
          ::PFM::Text::NUM3[1] => value.to_s))
        $bag.remove_item(@return_data, value)
      end
    end
    #===
    #> Vendre un objet
    #===
    def sell_item
      price = GameData::Item.price(@return_data) / 2
      if(price > 0)
        $game_temp.num_input_variable_id = ::Yuki::Var::EnteredNumber
        $game_temp.num_input_digits_max = $bag.item_quantity(@return_data).to_s.size
        $game_temp.num_input_start = $bag.item_quantity(@return_data)
        $game_temp.shop_calling = price
        display_message(parse_text(22,170, ITEM2[0] => ::GameData::Item.name(@return_data)))
        $game_temp.shop_calling = false
        value = $game_variables[::Yuki::Var::EnteredNumber]
        if(value > 0)
          c = display_message(parse_text(22,171, NUM7R => (value * price).to_s),
          1, text_get(11,27), text_get(11,28))
          return if(c != 0)
        else
          return
        end
        $bag.remove_item(@return_data, value)
        $pokemon_party.add_money(value * price)
        _calibrate_item_list
        _draw_stuff
        display_message(parse_text(22,172, NUM7R => (value * price).to_s))
      else
        ::PFM::Text.set_plural(false)
        display_message(parse_text(22,174, ITEM2[0] => ::GameData::Item.name(@return_data)))
      end
    end
    #===
    #>Calibration de la liste des objets
    #===
    def _calibrate_item_list
      @item_ids=$bag.get_order(@socket)
      @item_names=_item_name_list_gen
      @index=@item_ids.size if @index>@item_ids.size #Il y a l'option retour
    end
  end
end
