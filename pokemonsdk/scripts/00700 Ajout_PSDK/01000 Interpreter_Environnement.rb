# Interpreter of the event script commands
class Interpreter < Interpreter_RMXP
  # Detect if the event can spot the player and move to the player
  # @param nb_pas [Integer] number of step the event should do to spot the player
  # @return [Boolean] if the event spot the player or not
  # @author Nuri Yuri
  def player_spotted?(nb_pas)
    return false if $game_switches[Yuki::Sw::Env_Detection]
    c = $game_map.events[@event_id]
    # Detect if the player is too far away from the event
    return false if (c.x - $game_player.x).abs > nb_pas || (c.y - $game_player.y).abs > nb_pas
    return false if c.z != $game_player.z # Prevent detection when event & player arent both on a bridge
    x = c.x
    y = c.y
    d = c.direction
    new_x = (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = (d == 2 ? 1 : d == 8 ? -1 : 0)
    result = false
    # Detect if the player is right in front of the event
    result = true if $game_player.x == (x + new_x) && $game_player.y == (y + new_y)
    # Detect the player by simulating walking
    unless result
      0.upto(nb_pas) do
        if c.passable?(x, y, d, true)
          break(result = true) if $game_player.x == x && $game_player.y == y
        else
          result = true if $game_player.x == x && $game_player.y == y
          break
        end
        x += new_x
        y += new_y
      end
    end
    # Detect if the player triggered the event from Action key
    result ||= (Input.trigger?(:A) && $game_player.front_tile_event == c)
    # Stop the player from Running
    if result
      $game_switches[::Yuki::Sw::EV_Run] = false
      $game_temp.common_event_id = Game_CommonEvent::APPEARANCE
    end
    return result
  end
  alias trainer_spotted player_spotted?

  # Detect the player in a specific direction
  # @param nb_pas [Integer] the number of step between the event and the player
  # @param direction [Symbol, Integer] the direction : :right, 6, :down, 2, :left, 4, :up or 8
  # @return [Boolean]
  # @author Nuri Yuri
  def detect_player(nb_pas, direction)
    return false if $game_switches[Yuki::Sw::Env_Detection]
    c = $game_map.events[@event_id]
    dx = $game_player.x - c.x
    dy = $game_player.y - c.y
    case direction
    when :right, 6
      return (dy == 0 && dx >= 0 && dx <= nb_pas)
    when :down, 2
      return (dx == 0 && dy >= 0 && dy <= nb_pas)
    when :left, 4
      return (dy == 0 && dx <= 0 && dx >= -nb_pas)
    else
      return (dx == 0 && dy <= 0 && dy >= -nb_pas)
    end
  end

  # Detect the player in a rectangle around the event
  # @param nx [Integer] the x distance of detection between the event and the player
  # @param ny [Integer] the y distance of detection between the event and the player
  # @return [Boolean]
  # @author Nuri Yuri
  def detect_player_rect(nx, ny)
    return false if $game_switches[Yuki::Sw::Env_Detection]
    c = $game_map.events[@event_id]
    dx = ($game_player.x - c.x).abs
    dy = ($game_player.y - c.y).abs
    return (dx <= nx && dy <= ny)
  end

  # Detect the player in a circle around the event
  # @param r [Numeric] the square radius (r = R²) of the circle around the event
  # @return [Boolean]
  # @author Nuri Yuri
  def detect_player_circle(r)
    return false if $game_switches[Yuki::Sw::Env_Detection]
    c = $game_map.events[@event_id]
    dx = $game_player.x - c.x
    dy = $game_player.y - c.y
    return ((dx * dx) + (dy * dy)) <= r
  end

  # Change the tileset
  # @param filename [String] filename of the new tileset
  def change_tileset(filename)
    $scene.change_tileset(filename)
  end

  # Delete the current event forever
  def delete_this_event_forever
    $env.set_event_delete_state(@event_id)
    $game_map.events[@event_id].erase
  end

  # Wait for the end of the movement of this particular character
  # @param event_id [Integer] <default : calling event's> the id of the event to watch
  def wait_character_move_completion(event_id = @event_id)
    @move_route_waiting = true
    @move_route_waiting_id = event_id
  end
  alias attendre_fin_deplacement_cet_event wait_character_move_completion
end
