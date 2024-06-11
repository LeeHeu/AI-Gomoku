import time
from Board import *
from  backend.app import *

board = GameClient(host, 1, 1, 2, 'x')
board.size = 6
board.board = [[' ', ' ', ' ', ' ', ' ', ' '],
                [' ', ' ', ' ', ' ', ' ', ' '],
                [' ', ' ', ' ', ' ', ' ', ' '],
                [' ', ' ', ' ', ' ', ' ', ' '],
                [' ', ' ', ' ', ' ', ' ', ' '],
                [' ', ' ', ' ', ' ', ' ', ' ']]

# newBoard = board.convert_char_to_num('x')
# AIBoard = Board(6)
# AIBoard.board_matrix = newBoard

# ai = Minimax(AIBoard)
# AImove = ai.calculate_next_move(4)
# move = AImove
# print("Move: ", move)
# board.board[int(move[0])][int(move[1])] = 'x'
# newBoard = board.convert_char_to_num('x')

print(board.FIRST_MOVE())
# for i in range(6):
#     print(newBoard[i])

