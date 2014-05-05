#
require_relative '../lib/chess/pawn'

describe Pawn do 
	let(:piece_colors) {
	   [ [:black, :black, :black,  nil,   :black, :black, :black, :black],
		   [:black, :black, :black,  nil,   :black,  nil,   :black, :black],
		   [ nil,   :black,  nil,    nil,    nil,    nil,   :white, :white],
  	   [ nil,    nil,    nil,    nil,    nil,   :black, :white,  nil  ],
	  	 [ nil,    nil,   :white,  nil,   :black,  nil,    nil,    nil  ],
		   [ nil,   :black,  nil,   :white,  nil,    nil,    nil,    nil  ],
		   [:white, :white, :white,  nil,   :white, :white, :white, :white],
	     [:white, :white, :white, :white, :white, :white, :white, :white] ]
		}
	let(:pawn) { Pawn.new }

	describe '#possible_positions' do
		it 'can take one or two steps on first move' do
			pawn.position = [6, 0]
			pawn.color = :white
			pawn.type = :pawn
			# *************************
			# *** REMOVE BELOW LINE ***
			# *************************
			pawn.chessboard = piece_colors

			expect(pawn.possible_positions).to match_array([[5, 0], [4, 0], [5, 1]])
	  end
	  it 'can take only one step after first move' do
			pawn.position = [4, 4]
			pawn.color = :black
			pawn.type = :pawn
			pawn.moved = true
			# *************************
			# *** REMOVE BELOW LINE ***
			# *************************
			pawn.chessboard = piece_colors

			expect(pawn.possible_positions).to match_array([[5, 4], [5, 3]])
	  end
	  it 'includes en passant' do
			pawn.position = [3, 6]
			pawn.color = :white
			pawn.type = :pawn
			pawn.moved = true
			# *************************
			# *** REMOVE BELOW LINE ***
			# *************************
			pawn.chessboard = piece_colors

			expect(pawn.possible_positions).to match_array([])
			# USE FOR EN PASSANT
			# expect(pawn.possible_positions).to match_array([[2, 5]])
	  end
	end
end
