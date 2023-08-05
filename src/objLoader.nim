import std/streams
import std/strutils
import std/strformat
import std/options
import fusion/matching
import std/sequtils
import std/parseutils
import std/tables
import vmath

{.experimental: "caseStmtMacros".}

type Material* = object

type Face = object of RootObj
  vert_indices*: seq[int]
  norm_indices*: seq[int]
  text_coords*: seq[int]
  material*: Material
  num_verticies*: int

type Polygon* = object of Face

type Line* = object of Face

type Point* = object of Face

type MeshObj* = object
  name*: string
  faces*: seq[Face]
  num_indicies*: int
  num_uvs*: int
  material*: Material
type Mesh* = ref MeshObj

type Model* = object
  name*: string
  geom_vertices*: seq[Vec3]
  num_geom_vertices*: int = 0
  text_vertices*: seq[Vec3]
  num_text_vertices*: int = 0
  vertex_norms*: seq[Vec3]
  num_vertex_norms*: int
  groups*: Table[string,seq[Mesh]]
  meshes*: seq[Mesh]
  materials*: seq[Material]

type ObjLoader* = object
  file*: File
  #triangulate*: bool = false [TODO]
  model*: Option[Model]
  currentMesh*: Mesh
  activeGroups: seq[string]

proc parseFile*(loader: var ObjLoader): void =
  var
    dataStream = newFileStream(loader.file)
    line = ""
    lineNumber = 1
    model: Model = Model()
  while dataStream.readLine(line):
    line = line.strip()
    let components = line.split()
    if components[0] != "" and components[0] != "#" and components.len == 1:
      raise newException(ValueError,fmt"No values provided for command on line: {lineNumber}")
    case components[0]:
      of "":
        continue #empty line
      of "#":
        continue #comment
      # Vertex Data
      of "v":
        if(components.len == 4):
          model.geom_vertices.add(vec3(parseFloat(components[1]),parseFloat(components[2]),parseFloat(components[3])))
          model.num_geom_vertices += 1
        else:
          raise newException(ValueError,fmt"Curves not currently supported. Failure on line: {lineNumber}")
      of "vt":
        model.text_vertices.add(vec3(parseFloat(components[1]),if components.len > 2: parseFloat(components[2]) else: 0,if components.len > 3: parseFloat(components[3]) else: 0))
        model.num_text_vertices += 1
      of "vn":
        model.vertex_norms.add(vec3(parseFloat(components[1]),parseFloat(components[2]),parseFloat(components[3])))
        model.num_vertex_norms += 1
      of "vp":
        continue # [TODO]implement later
      of "cstype":
        continue # [TODO]implement later
      of "deg":
        continue # [TODO]implement later
      of "bmat":
        continue # [TODO]implement later
      of "step":
        continue # [TODO]implement later
      # Elements
      of "f", "l", "p":
        if loader.currentMesh.isNil:
          var mesh: Mesh = new(Mesh)
          model.meshes.add(mesh)
          loader.currentMesh = mesh
          if loader.activeGroups.len > 0:
            for group in loader.activeGroups:
              if not model.groups.hasKey(group):
                model.groups[group] = @[]
              model.groups[group].add(mesh)
        var face = Polygon()
        face.num_verticies = components.len-1
        for indicies in components[1..^1]:
          loader.currentMesh.num_indicies += 1
          let splitIndicies = indicies.split('/')
          var indiciesParsed = splitIndicies.map(proc(x: string): int = discard parseInt(x,result))
          face.vert_indices.add(indiciesParsed[0])
          if indiciesParsed.len > 1: #if not using / delimiter
            if indiciesParsed[1] != 0:
              face.text_coords.add(indiciesParsed[1])
              loader.currentMesh.num_uvs += 1
            if indiciesParsed[2] != 0:
              face.norm_indices.add(indiciesParsed[2])
        loader.currentMesh.faces.add(face)
      of "curv":
        continue # [TODO]implement later
      of "curv2":
        continue # [TODO]implement later
      of "surf":
        continue # [TODO]implement later
      # Freeform Curve/Surface Body statemnts
      of "parm":
        continue # [TODO]implement later
      of "trim":
        continue # [TODO]implement later
      of "hole":
        continue # [TODO]implement later
      of "scrv":
        continue # [TODO]implement later
      of "sp":
        continue # [TODO]implement later
      of "end": # end of block
        continue # [TODO]implement later
      # connectivity
      of "con":
        continue # [TODO]implement later
      # grouping
      of "g":
        loader.currentMesh = nil
        loader.activeGroups = components[1..^1]
      of "s":
        continue # [TODO]implement later
      of "mg":
        continue # [TODO]implement later
      of "o":
        continue # [TODO]implement later
      # Display/render attributes
      of "bevel":
        continue # [TODO]implement later
      of "c_interp":
        continue # [TODO]implement later
      of "d_interp":
        continue # [TODO]implement later
      of "lod":
        continue # [TODO]implement later
      of "usemtl":
        continue # [TODO]implement later
      of "mtllib":
        continue # [TODO]implement later
      of "shadow_obj":
        continue # [TODO]implement later
      of "trace_obj":
        continue # [TODO]implement later
      of "ctech":
        continue # [TODO]implement later
      of "stech":
        continue # [TODO]implement later
      else:
        echo "No match: " & line
    lineNumber += 1
  dataStream.close()
  loader.model = some(model)