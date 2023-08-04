import std/math
import vmath
import std/fenv

proc lineLineIntersect(line1: array[2,Vec3], line2: array[2,Vec3]): bool =
  echo $line1
  echo $line2
  var p13,p43,p21: Vec3
  var pa, pb: Vec3
  p13 = line1[0] - line2[0]
  p43 = line2[1] - line2[0]
  p21 = line1[1] - line1[0]

  var
    d1343 = dot(p13,p43)
    d4321 = dot(p43,p21)
    d1321 = dot(p13,p21)
    d4343 = dot(p43,p43)
    d2121 = dot(p21,p21)

  var
    denom = d2121 * d4343 - d4321 * d4321
    numer = d1343 * d4321 - d1321 * d4343
    mua = numer / denom
    mub = (d1343 + d4321 * mua) / d4343

  pa = line1[0] + mua * p21
  pb = line2[0] + mub * p43
  echo pa
  echo pb

  if 0 <= mua and mua <= 1 and 0 <= mub and mub <= 1:
    echo "onSegment"
  let papbMag = sqrt((pa.x-pb.x)^2 + (pa.y-pb.y)^2 + (pa.z-pb.z)^2)
  if papbMag <= 0.00000000000001f:
    echo "intersects"
  return true


proc trapezoidation(): array[3,int] =
  return [0,0,0]
