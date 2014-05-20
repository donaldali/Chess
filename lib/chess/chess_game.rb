# Class to play one or many Chess games
class ChessGame
	Player = Struct.new(:color, :name)

  attr_accessor :chessboard

	def initialize
		@chessboard = Chessboard.new
		display_welcome_message
		setup_game
		@chessboard.players = {white: @players.first.name, black: @players.last.name}
	end

  # Play as many Chess games as desired
	def play
		catch(:game_saved) do
			loop do 
				play_game
				play_again = Chess.yes_or_no "Play another game"
				break unless play_again
				reset_game
			end
		end
	end

  # *********************************************
  # ************  PRIVATE METHODS  **************
  # *********************************************
	private

  # Play one game of Chess
	def play_game
		catch(:game_over) do
			loop do
				@chessboard.display_board
				get_input
				handle_input
			end
		end
	end

  # Setup game players and other variables
	def setup_game
		@players = [Player.new(:white), Player.new(:black)]
		get_player_names
		reset_game
	end

  # Set variables for the start of a Chess game
	def reset_game
		@chessboard.reset_board
		@cur_player  = @players.first
		@game_states_count = Hash.new(0)
		add_game_state
		reset_input
	end

  # Reset input for a new player
	def reset_input
		@input  = { option: nil, from: nil, to: nil }
	end

	def get_player_names
		@players.first.name = Chess.get_input_for_prompt "Enter White player's name"
		@players.last.name  = Chess.get_input_for_prompt "Enter Black player's name"
	end

  # Add the current game state to the count of game states. This count is
  # used to check for threefold repetition
	def add_game_state
		@game_states_count[current_game_state] = 0 if	@game_states_count[current_game_state].nil?
		@game_states_count[current_game_state] += 1
	end

  # Store the game state as a combination of the board state and current player
	def current_game_state
		(@chessboard.board_state << @cur_player.color).to_yaml
	end

	def switch_player
		@cur_player = opponent
	end

  # Display relevant end of game message, and end the game
	def end_game end_type
		message = case end_type
		          when :checkmate, :resign then win_game(end_type)
		          when :stalemate, :draw_offer, :three_repetition, :fifty_move, 
			             :no_checkmate then draw_game(end_type)
		          end
	
		@chessboard.display_board
		Chess.highlight_message message
		throw :game_over
	end

  # Generate end game message based on type of draw
	def draw_game end_type
		case end_type
		when :stalemate        then "A stalemate has occured (#{opponent.name} has "\
			                          "no moves but is not in check). Game is a DRAW."
		when :draw_offer       then "#{opponent.name} accepted #{@cur_player.name}'s"\
			                          " draw offer. Game is a DRAW."
		when :three_repetition then "#{@cur_player.name}'s claim of draw by threefold"\
			                          " repetition was verified. Game is a DRAW."
		when :fifty_move       then "#{@cur_player.name}'s claim of draw by "\
			                          "fifty-move rule was verified. Game is a DRAW."
		when :no_checkmate     then "There is an Impossibility of checkmate "\
			                          "(insufficient material). Game is a DRAW."
		end
	end

  # Generate end game message based on type of win
	def win_game end_type
		case end_type
		when :checkmate then "#{opponent.name} has been checkmated. #{@cur_player.name} WINS."
		when :resign    then "#{@cur_player.name} Resigns. #{opponent.name} WINS."
		end
	end

  # Process the legal input of a player
	def handle_input
		check_draw_claim(:before_move)
		make_move
		check_auto_end_game
		handle_draw_offer if @input[:option] == :draw_offer
		switch_player
		add_game_state
		check_draw_claim(:after_move)
		reset_input
	end

  # Move a game piece on the chessboard
	def make_move
		@chessboard.move(@input[:from], @input[:to])
	end

  # Check if any automatic end game triggering situation exists
	def check_auto_end_game
		end_game(:checkmate)    if @chessboard.checkmate?(opponent.color)
		end_game(:stalemate)    if @chessboard.stalemate?(opponent.color)
		end_game(:no_checkmate) if @chessboard.checkmate_impossible?
	end

  # Present a player's draw offer to his/her opponent
	def handle_draw_offer
		@chessboard.display_board
		question = "#{opponent.name}, #{@cur_player.name} offered a draw. Do you accept"
		end_game(:draw_offer) if Chess.yes_or_no question
		Chess.warn_message "#{@cur_player.name}, #{opponent.name} rejected your draw offer"
	end

  # Check if the draw claim of a player exists
	def check_draw_claim check_time
		return if @input[:option].nil?
		check_threefold_repetition check_time if @input[:option] == :three_repetition
		check_fifty_move check_time           if @input[:option] == :fifty_move		
	end

  # Check if the threefold repetition situation exists
	def check_threefold_repetition check_time
		if @game_states_count[current_game_state] >= 3
			switch_player if check_time == :after_move
			end_game(:three_repetition)
		end	
		reject_draw_claim("threefold repetition", check_time)
	end

  # Check if the fifty-move rule situation exists
	def check_fifty_move check_time
		if @chessboard.no_capture_or_pawn_moves >= 100
			switch_player if check_time == :after_move
			end_game(:fifty_move)
		end
		reject_draw_claim("fifty-move rule", check_time)
	end

  # Inform a player if their draw claim was found to not exist
	def reject_draw_claim(draw_claim, check_time)
		msg = "#{opponent.name}, your claim of draw by "
		msg += "#{draw_claim} was NOT verified. Game continues"	
		Chess.warn_message msg if check_time == :after_move
	end

  # Check if the current player's King is in check
	def check_for_check
		if @chessboard.check?(@cur_player.color)
			Chess.warn_message("WARNING: #{@cur_player.name}, your King is in check")
		end
	end

  # Display an error message for bad input and go back to get new user input
	def invalid message
		Chess.error_message "#{@cur_player.name}, #{message}"
		throw :invalid
	end

  # Get a complete valid input for the current player
	def get_input
		check_for_check
		prompt = "#{@cur_player.name}, Enter a move (or 'o' for options)"
		loop do 
			player_input = (Chess.get_input_for_prompt prompt).strip.downcase
			break if complete_input?(player_input)
		end
	end

  # Verify that the user's input is complete and valid
	def complete_input?(player_input)
		if player_input == "o" || player_input == "'o'" || player_input == "options"
			set_in_game_options
			return nil
		end

		catch(:invalid) do
			return set_valid_move player_input
		end
		nil
	end

  # Set the user's input (if it is valid)
	def set_valid_move player_input
		from, to      = split_input player_input
		from, to      = convert_positions(from, to)
		validate_move(from, to)
		@input[:from] = from
		@input[:to]   = to
	end

  # Check that the move entered as two positions is valid
	def validate_move(from, to)
		invalid "you must enter different positions" if from == to
		unless @cur_player.color == @chessboard.piece_at(from).color
			invalid "your first position must contain your piece" 
		end
		if @chessboard.piece_at(from).possible_positions.include?(to) &&
			 !@chessboard.piece_at(from).move_positions.include?(to)
			invalid check_causing_message(from, to)
		end
		unless @chessboard.piece_at(from).move_positions.include?(to)
			invalid move_error_message(from, to)
		end
	end

  # Create error message for a move that leaves a player's king in check
	def check_causing_message(from, to)
		from_piece, human_from, human_to = human_parse(from, to)
		"moving your #{from_piece} from #{human_from} to #{human_to} will leave your King in check"
	end

  # Create error message for an invalid move
	def move_error_message(from, to)
		from_piece, human_from, human_to = human_parse(from, to)
		"you can't move your #{from_piece} from #{human_from} to #{human_to}"
	end

  # Convert a move to a human-readable parts
	def human_parse(from, to)
		from_piece = @chessboard.piece_at(from).type.to_s.capitalize
		human_from = human_position(from)
		human_to   = human_position(to)
		[from_piece, human_from, human_to]
	end

  # Convert an array position to a position as is on a chessboard (eg 'a2')
	def human_position position
		ranks = %w(8 7 6 5 4 3 2 1)
		files = %w(a b c d e f g h)
		files[position[1]] + ranks[position[0]]
	end

  # Convert two positions as is on a chessboard to array representation
	def convert_positions(from, to)
		[convert_position(from), convert_position(to)]		
	end

  # Convert a position as is on a chessboard to an array representation
	def convert_position(position)
		unless position.length == 2
			invalid "each of your two positions must be exactly one letter and one number"
		end
		convert_rank_file(position[1], position[0])
	end

  # Validate a chess position and convert a valid position to array form
	def convert_rank_file(rank, file)
		unless file.between?("a", "h")
			invalid "your position should start with a letter between 'a' and 'h'"
		end
		unless rank.between?("1", "8")
			invalid "your position should end with a digit between '1' and '8'"
		end

		ranks = { "1" => 7, "2" => 6, "3" => 5, "4" => 4, "5" => 3, "6" => 2, "7" => 1, "8" => 0 }
		files = { "a" => 0, "b" => 1, "c" => 2, "d" => 3, "e" => 4, "f" => 5, "g" => 6, "h" => 7 }
		[ ranks[rank], files[file] ]
	end

  # Split a move into its positions and accept only a valid move
	def split_input player_input
		if player_input.length == 4
			[player_input[0..1], player_input[2..3]]
		else
			player_input = player_input.split(",").join(" ").split(" ")
			unless player_input.length == 2
				invalid "Please enter your move as TWO positions separated by a space and/or comma"
			end
			player_input
		end		
	end

  # Get and handle an in-game option chosen by a player
	def set_in_game_options
		options = [ "Resign (Loss for #{@cur_player.name})", "Offer Draw to #{opponent.name}", 
			          "Claim Draw by Threefold Repetition", "Claim Draw by Fifty-Move Rule", 
			          "Save (with #{opponent.name}'s consent)", "Exit"]
		options_title = "In Game Options for #{@cur_player.name}"
		choice = Chess.get_option_choice(options, options_title)

		handle_in_game_choice choice
		@chessboard.display_board
	end

  # Controller for Chess in-game menu
	def handle_in_game_choice choice
		case choice
		when 1 then	end_game(:resign)
		when 2 then set_draw_option(:draw_offer)
		when 3 then set_draw_option(:three_repetition)
		when 4 then set_draw_option(:fifty_move)
		when 5 then save_protocol
		end
	end

  # Store option chosen by player to be handled after the player's next move
	def set_draw_option option
		message        = "\n#{@cur_player.name}, you must still make your next move.\n"
		draw_offer_msg = "Your draw offer will be presented to #{opponent.name} after your move."
		draw_claim_msg = "Your draw claim will be considered before and after your move."

		message += if option == :draw_offer
			           draw_offer_msg
			         else
			         	 draw_claim_msg
			         end
		Chess.display_message message
		@input[:option] = option
	end

  # Process (betweeen a player and his/her opponent) to save a game
	def save_protocol
		message = "Your opponent must agree to save the game. Seeking #{opponent.name}'s consent..."
		Chess.display_message(message + "\n")
		save =  Chess.yes_or_no("#{opponent.name}, do you accept #{@cur_player.name}'s offer to save the game")
		if save
			Chess.display_message "#{@cur_player.name}, #{opponent.name} accepted your save request."
			save_game
		else
			Chess.warn_message "#{@cur_player.name}, #{opponent.name} denied your save request. Please make your next move"
		end
	end

	# Save a chess game in progress
	def save_game
		all_saved_games = Chess.yaml_load(Chess::GAMES_FILE)
		game_name = get_save_name(all_saved_games)
		return if game_name.nil?

		game_string = self.to_yaml
		all_saved_games[game_name] = game_string
		Chess.yaml_save(Chess::GAMES_FILE, all_saved_games)
		Chess.message_then_enter "'#{game_name}' was successfully saved."
		throw :game_saved
	end

	# Get the name that the chess game in progress will be saved as
	def get_save_name all_saved_games
		game_names = all_saved_games.keys

		loop do
			game_name = Chess.get_input_for_prompt "#{@cur_player.name}, Enter name to save game as"
			return game_name unless game_names.include? game_name

			return game_name if Chess.yes_or_no "'#{game_name}' already exists. Overwrite it"
			next if Chess.yes_or_no "Save game with a different name"

			Chess.message_then_enter "#{@cur_player.name}, you chose to not save this game."
			return nil
		end
	end

  # Determine the current player's opponent
	def opponent
		@players.select { |player| player.color != @cur_player.color }.first
	end

  # Display instructional message for game play
	def display_welcome_message
    message = <<-END.gsub(/^\s+\|/, '')
      |Make a move by entering two positions on the chess board separated by
      |a space and/or comma. Enter a position as a letter then a number. An
      |example position is 'a2' and example moves are 'a2,b3' or 'a2 b3' or
      |'a2, b3' (you may also enter 'a2b3'). Enter the letter 'o' from the move
      |prompt to access the options available during a chess game. For some of
      |the options, you will still be required to indicate your next move.
      |
	  END
	  Chess.display_message message		
	end

end
