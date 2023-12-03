from cell import Cell as cl
import random

class Reel():
    def __init__(self, dimension):
        self.cells = [0] * dimension
        for i in range (dimension):
            self.cells[i] = cl()
        self.head_position = 0
    
    def next(self):
        if self.head_position < len(self.cells) - 1:
            self.head_position += 1
    
    def prev(self):
        if self.head_position > 0:
            self.head_position -= 1

    def command(self, cmd):
        if cmd not in ("+","-",">","<",".",","):
            return
        elif cmd == "+":
            self.increase()
        elif cmd == "-":
            self.decrease()
        elif cmd == ">":
            self.next()
        elif cmd == "<":
            self.prev()
        elif cmd == ".":
            #print(self.display(),end="")
            return self.display()
        
    def increase(self):
        self.cells[self.head_position].increase()

    def decrease(self):
        self.cells[self.head_position].decrease()

    def get_value(self):
        return self.cells[self.head_position].get_value()

    def display(self):
        return self.cells[self.head_position].display()

    def display_all_values(self):
        tmp_str = "["
        for c in self.cells:
            tmp_str += str(c.get_value())
            tmp_str +="]["
        return tmp_str.rstrip("[")

    def display_all(self):
        tmp_str = "["
        for c in self.cells:
            tmp_str += str(c.display())
            tmp_str +="]["
        return tmp_str.rstrip("[")
    
    def get_header_pos(self):
        return self.head_position

if __name__ == "__main__":
    r = Reel(10)
    
    # for i in range(1000):
    #     rng = random.randrange(4)
    #     if rng == 0:
    #         r.increase()
    #     elif rng == 1:
    #         r.decrease()

    #     elif rng == 2:
    #         r.next()
    #     else:
    #         r.prev()
    for _ in range(40):
        r.command("+")
    print(r.command("."))
    print(r.display_all_values())