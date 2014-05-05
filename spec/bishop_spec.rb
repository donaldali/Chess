#
require_relative '../lib/chess/bishop'

describe Bishop do 
	let(:piece_colors) {
	   [ [:black, :black, :black, :black, :black, :black, :black, :black],
		   [:black, :black, :black, :black, :black, :black, :black, :black],
		   [ nil,   :black,  nil,    nil,    nil,    nil,    nil,    nil  ],
  	   [ nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil  ],
	  	 [ nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil  ],
		   [ nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil  ],
		   [:white, :white, :white, :white, :white, :white, :white, :white],
	     [:white, :white, :white, :white, :white, :white,  nil,   :white] ]
		}
	let(:bishop) { Bishop.new }

	describe '#possible_positions' do
		it 'stops before board boundary and friendly piece, but at enemy piece' do
			bishop.position = [6, 5]
			bishop.color = :white
			bishop.type = :bishop
			# *************************
			# *** REMOVE BELOW LINE ***
			# *************************
			bishop.chessboard = piece_colors

			expect(bishop.possible_positions).to match_array([[7, 6], [5, 6], [4, 7], [5, 4],
				                                                [4, 3], [3, 2], [2, 1]])
	  end
	end
end
