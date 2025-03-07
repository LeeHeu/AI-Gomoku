import backend.Board
import Game
from backend.Minimax import *

board = Board(15)
# print(board.get_board_matrix())

game = Game.Game(board)
game.run()