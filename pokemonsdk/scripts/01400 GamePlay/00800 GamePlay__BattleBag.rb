#encoding: utf-8

#noyard
module GamePlay
  class Battle_Bag < Bag
    #===
    #>Initialisation du sac
    #===
    def initialize(team)
      super(:battle)
      @team=team
    end
    #===
    #>Mise à jour de la scène
    #===
    def update
      @message_window.update if @message_window
      if(Input.repeat?(:UP))
        @index-=1
        @index=@item_ids.size if @index<0
        return _draw_stuff
      elsif(Input.repeat?(:DOWN))
        @index+=1
        @index=0 if @index>@item_ids.size
        return _draw_stuff
      elsif(Input.repeat?(:RIGHT) and !@moving)
        index=Battle_Socket.index(@socket)
        @socket=Battle_Socket[index+1]
        @socket=Battle_Socket[0] unless @socket
        @item_ids=$bag.get_order(@socket)
        @item_names.clear
        @item_names=_item_name_list_gen
        _bag_src_rect_gen
        @index=0
        return _draw_stuff
      elsif(Input.repeat?(:LEFT) and !@moving)
        index=Battle_Socket.index(@socket)
        @socket=Battle_Socket[index-1]
        @item_ids=$bag.get_order(@socket)
        @item_names.clear
        @item_names=_item_name_list_gen
        _bag_src_rect_gen
        @index=0
        return _draw_stuff
      end
      if(Input.trigger?(:B))
        @return_data=-1
        return _close_bag
      elsif(Input.trigger?(:A))
        $game_system.se_play($data_system.decision_se)
        if(@index==@item_ids.size)
          @return_data=-1
          return _close_bag
        else
          return _action_on_item
        end
      end
    end

    #===
    #>Quand on utilise un objet
    #===
    def _action_on_item
      @return_data=@item_ids[@index]
      if(@moving)
        #>Si get_order change, il faut changer ce code !
        origin=@item_ids.index(@moving)
        @item_ids[origin]=nil
        @item_ids.insert(@index,@moving)
        @item_ids.compact!
        @selector.color=Color.new(0,0,0,0)
        @item_names.clear
        @item_names=_item_name_list_gen
        _draw_stuff
        @moving=false
        return
      end
      choix=_bag_window(USE,MOVE,SORT_ALPHA,SORT_ID)
      if(choix==0)
        return _use_item
      elsif(choix==1)
        @moving=@return_data
        @selector.color=Color.new(0,160,0,255)
        return
      elsif(choix==2)
        $bag.sort_alpha(@socket)
        @item_names.clear
        @item_names=_item_name_list_gen
        return _draw_stuff
      elsif(choix==3)
        $bag.reset_order(@socket)
        @item_names.clear
        @item_names=_item_name_list_gen
        return _draw_stuff
      end
    end
    #===
    #>Quand on ferme le sac
    #===
    def _close_bag
      @running = false
    end
    #===
    #>Fenêtre d'action du sac
    #===
    def _bag_window(*args)
      window=Window_Choice.new(105,args+[text_get(22,7)])
      window.z=@viewport.z+1
      window.x=213
      window.y=238-window.height
      item_id=@item_ids[@index]
      disabled=[]
      use = text_get(22,0)
      args.each_index do |i|
        cmd=args[i]
        if((cmd==use and !GameData::Item.battle_usable?(item_id)))
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
        elsif(Input.trigger?(:B))
          window.index=args.size
          break
        end
      end
      index=window.index
      window.dispose
      return index
    end
  end
end
