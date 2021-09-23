#encoding: utf-8

#noyard
module GamePlay
  class Menu_Item
    STRINGS=["Pokédex","Pokémon","Sac",nil,"Sauvegarder","Options","Quitter"]
    ALIAS_IDS=[1,0,2,3,4,5,6]
    Button="Menu_button"
    Icons="Menu_icons"
    TNAME="[VAR TRNAME(0000)]"
    Select_offset=6
    def initialize(viewport,id,enabled)
      @sprite=Sprite.new(viewport)
      @sprite.bitmap=RPG::Cache.interface(Button)
      eax=@sprite.bitmap.height+1
      @sprite.y=(240-(eax*STRINGS.size))/2 + eax*id
      @sprite.z=1
      @icon=Sprite.new(viewport)
      @icon.y=@sprite.y
      @icon.bitmap=RPG::Cache.interface(Icons)
      @icon.z=2
      eax=@icon.bitmap.height/(STRINGS.size+1)
      @id=(id==2 ? ($trainer.playing_girl ? 7 : 2) : id)
      #>Correction pour afficher dans l'ordre de GF
      #!!CHANGER LA RESSOURCE GRAPHIQUE !
      if(@id==4)
        @id=5
      elsif(@id==5)
        @id=4
      end
      @icon.src_rect.set(0, @id*eax, @icon.bitmap.width/2, eax)

      id = ALIAS_IDS[id]
      #>Récupération du texte du menu en fonction de la langue
      if(id !=6)
        text = text_get(14,id).gsub(TNAME, $trainer.name)
      else
        text = ext_text(9000, 26)
      end
      @text = Text.new(0, viewport, 320, @sprite.y - 2, 
        @sprite.bitmap.width-48, @sprite.bitmap.height, text).load_color(enabled ? 0 : 7)
      @text.z = 3
      @disposed=false
      @selected=false
      self.x=320
    end

    def x=(v)
      return if @disposed
      v-=Select_offset if @selected
      @sprite.x=v
      @icon.x=v+14
      @text.x=v+46
    end

    def x
      return 0 if @disposed
      return @sprite.x+Select_offset if @selected
      return @sprite.x
    end

    def set_selected_state(v)
      return if @disposed
      x=self.x
      @selected=v
      self.x=x
      eax=@icon.bitmap.height/(STRINGS.size+1)
      ebx=@icon.bitmap.width/2
      @icon.src_rect.set(v ? ebx : 0, @id*eax, ebx , eax)
    end

    def disposed?
      return @disposed
    end

    def width
      return @sprite.bitmap.width
    end

    def simple_mouse_in?
      @sprite.simple_mouse_in?
    end

    def dispose
      return if @disposed
      @text.dispose
      @icon.dispose
      @sprite.dispose
      @disposed=true
    end
  end
end
