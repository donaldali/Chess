#
require_relative '../lib/chess/queen'

describe Queen do 
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
	let(:queen) { Queen.new }

	describe '#possible_positions' do
		it 'stops before board boundary and friendly piece, but at enemy piece' do
			queen.position = [4, 3]
			queen.color = :white
			queen.type = :queen
			# *************************
			# *** REMOVE BELOW LINE ***
			# *************************
			queen.chessboard = piece_colors

			expect(queen.possible_positions).to match_array(
				[[3, 3], [2, 3], [1, 3], [0, 3], [5, 3], [6, 3], [4, 2], [4, 1], [4, 0],
				 [4, 4], [3, 4], [2, 5], [1, 6], [3, 2], [2, 1], [5, 2], [5, 4]])
	  end
	end
end
