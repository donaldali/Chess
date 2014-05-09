#
module Chess
	SIZE = 8

	def other_player(player)
		player == :white ? :black : :white
	end

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

	#
	def message_then_enter(message)
		print_message(message += "\nPress Enter to continue...")
		gets
	end

	#
	def display_message(message)
		puts message
	end

	#
	def print_message(message)
		print message
	end
end
