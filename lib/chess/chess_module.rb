#
module Chess
	SIZE = 8

	def other_player(player)
		player == :white ? :black : :white
	end
end
