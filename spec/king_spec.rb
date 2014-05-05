#
require_relative '../lib/chess/king'

describe King do 
	let(:piece_colors) {
	   [ [:black, :black, :black,  nil,   :black, :black, :black, :black],
		   [:black, :black, :black,  nil,   :black, :black, :black, :black],
		   [ nil,   :black,  nil,    nil,    nil,    nil,    nil,    nil  ],
  	   [ nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil  ],
	  	 [ nil,    nil,    nil,   :white, :black,  nil,    nil,    nil  ],
		   [ nil,    nil,    nil,    nil,    nil,    nil,    nil,    nil  ],
		   [:white, :black, :white,  nil,   :white, :white, :white, :white],
	     [:white, :white, :white, :white, :white, :white, :white, :white] ]
		}
	let(:king) { King.new }

	describe '#possible_positions' do
		it 'steps to empty and open squares only' do
			king.position = [6, 0]
			king.color = :white
			king.type = :king
			# *************************
			# *** REMOVE BELOW LINE ***
			# *************************
			king.chessboard = piece_colors

			expect(king.possible_positions).to match_array([[5, 0], [5, 1], [6, 1]])
	  end

	  # it 'handles en passant'
	end
end
