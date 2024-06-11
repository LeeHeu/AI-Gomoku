import Board
import Game
from Minimax import *

board = Board(8)
# print(board.get_board_matrix())

game = Game.Game(board)
game.run()