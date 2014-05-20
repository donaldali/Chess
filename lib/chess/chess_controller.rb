# Class to manage the chess games available and run them as needed
class ChessController
	
	# Run the options available for the Chess app
	def run
		display_welcome
		loop do
			choice = get_menu_choice
			choice_result = handle_menu_choice choice
			break if choice_result == :quit
		end
		puts "Thanks for playing Chess :-) Play again soon."
	end

  # *********************************************
  # ************  PRIVATE METHODS  **************
  # *********************************************
	private

	# One time welcome message
	def display_welcome
		welcome = "\t**************************************\n" +
		          "\t********** Welcome To Chess **********\n" +
		          "\t**************************************\n"
		Chess.display_message welcome
	end

	# Display main menu and get user's choice
	def get_menu_choice
		options = ["Play Chess", "Load Saved Game", "Delete Saved Game",
			         "List Saved Games", "Quit"]
		options_title = "Chess Main Menu"
		get_option_choice(options, options_title)
	end

	# Controller that calls the appropriate method based on the user's choice
	def handle_menu_choice choice
		case choice
		when 1 then play_chess
		when 2 then load_game
		when 3 then delete_game
		when 4 then list_games
		when 5 then return :quit
		end
	end

	# Setup and play a new chess game
	def play_chess
		chess_game = ChessGame.new
		chess_game.play
	end

	# Load a previously saved chess game and resume game play from last save
	def load_game
		all_saved_games = Chess.yaml_load(Chess::GAMES_FILE)
		game_name = get_game_name(all_saved_games, "load")
		return if game_name.nil?

		saved_game = YAML::load(all_saved_games[game_name])
		Chess.message_then_enter "'#{game_name}' was successfully loaded."
		saved_game.play
	end

	# Get the name of a chess game (to load or delete) from the user
	def get_game_name(all_saved_games, task)
		game_names = all_saved_games.keys

		loop do
			game_name = Chess.get_input_for_prompt "Enter name of game to #{task}"
			return game_name if game_names.include? game_name

			next if Chess.yes_or_no "'#{game_name}' doesn't exists; #{task} another game"

			Chess.message_then_enter "You chose to not #{task} any game."
			return nil
		end
	end

	# Delete a previously saved chess game
	def delete_game
		all_saved_games = Chess.yaml_load(Chess::GAMES_FILE)
		game_name = get_game_name(all_saved_games, "delete")
		return if game_name.nil?

		all_saved_games.delete(game_name)
		Chess.yaml_save(Chess::GAMES_FILE, all_saved_games)
		Chess.message_then_enter "'#{game_name}' was successfully deleted."
	end

	# List the names of all previously saved chess games
	def list_games
		all_saved_games = Chess.yaml_load(Chess::GAMES_FILE)
		game_string = "Saved Games\n===========\n"
		all_saved_games.keys.each { |game_name| game_string += "#{game_name}\n"}
		Chess.message_then_enter game_string
	end

end
