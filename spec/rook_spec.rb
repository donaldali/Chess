#
require_relative '../lib/chess/rook'

describe Rook do 
	let(:piece_colors) {
	   [ [:black, :black, :black,  nil,   :black, :black, :black, :black],
		   [:black, :black, :black,  nil,   :black, :black, :black, :black],
		   [ nil,   :black,  nil,    nil,    nil,    nil,    nil,    nil  ],
  	   [ nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil  ],
	  	 [ nil,    nil,    nil,   :white, :black,  nil,    nil,    nil  ],
		   [ nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil  ],
		   [:white, :white, :white,  nil,   :white, :white, :white, :white],
	     [:white, :white, :white, :white, :white, :white,  nil,   :white] ]
		}
	let(:rook) { Rook.new }

	describe '#possible_positions' do
		it 'stops before board boundary and friendly piece, but at enemy piece' do
			rook.position = [4, 3]
			rook.color = :white
			rook.type = :rook
			# *************************
			# *** REMOVE BELOW LINE ***
			# *************************
			rook.chessboard = piece_colors

			expect(rook.possible_positions).to match_array(
				[[3, 3], [2, 3], [1, 3], [0, 3], [5, 3], [6, 3], [4, 2], [4, 1], [4, 0], [4, 4]])
	  end
	end
end
