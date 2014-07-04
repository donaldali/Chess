require 'spec_helper'

describe Knight do 
  let(:piece_colors) {
     [ [:black, :black, :black, :clear, :black, :black, :black, :black],
       [:black, :black, :black, :clear, :black, :black, :black, :clear],
       [:clear, :black, :clear, :clear, :clear, :clear, :clear, :black],
       [:clear, :clear, :clear, :clear, :black, :clear, :clear, :clear],
       [:clear, :clear, :clear, :white, :black, :clear, :white, :clear],
       [:clear, :clear, :clear, :clear, :clear, :clear, :clear, :clear],
       [:white, :white, :white, :clear, :white, :white, :white, :white],
       [:white, :white, :white, :white, :white, :white, :clear, :white] ]
    }
  let(:chessboard) { Chessboard.new }
  let(:knight) { chessboard.piece_at([7, 6]) }

  describe '#possible_positions' do
    it 'jumps onto blank and enemy pieces, but not on friendly pieces' do
      allow(chessboard).to receive(:get_piece_colors).and_return(piece_colors)
      chessboard.set_square([4, 6], knight)
      expect(knight.possible_positions).to match_array([[3, 4], [5, 4], [2, 5], [2, 7]])
    end
  end
end
