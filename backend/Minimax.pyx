# minimax.pyx

import time
import math
from Board import Board
from functools import lru_cache
cimport cython

cdef class Minimax:
    cdef int evaluation_count
    cdef int WIN_SCORE
    cdef Board board

    def __init__(self, Board board):
        self.evaluation_count = 0
        self.WIN_SCORE = 100_000_000
        self.board = board

    @staticmethod
    def get_win_score():
        return Minimax.WIN_SCORE

    @staticmethod
    def evaluate_board_for_white(board, blacks_turn):
        Minimax.evaluation_count += 1
        black_score = Minimax.get_score(board, True, blacks_turn)
        white_score = Minimax.get_score(board, False, blacks_turn)
        if black_score == 0:
            black_score = 1.0
        return white_score / black_score

    @staticmethod
    def get_score(board, for_black, blacks_turn):
        board_matrix = board.board_matrix
        return (Minimax.evaluate_horizontal(board_matrix, for_black, blacks_turn) +
                Minimax.evaluate_vertical(board_matrix, for_black, blacks_turn) +
                Minimax.evaluate_diagonal(board_matrix, for_black, blacks_turn))

    @cython.locals(depth=int)
    @lru_cache(None)
    def calculate_next_move(self, int depth):
        cdef list move = [0, 0]
        start_time = time.time()
        best_move = Minimax.search_winning_move(self.board)
        if best_move is not None:
            move[0] = int(best_move[1])
            move[1] = int(best_move[2])
        else:
            best_move = Minimax.minimax_search_ab(depth, self.board, True, -1.0, self.get_win_score())
            if best_move[1] is None:
                move = None
            else:
                move[0] = int(best_move[1])
                move[1] = int(best_move[2])
        print(f"Cases calculated: {Minimax.evaluation_count} Calculation time: {time.time() - start_time:.2f} s")
        Minimax.evaluation_count = 0
        return move

    @staticmethod
    def minimax_search_ab(int depth, dummy_board, bint max, float alpha, float beta):
        if depth == 0:
            return [Minimax.evaluate_board_for_white(dummy_board, not max), None, None]
        all_possible_moves = dummy_board.generate_moves()
        if all_possible_moves is None:
            return [Minimax.evaluate_board_for_white(dummy_board, not max), None, None]
        best_move = [None] * 3

        if max:
            best_move[0] = -1.0
            for move in all_possible_moves:
                dummy_board.add_stone(move[1], move[0], False)
                temp_move = Minimax.minimax_search_ab(depth - 1, dummy_board, False, alpha, beta)
                dummy_board.remove_stone_no_gui(move[1], move[0])
                if temp_move[0] > alpha:
                    alpha = temp_move[0]
                if temp_move[0] >= beta:
                    return temp_move
                if temp_move[0] > best_move[0]:
                    best_move = temp_move
                    best_move[1] = move[0]
                    best_move[2] = move[1]

        else:
            best_move[0] = 100_000_000.0
            best_move[1] = all_possible_moves[0][0]
            best_move[2] = all_possible_moves[0][1]
            for move in all_possible_moves:
                dummy_board.add_stone(move[1], move[0], True)
                temp_move = Minimax.minimax_search_ab(depth - 1, dummy_board, True, alpha, beta)
                dummy_board.remove_stone_no_gui(move[1], move[0])
                if temp_move[0] < beta:
                    beta = temp_move[0]
                if temp_move[0] <= alpha:
                    return temp_move
                if temp_move[0] < best_move[0]:
                    best_move = temp_move
                    best_move[1] = move[0]
                    best_move[2] = move[1]
        return best_move

    @staticmethod
    def search_winning_move(board):
        all_possible_moves = board.generate_moves()
        winning_move = [None] * 3
        for move in all_possible_moves:
            Minimax.evaluation_count += 1
            dummy_board = board.copy_board()
            dummy_board.add_stone(move[1], move[0], False)
            if Minimax.get_score(dummy_board, False, False) >= Minimax.get_win_score():
                winning_move[1] = move[0]
                winning_move[2] = move[1]
                return winning_move
        return None

    @staticmethod
    def evaluate_horizontal(board_matrix, for_black, players_turn):
        evaluations = [0, 2, 0]
        for i in range(len(board_matrix)):
            for j in range(len(board_matrix[0])):
                Minimax.evaluate_directions(board_matrix, i, j, for_black, players_turn, evaluations)
            Minimax.evaluate_directions_after_one_pass(evaluations, for_black, players_turn)

        return evaluations[2]

    @staticmethod
    def evaluate_vertical(board_matrix, for_black, players_turn):
        evaluations = [0, 2, 0]
        for j in range(len(board_matrix[0])):
            for i in range(len(board_matrix)):
                Minimax.evaluate_directions(board_matrix, i, j, for_black, players_turn, evaluations)
            Minimax.evaluate_directions_after_one_pass(evaluations, for_black, players_turn)
        return evaluations[2]

    @staticmethod
    def evaluate_diagonal(board_matrix, for_black, players_turn):
        evaluations = [0, 2, 0]
        for k in range(2 * len(board_matrix) - 1):
            i_start = max(0, k - len(board_matrix) + 1)
            i_end = min(len(board_matrix) - 1, k)
            for i in range(i_start, i_end + 1):
                Minimax.evaluate_directions(board_matrix, i, k - i, for_black, players_turn, evaluations)
            Minimax.evaluate_directions_after_one_pass(evaluations, for_black, players_turn)
        for k in range(1 - len(board_matrix), len(board_matrix)):
            i_start = max(0, k)
            i_end = min(len(board_matrix) + k - 1, len(board_matrix) - 1)
            for i in range(i_start, i_end + 1):
                Minimax.evaluate_directions(board_matrix, i, i - k, for_black, players_turn, evaluations)
            Minimax.evaluate_directions_after_one_pass(evaluations, for_black, players_turn)
        return evaluations[2]

    @staticmethod
    def evaluate_directions(board_matrix, int i, int j, bint is_bot, bint bots_turn, eval):
        if board_matrix[i][j] == (2 if is_bot else 1):
            eval[0] += 1
        elif board_matrix[i][j] == 0:
            if eval[0] > 0:
                eval[1] -= 1
                eval[2] += Minimax.get_consecutive_set_score(eval[0], eval[1], is_bot == bots_turn)
                eval[0] = 0
            eval[1] = 1 
        elif eval[0] > 0:
                eval[2] += Minimax.get_consecutive_set_score(eval[0], eval[1], is_bot == bots_turn)
                eval[0] = 0
                eval[1] = 2
        else: 
            eval[1] = 2

    @staticmethod
    def evaluate_directions_after_one_pass(eval, bint is_bot, bint players_turn):
        if eval[0] > 0:
            eval[2] += Minimax.get_consecutive_set_score(eval[0], eval[1], is_bot == players_turn)
        eval[0] = 0
        eval[1] = 2

    @staticmethod
    def get_consecutive_set_score(int count, int blocks, bint current_turn):
        cdef int win_guarantee = 1000000
        if blocks == 2 and count < 5:
            return 0
        if count == 5:
            return Minimax.WIN_SCORE
        elif count == 4:
            if current_turn:
                return win_guarantee
            else:
                return win_guarantee // 4 if blocks == 0 else 200
        elif count == 3:
            if blocks == 0:
                return 50_000 if current_turn else 200
            else:
                return 10 if current_turn else 5
        elif count == 2:
            return 7 if blocks == 0 and current_turn else 5 if blocks == 0 else 3
        elif count == 1:
            return 1
        return Minimax.WIN_SCORE * 2
