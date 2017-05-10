pmodule lens
include("Utility.jl")
using ImageView, Images, TestImages #, CoordinateTransformations, OffsetArrays
using ImageFiltering, Colors, ImageMetadata

imgc = testimage("mandrill")
# or this to load your own file!
# using FileIO
# ------------------------------------------------------------------------------
# I think that the way to do the ray tracing is to use an array of "Lens" values
# as the curve of the imaginary lens. Since it is a curve and not a 3d shape the
# formula can be applied radially by simply measuring the distance of each pixel
# from the lens origion and using the distance as the index of the lens array.
#
# We must also keep track of the angle of the pixel (from the lens origin) for
# later use in ray tracing.
#
# The angle that the ray is bent to is an inversion relative to the angle of the
# point on the curve that is hit by the ray. So, for surface angle  +0.953
# ------------------------------------------------------------------------------


 Curve = [( 1/(X+1) ) for X in 1000:-1:-1000]
  Curve[1002] = 0 # because it was "Inf"

# * 180 / pi
# ==============================================================================
 width, height = size(imgc)
 halfWidth, halfHeight = width*.5, height*.5
 O = Point(halfWidth, halfHeight)

for x in 1:width
    for y in 1:height
        #value = Lens(O,  Point(x,y), 50)
         dist = round(Int64 , abs(distance(O, Point(x,y))))+1 # +1 to avoid zero
        # angle = getAngle(halfWidth, halfHeight, x,y)
# println("dist: $dist")
    #dist == 0 && (dist = 1)
        #i = Curve[round(Int64, dist)]/10 #-Curve[dist+2]
        #rx,ry = rotateZ3D(i, x+0.0, y+0.0)
# x = 7     # x = 13   (-3 and +3 from origion respectively)
# HW = 10   # HW = 10
# W =  20   # W =  20
# x-HW = -3  # x-HW = 3

### relx = x-halfWidth
### rely = y-halfHeight
        ### ax = relx + (Curve[round(Int64, 1002 + round(Int64, relx) )])
        ### ay = rely + (Curve[round(Int64, 1002 + round(Int64, rely) )])


#angle = 2 # getAngle(halfWidth, halfHeight, x,y)
#az = 1
# dx = 1+(1/(abs(x-halfWidth)+1)) #1/(X+1)
# dy = 1+(1/(abs(y-halfHeight)+1)) #1/(X+1)

d = 1+(1/((dist*0.5)+1)) #1/(X+1)
ax =  (x-halfWidth)*d #
ay = (y-halfHeight)*d #(1/dist)   #rotateZ3D(0.01, x, y) #rotateZ3D
        rx = 0# round(Int64, ax+halfWidth )
        ry = round(Int64, ay+halfHeight )
        #rz = round(Int64, az )
        # println(rx, ry)
    if rx > 0 && rx <= width && ry > 0 && ry <= height
            p = imgc[rx,ry]
            imgc[x,y] = RGB(red(p),green(p),blue(p))
    else
      # print("n $rx, $ry: ")
            imgc[x,y] = RGB(0,0,0.3)
    end

    end
end

# ==============================================================================
# just playing arround ...kinda'
# ==============================================================================
function DrawCircle(r, x, y, color)
  deg = pi/180

  points = []
  for t in (0*deg):0.01:(360*deg) #(r*3.2)
    xx, yy = rotateZ3D(t, r, r)
    push!(points, [xx, yy, r])
  end


    for i in 1:length(points)
      xx, zz = rotateY3D((45*deg), points[i][1], points[i][3])
         imgc[ round(Int64, xx + x),
               round(Int64, points[i][2] + y)
               ] = color
    end
end
# ==============================================================================
# ==============================================================================
function DrawCircle2(r, x, y, color)
  deg = pi/180
    for t in -(45*deg):0.01:(360*deg) #(r*3.2)

         imgc[  round(Int64, r*cos(t) + x),
                round(Int64, r*sin(t) + y)
               ] = color
    end
end
# ==============================================================================

DrawCircle(width/5, halfWidth, halfHeight, RGB(1,0,0))


imshow(imgc, pixelspacing = [1,1])

end # module
