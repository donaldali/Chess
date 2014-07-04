require 'spec_helper'

describe Queen do 
  let(:piece_colors) {
     [ [:black, :black, :black, :clear, :black, :black, :black, :black],
       [:black, :black, :black, :clear, :black, :black, :black, :black],
       [:clear, :black, :clear, :clear, :clear, :clear, :clear, :clear],
       [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
       [:clear, :clear, :clear, :white, :black, :clear, :clear, :clear],
       [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
       [:white, :white, :white, :clear, :white, :white, :white, :white],
       [:white, :white, :white, :white, :white, :white, :clear, :white] ]
    }
  let(:chessboard) { Chessboard.new }
  let(:queen) { chessboard.piece_at([7, 3]) }

  describe '#possible_positions' do
    it 'stops before board boundary and friendly piece, but at enemy piece' do
      allow(chessboard).to receive(:get_piece_colors).and_return(piece_colors)
      chessboard.set_square([4, 3], queen)
      expect(queen.possible_positions).to match_array(
        [[3, 3], [2, 3], [1, 3], [0, 3], [5, 3], [6, 3], [4, 2], [4, 1], [4, 0],
         [4, 4], [3, 4], [2, 5], [1, 6], [3, 2], [2, 1], [5, 2], [5, 4]])
    end
  end
end
