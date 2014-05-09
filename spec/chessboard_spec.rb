require_relative '../lib/chess/chessboard'

#
describe Chessboard do 
	let(:chessboard) { Chessboard.new }
	before(:each) do
		allow(Chess).to receive(:puts)
		allow(Chess).to receive(:print)
	end

	describe '#new' do 
		it "creates an #{Chessboard::SIZE} X #{Chessboard::SIZE} array of squares" do 
			expect(chessboard.squares.size).to eq(Chessboard::SIZE)
			chessboard.squares.each do |row|
				expect(row.size).to eq(Chessboard::SIZE)
				row.each do |square|
					expect(square).to be_instance_of(Chessboard::Square)
				end
			end
		end
		it 'initializes en passant' do 
			expect(chessboard.en_passant_position).to be_nil
		end
		it 'initializes no capture/pawn move count' do 
			expect(chessboard.no_capture_or_pawn_moves).to be_zero
		end
	end

	describe '#set_square' do
		it 'sets the piece in a square' do
			piece = Piece.new(:clear)
			expect(chessboard.squares[3][3].piece.position).to be_nil
			chessboard.set_square([3, 3], piece)
			expect(chessboard.squares[3][3].piece.position).to eq([3, 3])
		end
	end

	describe '#clear_square' do
		it 'clears the piece in a square' do
			expect(chessboard.squares[0][0].piece.type).to eq(:rook)
			chessboard.clear_square([0, 0])
			expect(chessboard.squares[0][0].piece.type).to be_nil
		end
	end

	describe '#get_piece_colors' do
		it 'creates an array of the colors of chessboard pieces' do 
			expect(chessboard.get_piece_colors).to eq([ 
			 [:black, :black, :black, :black, :black, :black, :black, :black],
		   [:black, :black, :black, :black, :black, :black, :black, :black],
		   [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
		   [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
		   [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
		   [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
		   [:white, :white, :white, :white, :white, :white, :white, :white],
	     [:white, :white, :white, :white, :white, :white, :white, :white] ])
		end
	end

	describe '#positions_attacked_by' do 
		it 'gives initial positions white pieces attack' do 
			expect(chessboard.positions_attacked_by(:white)).to match_array( 
				[ [4, 0], [4, 1], [4, 2], [4, 3], [4, 4], [4, 5], [4, 6], [4, 7], 
				  [5, 0], [5, 1], [5, 2], [5, 3], [5, 4], [5, 5], [5, 6], [5, 7] ])
		end
		it 'gives initial positions black pieces attack' do 
			expect(chessboard.positions_attacked_by(:black)).to match_array( 
				[ [2, 0], [2, 1], [2, 2], [2, 3], [2, 4], [2, 5], [2, 6], [2, 7], 
				  [3, 0], [3, 1], [3, 2], [3, 3], [3, 4], [3, 5], [3, 6], [3, 7] ])
		end

		#  **** MORE TESTS ***
		# it 'gives initial positions attacked'
	end

	describe '#king_position' do
		it "finds black king's initial position" do
			expect(chessboard.king_position(:black)).to eq([0, 4])
		end
		it "finds white king's initial position" do
			expect(chessboard.king_position(:white)).to eq([7, 4])
		end
	end

	describe '#check?' do 
		it 'recognizes check condition' do 
	  	chessboard.set_square([5, 3], Knight.new(:black, [5, 3], chessboard))
	  	expect(chessboard.check?(:white)).to be_true
		end
		it 'knows when check does not exist' do
	  	expect(chessboard.check?(:white)).to be_false
		end
	end

	describe '#move_piece' do 
		it 'moves a piece at a location' do 
			expect(chessboard.piece_at([1, 0]).type).to eq(:pawn)
			expect(chessboard.move_piece([0, 0], [1, 0]).type).to eq(:pawn)
			expect(chessboard.piece_at([1, 0]).type).to eq(:rook)
			expect(chessboard.piece_at([0, 0]).type).to be_nil
		end
	end

	describe '#get_castle_direction' do 
		before(:each) do
		  chessboard.clear_square([7, 1])
		  chessboard.clear_square([7, 2])
		  chessboard.clear_square([7, 3])
		  chessboard.clear_square([7, 5])
		  chessboard.clear_square([7, 6])

		  chessboard.clear_square([0, 1])
		  chessboard.clear_square([0, 2])
		  chessboard.clear_square([0, 3])
		  chessboard.clear_square([0, 5])
		  chessboard.clear_square([0, 6])
		end
		it 'recognizes initial castle direction' do 
			new_chessboard = Chessboard.new
			expect(new_chessboard.get_castle_direction).to eq([[], []])
		end
		it 'recognizes all castle directions' do 
			expect(chessboard.get_castle_direction).to eq([[:left, :right], [:left, :right]])
		end
		it 'recognizes all white castle directions' do 
			chessboard.piece_at(chessboard.king_position(:black)).moved = true
			expect(chessboard.get_castle_direction).to eq([[], [:left, :right]])
		end
		it 'recognizes all black castle directions' do 
			chessboard.piece_at(chessboard.king_position(:white)).moved = true
			expect(chessboard.get_castle_direction).to eq([[:left, :right], []])
		end
		it 'recognizes partial black/white castle directions' do 
			chessboard.piece_at([0, 0]).moved = true
			chessboard.piece_at([7, 7]).moved = true
			expect(chessboard.get_castle_direction).to eq([[:right], [:left]])
		end
	end

	describe '#move' do
		shared_examples_for "moving a piece" do |from, to|

			it 'moves piece to new position' do
				from_piece = chessboard.piece_at(from)
				chessboard.move(from, to)
				# expect(chessboard.piece_at(to)).to be(from_piece)
				expect(chessboard.piece_at(to)).to eq(from_piece)
			end
			it "sets piece's position to new position" do
				from_piece = chessboard.piece_at(from)
				chessboard.move(from, to)
				expect(from_piece.position).to eq(to)
			end
			it 'clears the old position' do 
				from_piece = chessboard.piece_at(from)
				chessboard.move(from, to)
				expect(chessboard.clear_position?(from)).to be_true
			end
		end

		context 'when a simple non-pawn move is made' do 
			it_should_behave_like "moving a piece", [7, 1], [5, 0]
			it 'sets en passant positon to nil' do
				chessboard.en_passant_position = [2, 1]
				chessboard.move([7, 1], [5, 0])
				expect(chessboard.en_passant_position).to be_nil
			end
			it 'increases no capture or pawn move count' do
				expect{chessboard.move([7, 1], [5, 0])}.to change{chessboard.no_capture_or_pawn_moves}.by(1)
			end
		end
		context 'when an opponent piece is captured' do 
			it_should_behave_like "moving a piece", [6, 0], [1, 0]
			it 'resets no capture or pawn move count' do
				chessboard.no_capture_or_pawn_moves = 1
				chessboard.move([6, 0], [1, 0])
				expect(chessboard.no_capture_or_pawn_moves).to be_zero
			end
		end
		context 'when a pawn moves' do 
			it_should_behave_like "moving a piece", [6, 1], [5, 1]
			it 'resets no capture or pawn move count' do 
				chessboard.no_capture_or_pawn_moves = 1
				chessboard.move([6, 1], [5, 1])
				expect(chessboard.no_capture_or_pawn_moves).to be_zero
			end
			it 'sets en passant position when appropriate'do 
				chessboard.move([6, 1], [4, 1])
				expect(chessboard.en_passant_position).to eq([5, 1])
			end
			it 'handles en passant move when appropriate' do 
				chessboard.move([1, 2], [4, 2])
				chessboard.move([6, 1], [4, 1])
				chessboard.move([4, 2], [5, 1])
				expect(chessboard.clear_position?([4, 1])).to be_true
				expect(chessboard.en_passant_position).to be_nil
			end
			it 'promotes pawn piece when appropriate' do
				allow(Chess).to receive(:gets).and_return("1")
				chessboard.move([6, 1], [0, 1])
				expect(chessboard.piece_at([0, 1]).type).to be(:queen)
			end
		end

		context 'when castling move is made' do 
			before(:each) do
				chessboard.clear_square([7, 5])
				chessboard.clear_square([7, 6])
			end
			it 'handles single castling posibility' do
				chessboard.move([7, 4], [7, 6])
				expect(chessboard.clear_position?([7, 4])).to be_true
				expect(chessboard.piece_at([7, 5]).type).to be(:rook)
				expect(chessboard.piece_at([7, 6]).type).to be(:king)
				expect(chessboard.clear_position?([7, 7])).to be_true
			end
			it 'handles all castling posibilities' do
				chessboard.clear_square([7, 1])
				chessboard.clear_square([7, 2])
				chessboard.clear_square([7, 3])

				chessboard.clear_square([0, 1])
				chessboard.clear_square([0, 2])
				chessboard.clear_square([0, 3])
				chessboard.clear_square([0, 5])
				chessboard.clear_square([0, 6])

				chessboard.move([0, 4], [0, 6])
				expect(chessboard.clear_position?([0, 4])).to be_true
				expect(chessboard.piece_at([0, 5]).type).to be(:rook)
				expect(chessboard.piece_at([0, 6]).type).to be(:king)
				expect(chessboard.clear_position?([0, 7])).to be_true
			end
		end
		
		
	end

end
