from brainfuk_compiler import BrainfukCompiler
from reel import Reel
from cell import Cell
import unittest

class CellTest(unittest.TestCase):

    def test_zero(self):
        cell = Cell()
        self.assertEqual(cell.get_value(), 0)

    def test_one(self):
        cell = Cell()



if __name__ == "__main__":
    unittest.main()