#
require_relative '../lib/chess/piece'
require_relative '../lib/chess/chessboard'

describe Piece do 
	# let(:piece_colors) {
	#    [ [:black, :black, :black, :black, :black, :black, :black, :black],
	# 	   [:black, :black, :black, :black, :black, :black, :black, :black],
 #  	   [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
 #  	   [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
 #  	   [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
 #  	   [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
	# 	   [:white, :white, :white, :white, :white, :white, :white, :white],
	#      [:white, :white, :white, :white, :white, :white, :clear, :white] ]
	# 	}
	let(:chessboard) { Chessboard.new }
	let(:rook) { chessboard.piece_at([7, 0]) }
	let(:white_pawn) { chessboard.piece_at([6, 1]) }
	let(:black_pawn) { chessboard.piece_at([1, 0]) }

	describe '#move_positions' do
		it 'only recognizes positions that would not leave King in check' do 
			chessboard.clear_square([6, 4])
			chessboard.set_square([4, 4], rook)
			chessboard.set_square([2, 4], Rook.new(:black, [2, 4], chessboard))
			expect(rook.move_positions).to match_array([ [2, 4], [3, 4], [5, 4], [6, 4] ])
		end
		it 'includes en passant position' do
			chessboard.en_passant_position = [2, 0]
			chessboard.set_square([3, 1], white_pawn)
			chessboard.set_square([3, 0], black_pawn)
			expect(white_pawn.move_positions).to match_array([ [2, 1], [2, 0] ])
		end
	end
end
