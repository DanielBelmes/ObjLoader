# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest
import std/options
import std/tables

import objLoader
test "can load obj":
  var test: ObjLoader = ObjLoader(file: open("tests/models/cube.obj"))
  test.parseFile()
  check test.model.isSome()
  check test.model.get.num_geom_vertices == 8
  check test.model.get.num_text_vertices == 8
  check test.model.get.num_vertex_norms == 6
  check true
