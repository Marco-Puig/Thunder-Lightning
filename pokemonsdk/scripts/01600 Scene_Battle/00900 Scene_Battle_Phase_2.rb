#encoding: utf-8

#noyard
# Description: Définition de la phase de choix de l'action à réaliser
class Scene_Battle
  #===
  #>start_phase2 : Initialisation du choix pour le pokémon index
  #===
  def start_phase2(index=0)
    # Remise à 0 de l'avancement de la phase 4 (on passe forcément ici)
    @phase4_step = 0
    @phase = 2
    return if judge
    @action_selector.pos_selector(@action_index=0)
    #Vidage des actions si on retourne au premier actor :d
    @actor_actions.clear if index == 0
    #Si le Pokémon est KO on le saute
    if @actors[index].dead?
      @actor_actions.push([-1])
      return update_phase2_next_act
    #Si une attaque est forcée on la force :D
    elsif @actors[index].battle_effect.has_forced_attack?
      @actor_actions.push([0,@actors[index].battle_effect.get_forced_attack(@actors[index]),
      -@actors[index].battle_effect.get_forced_position-1,@actors[index]])
      return update_phase2_next_act
    #> Si le Pokémon doit se reposer
    elsif @actors[index].battle_effect.must_reload
      @actor_actions.push([0, @actors[index].find_last_skill_position, 0,@actors[index]])
      return update_phase2_next_act
    end
    display_message(parse_text(18, 71, '[VAR 010C(0000)]' => @actors[index].given_name),false) if @Actions_To_DO.size==0
    @action_selector.pokemon = @actors[index]
    @action_selector.visible = true
    0 while get_action
    launch_phase_event(2,true)
  end
  #===
  #>update_phase2
  #Méthode qui va mettre à jour le choix Attaquer, Sac, PKMN, Fuite
  #===
  def update_phase2
    #> Actions forcés par le tutoriel
    forced_action = get_action

    if !forced_action and Mouse.trigger?(:left) #>Souris
      forced_action, @action_index = @action_selector.mouse_action(@action_index)
      @action_selector.pos_selector(@action_index)
    end

    if Input.trigger?(:UP) and !forced_action or forced_action==:UP
      @action_index = ((@action_index == 3) ? 2 : 1)
    elsif Input.trigger?(:DOWN) and !forced_action or forced_action==:DOWN
      @action_index = ((@action_index == 1) ? 2 : 3)
    elsif Input.trigger?(:LEFT) and !forced_action or forced_action==:LEFT
      @action_index = 1
    elsif Input.trigger?(:RIGHT) and !forced_action or forced_action==:RIGHT
      @action_index = 0
    elsif Input.trigger?(:A) and !forced_action or forced_action==:A
      return on_phase2_validation
    elsif Input.trigger?(:B) and !forced_action or forced_action==:B
      if @actor_actions.size>0 and @actor_actions[-1][0] != 1 #> Empêchement du retour pour les objets
        $game_system.se_play($data_system.decision_se)
        start_phase2(@actor_actions.size-1)
      end
    end

    #Reposition du sprite de selection
    @action_selector.pos_selector(@action_index)
  end
  #===
  #>update_phase2_next_act
  #Méthode permettant de sauter l'actor en cours pour le suivant ou la phase 4
  #===
  def update_phase2_next_act
    if $game_temp.vs_type==2 and @actors[1] and
      !@actors[1].dead? and @actor_actions.size==1
      unless(@actor_actions[0][0] == 1 and @actor_actions[0][1][1][:ball_data])
        start_phase2(1)
        return
      end
    end
    launch_phase_event(4,false)
    @to_start=:start_phase4
  end
  #===
  #>update_phase2_escape
  #Méthode de fuite (menu fuite)
  #===
  def update_phase2_escape(auto_return=false)
    success = rand(256) < phase2_flee_factor
    $game_temp.vs_type.times do |i|
      next unless @actors[i]
      #>Boule fumée / Carapace Mue / Fuite
      if !$game_temp.trainer_battle and 
        (BattleEngine::_has_items(@actors[i],228,295) or 
        BattleEngine::Abilities.has_ability_usable(@actors[i],9))
        return true if auto_return
        $game_system.se_play($data_system.escape_se)
        display_message(text_get(18,75))
        battle_end(1)
        return
      end
      success&&=BattleEngine::_can_switch(@actors[i])
    end
    return success if auto_return
    #Si c'est un succès on lance la fin du combat avec l'argument fuite
    if success
      $game_system.se_play($data_system.escape_se)
      display_message(text_get(18,75))
      battle_end(1)
    else
      display_message(text_get(18,76))
      launch_phase_event(4,false)
      @to_start=:start_phase4
    end
  end

end
