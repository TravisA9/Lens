# ==============================================================================
function pixel(x::Int64,y::Int64,r,g,b) # x = restrict(1, x, width ) y = restrict(1, y, height)
    if plotIfVisible(1, x, width, 1, y, height)
        imgc[ round(Int64, y), round(Int64, x) ] = RGB(r,g,b)
    end
end
# ==============================================================================
# just playing arround ...kinda'
# NOTE: compare this to "normal(xa,ya, xb,yb)" in Utility.jl
# ==============================================================================
function drawLine( x::Int64, y::Int64, xx::Int64,yy::Int64, r,g,b)
  dx,dy = xx-x, yy-y
  l   = max(dx,dy) # greatest total length
  xUnit = dx/l
  yUnit = dy/l
    for p in 1:l
        pixel( round(Int64, x + (xUnit*p)), round(Int64, y + (yUnit*p)), r, g, b )
    end
end
# ==============================================================================
# just playing arround ...kinda'
# ==============================================================================
function drawObject(points, x, y, r,g,b)
  rad = width/5+1
    for p in points
      pixel( (p.x*(p.z*0.05)) + x,
             (p.y*(p.z*0.05)) + y,
             r,g,b )
    end
end

# ==============================================================================
# This either needs updated (as above) or deleted.
function drawWarpCurve(center, magnify)
    index = 0
    for l in -center:center
            index +=1
            c = Curve[1000 + l]
      pixel( round(Int64, index), round(Int64, (c*magnify)+1), 0,1,0 )

    end
end
# drawWarpCurve(0,1,0)
# ==============================================================================
function drawWarpNormals(center, magnify)
index = 0
    for l in -center:3:center
        index +=3
        n = diffract( l, magnify)
      drawLine( round(Int64, index + n[1]),
                round(Int64, n[2]),
                round(Int64, index + n[3]),
                round(Int64, n[4]),
                0,1,0)
    end
end

# ==============================================================================
# this function really doesn't go here since it creates an object and does not draw
  deg = pi/180
# ==============================================================================
function CirclePoints(r) # Z should probably be r
   p = []
   for x in 0:200 # draw a line
     push!(p, Point(x, 0,0))
   end

      for ϑ in (0*deg):0.01:(360*deg) #(r*3.2)
        xx, yy = rotateZ3D(ϑ, r, 0)
        push!(p, Point(xx, yy, 0))
      end
      return p
end

# ==============================================================================
# Some drawing tests...
# ==============================================================================
#=
points = CirclePoints( width/5)
drawObject(points, halfWidth, halfHeight, 0,1,0)
# rotates arround    x        y         z
rotateXYZ(points, (0*deg), (-80*deg), (0*deg))
drawObject(points, halfWidth, halfHeight, 1,0,0)
rotateXYZ(points, (0*deg), (0*deg), (60*deg))
drawObject(points, halfWidth, halfHeight, 0,0,1)

drawLine( 20, 20, 200,100, 0,.8,0)
=#
# ==============================================================================
