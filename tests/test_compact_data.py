"""Fast regression checks for clipping without Godot or network access."""
import importlib.util
import unittest
from pathlib import Path

spec = importlib.util.spec_from_file_location('compact', Path(__file__).resolve().parents[1] / 'tools/build_compact_city.py')
compact = importlib.util.module_from_spec(spec)
spec.loader.exec_module(compact)

class ClipTests(unittest.TestCase):
    def test_crossing_with_both_endpoints_outside(self):
        self.assertEqual(compact.segment([-4000,-3000],[0,-3000]),[[-2850.0,-3000.0],[-900.0,-3000.0]])

    def test_parallel_outside(self):
        self.assertIsNone(compact.segment([-3000,-4000],[-3000,-3000]))

    def test_polyline_does_not_bridge_outside_excursion(self):
        pieces=compact.lines([[-2000,-3000],[-4000,-3000],[-4000,-4000],[-2000,-4000]])
        self.assertEqual(len(pieces),2)
        self.assertEqual(pieces[0][-1],[-2850.0,-3000.0])
        self.assertEqual(pieces[1][0],[-2850.0,-4000.0])

    def test_footprint_respects_rotated_corners(self):
        self.assertTrue(compact.footprint(dict(x=-2000,z=-3000,w=20,d=20,a=.7)))
        self.assertFalse(compact.footprint(dict(x=-910,z=-3000,w=20,d=20,a=.7)))

    def test_boundary_tangent_does_not_add_zero_length_road(self):
        self.assertIsNone(compact.segment([-3000,-5250],[-2850,-5100]))

if __name__=='__main__': unittest.main()
