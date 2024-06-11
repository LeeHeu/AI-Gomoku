class Board:
    board_matrix = None
    def __init__(self, board_size):
        self.board_matrix = [[0 for _ in range(board_size)] for _ in range(board_size)]
      
    def copy_board(self):
        new_board = Board(len(self.board_matrix))
        new_board.board_matrix = [row[:] for row in self.board_matrix]
        return new_board
        

    def get_board_size(self):
        return len(self.board_matrix)

    def remove_stone_no_gui(self, pos_x, pos_y):
        self.board_matrix[pos_y][pos_x] = 0

    # def add_stone_no_gui(self, pos_x, pos_y, black):
    #     if self.board_matrix[pos_x][pos_y] != 0:
    #         return
    #     self.board_matrix[pos_x][pos_y] = 2 if black else 1

    def add_stone(self, pos_x, pos_y, black):
        # check if the cell is empty
        if self.board_matrix[pos_y][pos_x] != 0:
            return False
        self.board_matrix[pos_y][pos_x] = 2 if black else 1
        return True

    def generate_moves(self):
        board_matrix = self.board_matrix
        move_list = []
        board_size = board_matrix.__len__()

        for i in range(board_size):
            for j in range(board_size):
                if board_matrix[i][j] > 0:
                    continue
                if i > 0:
                    if j > 0:
                        if board_matrix[i - 1][j - 1] > 0 or board_matrix[i][j - 1] > 0:
                            move = [i, j]
                            move_list.append(move)
                            continue
                    if j < board_size - 1:
                        if board_matrix[i - 1][j + 1] > 0 or board_matrix[i][j + 1] > 0:
                            move = [i, j]
                            move_list.append(move)
                            continue
                    if board_matrix[i - 1][j] > 0:
                        move = [i, j]
                        move_list.append(move)
                        continue
                if i < board_size - 1:
                    if j > 0:
                        if board_matrix[i + 1][j - 1] > 0 or board_matrix[i][j - 1] > 0:
                            move = [i, j]
                            move_list.append(move)
                            continue
                    if j < board_size - 1:
                        if board_matrix[i + 1][j + 1] > 0 or board_matrix[i][j + 1] > 0:
                            move = [i, j]
                            move_list.append(move)
                            continue
                    if board_matrix[i + 1][j] > 0:
                        move = [i, j]
                        move_list.append(move)
                        continue

        return move_list

    def get_board_matrix(self):
        return self.board_matrix
    
    def printBoard(self):
        for row in self.board_matrix:
            print(row)