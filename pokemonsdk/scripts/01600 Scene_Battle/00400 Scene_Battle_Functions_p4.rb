#encoding: utf-8

#noyard
# Description: Définition de fonctions utiles ou d'animations pendant la phase 4
class Scene_Battle
  #===
  #>clean_effect
  #Mise à jour des effets d'une équipe de Pokémon
  #===
  def clean_effect(party)
    party.size.times do |i|
      party[i].battle_effect.update_counter(party[i]) unless party[i].dead?
    end
  end
  #===
  #>phase4_cant_display_message
  #Vérification de la possibilité d'affichage des message
  #===
  def phase4_cant_display_message(launcher,target)
    if launcher and launcher.hp==0
      return true
    elsif target and target.hp==0
      return true
    end
    return false
  end
  #===
  #>phase4_message_remove_hp
  #Animation de la perte de HP
  #===
  def phase4_message_remove_hp(pokemon,hp)
    pk_hp=pokemon.hp
    20.times do |i|
      pokemon.hp=pk_hp-hp*i/20
      pokemon.hp=0 if pokemon.hp<0
      status_bar_update(pokemon)
      break if pokemon.hp<=0
      Graphics.update
      update_animated_sprites
    end
    pokemon.hp=pk_hp-hp
    pokemon.hp=0 if pokemon.hp<0
    status_bar_update(pokemon)
    Graphics.update
    update_animated_sprites
    phase4_animation_KO(pokemon) if (pk_hp-hp)<=0
  end
  #===
  #>phase4_message_add_hp
  #Animation du gain de HP
  #===
  def phase4_message_add_hp(pokemon,hp)
    pk_hp=pokemon.hp
    20.times do |i|
      pokemon.hp=pk_hp+hp*i/20
      pokemon.hp=pokemon.max_hp if pokemon.hp>pokemon.max_hp
      status_bar_update(pokemon)
      break if pokemon.hp==pokemon.max_hp
      Graphics.update
      update_animated_sprites
    end
    pokemon.hp=pk_hp+hp
    pokemon.hp=pokemon.max_hp if pokemon.hp>pokemon.max_hp
    status_bar_update(pokemon)
    Graphics.update
    update_animated_sprites
  end
  #===
  #>status_bar_update
  #Mise à jour de la status bar d'un Pokémon
  #===
  def status_bar_update(pokemon)
    if pokemon.position.to_i<0
      bar=@enemy_bars[-pokemon.position-1]
    else
      bar=@actor_bars[pokemon.position]
    end
    return unless bar
    bar.refresh
    bar.update
  end
  #===
  #>phase4_distribute_exp
  #Distribution de l'expérience. pokemon est celui qui est tombé KO
  #===
  def phase4_distribute_exp(pokemon)
    return if $game_switches[::Yuki::Sw::BT_NoExp]
    #Selection des Pokémons qui reçoivent l'expérience
    getters=(pokemon.position<0 ? @actors : @enemies)
    #Si c'est pas le camp de l'attaquant, pas de distribution de l'exp
    #return if !getters.include?(@_launcher) and @_launcher #Retiré à cause des contre coups
    #Somme du nombre de tours
    turn_sum=0
    getters.each do |i|
      turn_sum+=i.battle_turns if i
    end
    #Somme des tours des combattant
    battle_turn=0
    $game_temp.vs_type.times do |j|
      battle_turn+=getters[j].battle_turns if getters[j]
    end
    return if turn_sum==0
    #On scane tous les Pokémons de l'équipe affin de distribuer expérience
    getters.each_index do |j|
      i=getters[j] #Pokémon recevant l'expérience

      #On passe au suivant si le Pokémon n'exste pas, est KO ou est déjà aux max level
      next if !i or i.dead?
      next if i.level>=GameData::MAX_LEVEL

      base_exp=phase4_exp_calculation(pokemon,i) #Expérience récupérée de base
      if(j<$game_temp.vs_type)
        get_exp=base_exp*battle_turn/turn_sum/$game_temp.vs_type
      else
        get_exp=base_exp*i.battle_turns/turn_sum
      end
      #Bonus du multi-exp (exp_totale*50%) // critère 4G
      get_exp+=(base_exp/2) if(i.item_holding == 216 and j>=$game_temp.vs_type)

      next if get_exp==0
      base_exp=i.exp #Expérience de base
      i.add_bonus(pokemon.battle_list) #Distribution des EVs
      text = parse_text(18, ((i.item_holding == 216) ? 44 : 43),
      "[VAR 010C(0000)]" => i.given_name,
      NUM7R => get_exp.to_s)
      display_message(text)
      #Boucle de distribution de l'expérience
      given=0
      while given < get_exp and i.level < GameData::MAX_LEVEL
        exp_lvl=i.exp_list[i.level+1].to_i
        exp=(exp_lvl-i.exp_list[i.level])/40
        exp=1 if exp<=0

        #Mise à jour de l'expérience pour le niveau actuel (40 frames = 1 niveau)
        40.times do
          i.exp+=exp
          break if i.exp>exp_lvl or i.exp>(base_exp+get_exp)
          #Si le Pokémon n'est pas sur le terrain on ne met pas la barre à jour
          if(j<$game_temp.vs_type)
            status_bar_update(i)
            Graphics.update
            update_animated_sprites
          end
        end

        #Ici on recalibre l'expérience totale
        i.exp=exp_lvl if i.exp>exp_lvl
        i.exp=(base_exp+get_exp) if i.exp>(base_exp+get_exp)
        if(j<$game_temp.vs_type) #Mise à jour de la barre affin de bien voir l'arrêt exact
          status_bar_update(i)
          Graphics.update
          update_animated_sprites
        end

        #Si on est au dessus de l'exp nécessaire au niveau, on level up !
        if i.exp >= exp_lvl
          list = i.level_up_stat_refresh
          status_bar_update(i) if j<$game_temp.vs_type
          display_message(parse_text(18, 62, '[VAR 010C(0000)]' => i.given_name,
          ::PFM::Text::NUM3[1] => (i.level).to_s))
          i.level_up_window_call(list[0],list[1],@message_window.z+5) if i.position>=0
          @message_window.update
          Graphics.update
          update_animated_sprites
          i.check_skill_and_learn
          @_Evolve<<i unless @_Evolve.include?(i)
        end

        #Mise à jour de l'exp donnée pour savoir si on arrête ou non la boucle
        given=i.exp-base_exp
      end
      # i.battle_turns = 0
    end
    @exp_distributed = true
  end
  #===
  #>phase4_exp_calculation
  #Calcul de l'expérience
  #===
  def phase4_exp_calculation(killed,receiver)
    #> Oeuf chance (+50%)
    return (killed.base_exp*killed.level*3/14) if(receiver.battle_item == 231)
    return killed.base_exp*killed.level/7
  end
  #===
  #>phase4_actor_select_pkmn
  # Selection d'un Pokémon pour l'actor
  #===
  def phase4_actor_select_pkmn(i)
    @message_window.visible = false
    $scene = scene = GamePlay::Party_Menu.new(@actors, :battle, no_leave: true)
    scene.main#(true)
    @message_window.visible = true
    $scene = self
    return_data = scene.return_data
    Graphics.transition
    return [2,return_data,i.position]
  end
  #===
  #>phase4_enemie_select_pkmn
  #Vérification de la possibilité d'envoyer un autre ennemi
  #===
  def phase4_enemie_select_pkmn(i)
    #>Temporaire en attendant la reprogrammation de l'IA
