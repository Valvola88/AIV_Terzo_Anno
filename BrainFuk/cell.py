class Cell:
    def __init__(self, max_value = 256):
        self.value = 0
        self.max_value = max_value
        pass

    def get_value(self):
        return self.value
    
    def display(self):
        return chr(self.value)
    
    def increase(self):
        self.value = (self.value + 1) % self.max_value

    def decrease(self):
        self.value = (self.value - 1) % self.max_value
    

if __name__ == "__main__":
    c = Cell()
    for i in range(40):
        c.increase()
    print(c.get_value())