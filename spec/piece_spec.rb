require 'spec_helper'

describe Piece do 
	let(:chessboard) { Chessboard.new }

	describe '.create' do 
		let(:piece) { Piece.create(:black, [4, 2], :king, chessboard) }
		it 'creates the type of piece specified' do
			expect(piece.type).to eq(:king)
		end
		it 'creates the color of piece specified' do
			expect(piece.color).to eq(:black)
		end
		it 'sets the position specified' do
			expect(piece.position).to eq([4, 2])
		end
	end

	describe '#move_positions' do
		let(:rook)       { chessboard.piece_at([7, 0]) }
		let(:white_pawn) { chessboard.piece_at([6, 1]) }
		let(:black_pawn) { chessboard.piece_at([1, 0]) }
		
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
