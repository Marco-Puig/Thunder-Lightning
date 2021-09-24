#encoding: utf-8

# Class that describe a collection of characters
class String
  # Convert numeric related chars of the string to corresponding chars in the Pokémon DS font family
  # @return [self]
  # @author Nuri Yuri
  def to_pokemon_number
    return self if Font::NoPokemonFont
    self.gsub!("0","│")
    self.gsub!("1","┤")
    self.gsub!("2","╡")
    self.gsub!("3","╢")
    self.gsub!("4","╖")
    self.gsub!("5","╕")
    self.gsub!("6","╣")
    self.gsub!("7","║")
    self.gsub!("8","╗")
    self.gsub!("9","╝")
    self.gsub!("n","‰")
    self.gsub!("/","▓")
    return self
  end
  # Generate line feed after each dot followed by an capital letter
  # @param destructive [Boolean] indicate if the method generate line feed in the calling String or a new String
  # @return [self, String]
  # @author Nuri Yuri
  def generate_line_feeds(destructive = true)
    regexp = /\. [A-Z]/
    if destructive
      self.gsub!(regexp) { |i| i.setbyte(1,10);next(i) }
    else
      return self.gsub(regexp) { |i| i.setbyte(1,10);next(i) }
    end
    return self
  end
end
