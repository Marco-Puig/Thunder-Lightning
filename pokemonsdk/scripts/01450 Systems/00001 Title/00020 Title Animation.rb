class Scene_Title
  private

  # Create the title animation
  def create_title_animation
    GamePlay::Save.save_index = Configs.save_config.single_save? ? 0 : 1
    GameData::Text.load unless GamePlay::Save.load
    start_intro_movie(@movie_map_id) if @movie_map_id > 0
    create_title_graphics
    Audio.bgm_play(*Configs.scene_title_config.bgm_name)
  end

  # Function that create the title graphics
  def create_title_graphics
    create_title_background
    create_title_title
    create_title_controls
    # You can hook an animation over there
  end

  def create_title_background
    @background.load('background', :title)
    @background.opacity = 255
  end

  def create_title_title
    @title = Sprite.new(@viewport)
    @title.z = 200
    @title.load('title', :title)
  end

  def create_title_controls
    @title_controls = UI::TitleControls.new(@viewport)
  end
end
