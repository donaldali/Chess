require_relative '../lib/chess/chessboard'

#
describe Chessboard do 
	let(:chessboard) { Chessboard.new }

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
			chessboard.set_square(3, 3, piece)
			expect(chessboard.squares[3][3].piece.position).to eq([3, 3])
		end
	end

	describe '#clear_square' do
		it 'clears the piece in a square' do
			expect(chessboard.squares[0][0].piece.type).to eq(:rook)
			chessboard.clear_square(0, 0)
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
	  	chessboard.set_square(5, 3, Knight.new(:black, [5, 3], chessboard))
	  	expect(chessboard.check?(:white)).to be_true
		end
		it 'knows when check does not exist' do
	  	expect(chessboard.check?(:white)).to be_false
		end
	end

end
