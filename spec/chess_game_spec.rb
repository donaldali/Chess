require 'spec_helper'

describe ChessGame do 
  let(:chess_game) { ChessGame.new }
  before(:each) do
    allow(Chess).to receive(:puts)
    allow(Chess).to receive(:print)
  end

  describe '#play' do 
    it 'ends game when checkmate occurs' do
      allow(Chess).to receive(:gets).and_return("White Player\n", 
        "Black Player\n", "f2 f3\n", "e7 e5\n", "g2 g4\n", "d8 h4\n", "n\n")
      expect(chess_game).to receive(:end_game).with(:checkmate).and_call_original
      chess_game.play
    end  
    it 'allows a player to resign' do
      allow(Chess).to receive(:gets).and_return("White Player\n", 
        "Black Player\n", "c2 c4\n", "o\n", "1\n", "n\n")
      expect(chess_game).to receive(:end_game).with(:resign).and_call_original
      chess_game.play
    end 
    it 'ends game when stalemate occurs' do
      allow(Chess).to receive(:gets).and_return("White Player\n", 
        "Black Player\n", "e2 e3\n", "a7 a5\n", "d1 h5\n", "a8 a6\n",
        "h5 a5\n", "h7 h5\n", "a5 c7\n", "a6 h6\n", "h2 h4\n", "f7 f6\n",
        "c7 d7\n", "e8 f7\n", "d7 b7\n", "d8 d3\n", "b7 b8\n", "d3 h7\n",
        "b8 c8\n", "f7 g6\n", "c8 e6\n", "n\n")
      expect(chess_game).to receive(:end_game).with(:stalemate).and_call_original
      chess_game.play
    end
    it 'allows players to draw by agreement' do
      allow(Chess).to receive(:gets).and_return("White Player\n", 
        "Black Player\n", "d2 d4\n", "o\n", "2\n", "f7 f5\n", "y\n", "n\n")
      expect(chess_game).to receive(:end_game).with(:draw_offer).and_call_original
      chess_game.play
    end 
    it 'detects draw by threefold repetition when requested' do
      allow(Chess).to receive(:gets).and_return("White Player\n", 
        "Black Player\n", "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", "b1 c3\n", 
        "b8 c6\n", "c3 b1\n", "c6 b8\n", "o\n", "3\n", "b1 c3\n", "n\n")
      expect(chess_game).to receive(:end_game).with(:three_repetition).and_call_original
      chess_game.play
    end
    it 'detects draw by fifty-move rule when requested' do
      allow(Chess).to receive(:gets).and_return("White Player\n", 
        "Black Player\n", "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", 
        "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", 
        "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", 
        "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", 
        "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", 
        "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", 
        "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", 
        "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", 
        "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", 
        "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", 
        "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", 
        "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", 
        "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", "b1 c3\n", "b8 c6\n", "c3 b1\n", "c6 b8\n", 
        "o\n", "4\n", "b1 c3\n",  "n\n")
      expect(chess_game).to receive(:end_game).with(:fifty_move).and_call_original
      chess_game.play
    end
    it 'ends game when impossibility of checkmate occurs' do 
      chess_game.chessboard = clear_board
      chess_game.chessboard.set_square([7, 1], Knight.new(:white, [7, 1], chess_game.chessboard))
      chess_game.chessboard.set_square([7, 4],   King.new(:white, [7, 4], chess_game.chessboard))
      chess_game.chessboard.set_square([0, 4],   King.new(:black, [0, 4], chess_game.chessboard))
      chess_game.chessboard.set_square([5, 2],  Queen.new(:black, [5, 2], chess_game.chessboard))
      chess_game.chessboard.set_square([3, 3], Knight.new(:black, [3, 3], chess_game.chessboard))

      allow(Chess).to receive(:gets).and_return("White Player\n", 
        "Black Player\n", "b1 c3\n", "d5 c3\n", "n\n")
      expect(chess_game).to receive(:end_game).with(:no_checkmate).and_call_original
      chess_game.play
    end
  end

end
