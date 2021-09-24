#encoding: utf-8

module GameData
  # Variable that contain a list of tutorial actions for battle
  # @deprecated will change in the future, its an old example
  Tutos=Array.new
  Tutos[0]=[[:@action_selector,false]] #N'affiche pas le selecteur pour débuter le combat tuto
  #>Choix du menu attaquer
  Tutos[1]=[[:msg],[:@action_selector,true],[:@Actions_Counter,-30],:RIGHT,:DOWN,:LEFT,:UP,:A,[:@skill_selector,false],[:@atk_index,0]]
  Tutos[2]=[[:msg],[:@action_selector,true],[:@Actions_Counter,-30],:A,[:@atk_index,0]]
  #>Choix attaque de type status
  Tutos[3]=[[:msg],[:@skill_selector,true],[:@Actions_Counter,-30],[:select_atk_caract,3]]
  #>Choix attaque de type offensive
  Tutos[4]=[[:msg],[:@Actions_Counter,-30],[:select_atk_caract,1]]
  Tutos[5]=[[:msg]]#,[:@action_selector,true]]
  Tutos[6]=[[:msg,"Que doit faire \\v[298] ?"],[:@action_selector,true]]
end
