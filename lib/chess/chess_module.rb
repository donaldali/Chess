# Shared constants and helpful methods for the Chess app
module Chess
  SIZE = 8
  GAMES_FILE = 'saved_games'

  # Determine the other player
  def other_player(player)
    player == :white ? :black : :white
  end

  # Get the user's choice for a list of menus in an array
  def get_option_choice(options, options_title = "Options")
    display_message("\n" + options_title)
    display_message("=" * options_title.length)
    options.each_with_index do |option, index|
      display_message "#{index + 1}. #{option}"
    end
    prompt = "Select an option (1 - #{options.length})"

    loop do 
      choice = (get_input_for_prompt prompt).to_i
      return choice if choice.between?(1, options.length)
    end
  end

  # Returns true if yes or y is entered; false if no or n is entered
  def yes_or_no(question)
    loop do
      prompt = question + " (y/n)"
      response = (get_input_for_prompt prompt).strip.downcase
      if response == 'y' || response == 'yes'
        return true
      elsif response == 'n' || response == 'no'
        return false
      end
    end
  end

  # Get input from user based on a given prompt
  def get_input_for_prompt(prompt) 
    loop do 
      print_message(prompt + ": ")
      input  = gets.chomp
      return input unless input.empty?
    end
  end

  # Display a message and wait for user to press enter before continuing
  def message_then_enter(message)
    print_message(message += "\nPress Enter to continue...")
    gets
  end

  # Display a message
  def display_message(message)
    puts message
  end

  # Print a message
  def print_message(message)
    print message
  end

  # Display an error message in appropriate color/format
  def error_message(message)
    display_message(color(message, :red))
  end

  # Display an warning message in appropriate color/format
  def warn_message(message)
    display_message(color(message, :yellow))
  end

  # Display an important message in appropriate color/format
  def highlight_message(message)
    display_message(color(message, :flip))
  end

  # Display text in color. Color is expected as a symbol. Eg :yellow or :red
  def color(text, color)
    case color
    when :red then colorize(text, "31")
    when :yellow then colorize(text, "33")
    when :green then colorize(text, "32")
    when :flip then colorize(text, "7")
    else colorize(text, "0")
    end
  end

  # Help display text in color. Color code is expected. Eg "1;34;44"
  def colorize(text, color_code)
    "\033[#{color_code}m#{text}\033[0m"
  end

  # Load the contents of a file and convert it to an object with YAML
  def yaml_load(filename)
    begin
      YAML::load(File.read filename)
    rescue
      error_message "Unable to read from file '#{filename}'."
      nil
    end
  end

  # Use YAML to save an object to file
  def yaml_save(filename, to_save)
    begin
      File.open(filename, 'w') do |file|
        file.write(to_save.to_yaml)
      end
      true
    rescue
      error_message "Unable to save to file '#{filename}'."
      nil
    end
  end
end