=begin
    $game_temp.vs_type.step(@enemies.length-1) do |j|
      if @enemies[j] and !@enemies[j].dead?
        return [2,-j-1,-i.position-1]
      end
    end
=end
    return PFM::IA.request_switch(i)
    #$game_temp.vs_type.step(@enemies.length-1) do |j|
    #  if @enemies[j] and !@enemies[j].dead?
    #    return j
    #  end
    #end
    return false
=begin
    if @enemies[i].dead?
      $game_temp.vs_type.step(@enemies.length-1) do |j|
        if @enemies[j] and !@enemies[j].dead?
          return j
          tmp=@enemies[j]
          @enemies[j]=@enemies[i]
          @enemies[i]=tmp
          return true
        end
      end
      return false
    end
    return false
=end
  end
  #===
  #>phase4_try_to_catch_pokemon
  #Fonction de tentative de capture d'un Pokémon
  #===
  def phase4_try_to_catch_pokemon(ball_data,id)
    pokemon=@enemies[@enemies[0].dead? ? 1 : 0]
    hpmax=pokemon.max_hp*3
    hp=pokemon.hp*2
    rate=pokemon.rareness
    #Calcul du bonus de status
    case pokemon.status
    when 1,2,3,8
      bs=1.5
    when 4,5
      bs=2
    else
      bs=1
    end
    #Calcul du bonus de ball utilisé
    bb=phase4_ball_bonus(ball_data,pokemon)
    #>Mass ball
    if(ball_data.special_catch and ball_data.special_catch[:mass])
      if(pokemon.weight < 100)
        rate -= 20
      elsif(pokemon.weight > 300)
        rate += 30
      elsif(pokemon.weight > 200)
        rate += 20
      end
    end
    #Taux préliminaires
    a=(hpmax-hp)*rate*bs*bb/hpmax
    b=(0xFFFF*(a/255.0)**0.25).to_i
    cnt=0
    4.times do |i|
      cnt+=1 if(rand(0xFFFF)<b)
    end
    return phase4_animation_capture(cnt,pokemon,id)
  end
  #===
  #>phase4_ball_bonus
  #Calcule le bonus conféré par la balle
  #===
  def phase4_ball_bonus(ball_data,pokemon)
    data=ball_data.special_catch
    if(data)
      if(types=data[:types])
        if(types.include?(pokemon.type1) or types.include?(pokemon.type2))
          return (data[:catch_rate] ? data[:catch_rate] : ball_data.catch_rate)
        end
      elsif(data[:level]) #Faiblo ball
        if(pokemon.level<19)
          return 3
        elsif pokemon.level<29
          return 2
        end
      elsif(data[:time]) #Chrono ball
        return (1+$game_temp.battle_turn/25)
      elsif(data[:bis]) #Bis ball
        return 3 if $pokedex.has_captured?(pokemon.id)
      elsif(data[:scuba]) #Scuba ball
        return 3.5 if $env.under_water?#Vérifier si on est sous l'eau
      elsif(data[:dark]) #Sombre ball
        return 4 if $env.night? or $env.cave?#Vérifier si on est la nuit ou dans une grotte
      elsif(data[:speed]) #Speed Ball
        return 4 if $game_temp.battle_turn<6
        return 3 if $game_temp.battle_turn<11
        return 2 if $game_temp.battle_turn<16
      elsif(data[:speed_pk])
        return 4 if pokemon.base_spd >= 100 or $wild_battle.is_roaming?(pokemon)#>Vérifier que le pokémon adverse est rapide
      elsif(data[:appat])
        return 3 if @fished #>Vérifier que le pokémon vient d'être peché
      elsif(data[:level_ball])
        lvl = @actors[0].level
        if(lvl / 4 > pokemon.level)
          return 8
        elsif(lvl / 2 > pokemon.level)
          return 4
        elsif(lvl > pokemon.level)
          return 2
        end
      elsif(data[:moon_ball])
        data = $game_data_pokemon[pokemon.id][pokemon.form]
        if(data.special_evolution and data.special_evolution[:stone]==81)
          return 4
        end
      elsif(data[:love])
        if(@actors[0].gender * pokemon.gender == 2)
          return 8
        end
      end
      return 1
    else
      return ball_data.catch_rate
    end
  end
  #===
  #>phase4_animation_capture
  #Animation de la capture //!!!\\ A terminer !
  #===
  def phase4_animation_capture(cnt,pokemon,id)
    gr_launch_ball_to_enemy(pokemon, id)
    (cnt - 1).times do
      gr_animate_ball_on_enemy(pokemon)
    end

    if cnt == 4
      gr_animate_caught(pokemon)
      #Faire toute la scène de capture
      $game_switches[Yuki::Sw::BT_Catch] = true
      pokemon.captured_with = id
      pokemon.captured_at = Time.new.to_i
      pokemon.trainer_name = $trainer.name
      pokemon.trainer_id = $trainer.id
      pokemon.code_generation(pokemon.shiny, !pokemon.shiny)
      start_phase5
    else
      gr_animate_pokebreak(pokemon)
      display_message(parse_text(18, 63 + rand(4)))
    end
  end

  # Show the launch ball animation
  # @param pokemon [PFM::Pokemon] Pokemon we try to catch
  # @param id [Integer] ID of the ball in the database
  def gr_launch_ball_to_enemy(pokemon, id)
    pokemon_sprite = gr_get_pokemon_sprite(pokemon)
    origin_sprite = pokemon.position < 0 ? @actor_sprites.first : @enemy_sprites.first
    @ball_sprite = Sprite.new(@viewport).set_bitmap(GameData::Item.ball_data(id).img, :ball)
    @ball_sprite.visible = false
    @animator = Yuki::Basic_Animator.new(load_data('Data/Animations/pokeball_catch.dat'), origin_sprite, pokemon_sprite)
    @animator.parameters[:ball_sprite] = @ball_sprite
    while @animator.update
      @viewport.sort_z
      update_animated_sprites
      Graphics.update unless @animator.terminated?
    end
    @animator = nil
  end

  # Show the moving animation of the ball
  # @param pokemon [PFM::Pokemon] Pokemon we try to catch
  def gr_animate_ball_on_enemy(pokemon)
    pokemon_sprite = gr_get_pokemon_sprite(pokemon)
    origin_sprite = pokemon.position < 0 ? @actor_sprites.first : @enemy_sprites.first
    @animator = Yuki::Basic_Animator.new(load_data('Data/Animations/pokeball_move.dat'), origin_sprite, pokemon_sprite)
    @animator.parameters[:ball_sprite] = @ball_sprite
    while @animator.update
      @viewport.sort_z
      update_animated_sprites
      Graphics.update unless @animator.terminated?
    end
    #@ball_sprite.dispose
    @animator = nil
  end

  # Show the catch animation of the ball
  # @param pokemon [PFM::Pokemon] Pokemon we try to catch
  def gr_animate_caught(pokemon)
    pokemon_sprite = gr_get_pokemon_sprite(pokemon)
    origin_sprite = pokemon.position < 0 ? @actor_sprites.first : @enemy_sprites.first
    @animator = Yuki::Basic_Animator.new(load_data('Data/Animations/pokeball_got.dat'), origin_sprite, pokemon_sprite)
    @animator.parameters[:ball_sprite] = @ball_sprite
    while @animator.update
      @viewport.sort_z
      update_animated_sprites
      Graphics.update unless @animator.terminated?
    end
    @animator = nil
  end

  # Show the break animation of the ball
  # @param pokemon [PFM::Pokemon] Pokemon we try to catch
  def gr_animate_pokebreak(pokemon)
    pokemon_sprite = gr_get_pokemon_sprite(pokemon)
    origin_sprite = pokemon.position < 0 ? @actor_sprites.first : @enemy_sprites.first
    @animator = Yuki::Basic_Animator.new(load_data('Data/Animations/pokeball_break.dat'), origin_sprite, pokemon_sprite)
    @animator.parameters[:ball_sprite] = @ball_sprite
    while @animator.update
      @viewport.sort_z
      update_animated_sprites
      Graphics.update unless @animator.terminated?
    end
    @ball_sprite.dispose
    @animator = nil
  end

  #===
  #>_phase4_status_check
  #Traitement des effets des status
  #===
  def _phase4_status_check(pkmn)
    return if(!pkmn or pkmn.dead? or BattleEngine::Abilities.has_ability_usable(pkmn,17)) #>Garde Magik
    if(pkmn.poisoned?) #Poison
      #>Soin Poison
      if(BattleEngine::Abilities::has_ability_usable(pkmn,89))
        BattleEngine::_msgp(19, 387, pkmn)
        BattleEngine::_message_stack_push([:hp_up, pkmn, pkmn.poison_effect, true])
      else
        BattleEngine::_msgp(19, 243, pkmn)
        BattleEngine::_mp([:animation_on, pkmn, 469 + pkmn.status])
        BattleEngine::_message_stack_push([:hp_down, pkmn, pkmn.poison_effect, true])
      end
    elsif(pkmn.burn?) #Brûlure
      hp = pkmn.burn_effect
      hp /= 2 if BattleEngine::Abilities::has_ability_usable(pkmn, 117) #> Ignifugé
      BattleEngine::_msgp(19, 261, pkmn)
      BattleEngine::_mp([:animation_on, pkmn, 469 + pkmn.status])
      BattleEngine::_message_stack_push([:hp_down,pkmn,pkmn.burn_effect,true])
    elsif(pkmn.toxic?) #Intoxiqué
      BattleEngine::_msgp(19, 243, pkmn)
      BattleEngine::_mp([:animation_on, pkmn, 469 + pkmn.status])
      BattleEngine::_message_stack_push([:hp_down,pkmn,pkmn.toxic_effect,true])
    end
  end
  #===
  #>switch_pokemon
  # Fonction permettant de réaliser un switch
  #===
  def switch_pokemon(from, to = nil)
    unless @_SWITCH.include?(from)
     @_SWITCH.push(from)
      if(to)
        @_NoChoice[from] = to
      end
    end
  end
  #===
  #>_phase4_switch_check
  # Vérification des switchs à réaliser
  #===
  def _phase4_switch_check
    return @_SWITCH.clear if judge
    to_del = [] #Array des Pokémon à supprimer du tableau de switch
    turn = @phase4_step<@actions.size #>Si on est pas à la fin du tour
    #Affichage des switch A REMANIER !!!!
    @_SWITCH.each do |i|
      next unless i
      next if i.dead? and turn #>Empêcher switch mort avant la fin
      to_del << i
      #>Choix forcé
      if(to = @_NoChoice[i])
        if(i.position < 0)
          phase4_switch_pokemon([2,-@enemies.index(to).to_i-1, -i.position-1])
        else
          phase4_switch_pokemon([2,@actors.index(to).to_i, i.position])
        end
        @_NoChoice.delete(i)
        next
      end
      #>Choix libre
      if i.position<0
        new_enemy=phase4_enemie_select_pkmn(i)
        #phase4_switch_pokemon([2,-new_enemy-1,-i.position-1]) if new_enemy
        phase4_switch_pokemon(new_enemy) if new_enemy
        @e_remaining_pk.redraw if $game_temp.trainer_battle
      else
        #Vérification de la possibilité de switch
        if($game_temp.vs_type==2)
          alive=0
          @actors.each do |j|
            alive+=1 if j and j.hp>0
          end
          next if(alive<2)
        end
        #Tentative de fuite en 1v1 wild
        unless($game_temp.trainer_battle or $game_temp.vs_type==2)
          #r=display_message("Voulez-vous envoyer un autre Pokémon ?\n",false,1,"Oui","Non")
          r=display_message(text_get(18, 80),true,1,text_get(20, 56),text_get(20, 55))
          if(r == 1)
            if(update_phase2_escape(true))
              $game_system.se_play($data_system.escape_se)
              return battle_end(1)
            else
              display_message(text_get(18, 77)) #"Impossible de fuire.")
            end
          end
        end
        #Switch si possible
        new_actor=phase4_actor_select_pkmn(i)
        phase4_switch_pokemon(new_actor) if new_actor
        @a_remaining_pk.redraw
      end
    end
    #suppression
    to_del.each do |i|
      @_SWITCH.delete(i)
    end
  end
end
