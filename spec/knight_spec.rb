#
require_relative '../lib/chess/knight'

describe Knight do 
	let(:piece_colors) {
	   [ [:black, :black, :black,  nil,   :black, :black, :black, :black],
		   [:black, :black, :black,  nil,   :black, :black, :black,  nil  ],
		   [ nil,   :black,  nil,    nil,    nil,    nil,    nil,   :black],
  	   [ nil,    nil,    nil,    nil,   :black,  nil,    nil,    nil  ],
	  	 [ nil,    nil,    nil,   :white, :black,  nil,   :white,  nil  ],
		   [ nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil  ],
		   [:white, :white, :white,  nil,   :white, :white, :white, :white],
	     [:white, :white, :white, :white, :white, :white,  nil,   :white] ]
		}
	let(:knight) { Knight.new }

	describe '#possible_positions' do
		it 'jumps onto blank and enemy pieces, but not on friendly pieces' do
			knight.position = [4, 6]
			knight.color = :white
			knight.type = :knight
			# *************************
			# *** REMOVE BELOW LINE ***
			# *************************
			knight.chessboard = piece_colors

			expect(knight.possible_positions).to match_array([[3, 4], [5, 4], [2, 5], [2, 7]])
	  end
	end
end
