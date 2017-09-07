module lens
using ImageView, Images, TestImages
using ImageFiltering, Colors, ImageMetadata, FixedPointNumbers

# include("Utility.jl")
# include("Draw.jl")

# ==============================================================================
# a few convenience variables...
# NOTE: be sure to change the directory if needed
#    blueGalaxy.jpg    Galaxy.JPG    Spiral.jpg
    currentPath = pwd()
    buffer = load(currentPath * "/lens/images/Galaxy.JPG")
    imgc = fill(RGB{N0f8}(0,0,0),(1575, 2800)) # rand(RGB{N0f8}, 1575, 2800)
    width, height = size(buffer)
    halfWidth, halfHeight = round(Int64, width*.5), round(Int64, height*.5)
# ==============================================================================
#                                  CURRENT METHOD:
# ------------------------------------o--------------------p--------------------    <-- source image
#                                     |--------------------|                        <-- d
# ------------------------------------o---------p-------------------------------    <-- altered image
#                                     |---------|  = x = ((x-o)*(1/d)) * degree
#
# Above you can see an example of a pixel (p) at distance (d) from origion (o)
# in the line representing the altered image p has been displaced. How is that
# displacement value calculated? ...logically it must be a value that is relative
# to the distance. I am using the following method: calculate the distance (d),
# miltiply each dimention (x and y) by the value ((1/d) * degree) I then assign
# the color values from the new pixel location to the origional pixel location.
# ------------------------------------------------------------------------------

# ==============================================================================
# Calculate the distance between a and b
# ==============================================================================
function distance(xa,ya, xb,yb)
    X, Y = (xa - xb), (ya - yb)
    return sqrt( (X*X) + (Y*Y) )
end
# ==============================================================================
# Calculate a lens effect: x = ((oy-x)*(1/d) * degree) and y = ((oy-y)*(1/d) * degree)
# ------------------------------------------------------------------------------
# Let's pre-calculate the lens curvature  ...this should speed things up a bit.
# Curve = [ (1/X) for X in 1:10000]
# ------------------------------------------------------------------------------
type Body
    value::Float64            # value of curvature
    curve::Array{Float64,1}   # lens curvature
    voxels::Any               # Voxels image of body
    class::String
    x::Float64                # x origon
    y::Float64                # y origon
    z::Float64                # z origon
    Body(value, x, y, z) = new(value,Float64[],0, "", x, y, z)
end

# ------------------------------------------------------------------------------
type Space
    bodies::Array{Body,1}     # lens curvature
    limit::Float64            # the size of our universe
    Space() = new([],100000)
    Space(limit) = new([],limit)
end
# ------------------------------------------------------------------------------
galaxies = ["E0.jpg", "E3.jpg", "E7.jpg", "S0.jpg", "Sa.jpg", "Sb.jpg", "SBa.jpg", "SBb.jpg", "SBc.jpg", "Sc.jpg"]
# ------------------------------------------------------------------------------
function createRandomBodies(space, number, bounds) # 1575
    Z = rand( 1:bounds, number) # Create Z coords before anything else
    sort!(Z) # Now sort them for depth

    for i in 1:number
        # Eventually the weight "10" will have to be correctly calculated!
        createBody(space, 50, rand(galaxies), rand(1:bounds), rand(1:bounds), Z[i])
    end

end
# ------------------------------------------------------------------------------
function createBody(body, weight, class, x, y, z)
    blackHole = Body(convert(Float64, weight), convert(Float64, x), convert(Float64, y), convert(Float64, z))
    blackHole.curve = [ (1/X) for X in 1:10000] * weight
    push!(body.bodies, blackHole )
end
# ==============================================================================
# function warp(x,y, ox,oy, degree)
function warp(x,y, body) # TODO: later make this work with slices (that is to say vector fields)
    ox, oy = body.x, body.y
        dx, dy = (ox - x), (oy - y) # Get 1D, 1D distance
        D = sqrt( (dx * dx) + (dy * dy)  ) # Get 2D distance
        (D==0) && return (0,0) # No point in doing anything if it's zero

        d = body.curve[round(Int64,D)];
        X,Y   =  round(Int64,x+(dx*d)), round(Int64,y+(dy*d))
        #Xr,Yr =  reinterpret(N0f8, round(UInt8, (X%1)*255)) , reinterpret(N0f8, round(UInt8, (Y%1)*255)) # get digits after point. This is for getting subpixel quality.
    return (X,Y)
end
# ==============================================================================
# Apply function warp() to all pixels:
# ==============================================================================
function paintThis(space)

    for x in 1:width, y in 1:height

        X, Y = x,y
        for plane in 1:length(space.bodies)
            X, Y = warp(X, Y, space.bodies[plane])

            if Y > height || Y < 1 || X > width || X < 1 #     || Z > space.limit || Z < 1
                imgc[x,y] = RGB(.5,0,.5) # plot black pixel because the value falls outside the bounds of our universe
                break
            end

            # TODO: test for intersection of ray with body, paint pixel and break.
            if  plane == length(space.bodies)
                 imgc[x,y] =  buffer[X,Y] # Simple way
            end
        end


    end
    imshow(imgc, aspect=:auto) # show the resulting image
    println("W: $(width),  H:$(height) ")
    # println(imgc)
end
# ==============================================================================







space = Space()
createRandomBodies(space, 25, 1575)
# createBody(space, 100, 's0', halfWidth, halfHeight*.43, 250)
# createBody(space, 200, 's0', halfWidth, halfHeight-8, 10)
paintThis(space)


end # module

#                                  A BETTER METHOD:
# ------------------------------------o--------------------p--------------------    <-- source image
#                                     |--------------------|                        <-- d
# ------------------------------------o---------p-------------------------------    <-- altered image
#                                     |---------|  x = ((x-o)*(1/d)) * degree
#
# By making adjustments to the method used above we could actially build a
# speaciallised ray tracer that would work well for our purposes. We could use
# the same formula or modify the existing formula. Compare the above method to
# the following:
#
# ------------------------------------o--------------------p--------------------    <-- source image
#                                     |-------------------/
#                                     |------------------/
#                                     |-----------------/
#                                     |----------------/
#                                     |---------------/  <-- v
#                                     |--------------/
#                                     |-------------/
#                                     |------------/
#                                     |-----------/
#                                     |----------/
# ------------------------------------o---------p-------------------------------    <-- altered image
#                                     |---------|  x = d = ((x-o)*(1/d)) * degree
#
# By assigning an arbitrary distance between the source image and the altered image
# we create 3d vectors which we could use to trace on in to an imaginary space until
# the ray hits something. Once it does the color of the pixel can be assigned.
#
#                    How can this be realisticaly applied?
# We can make a simple function or even just a database of stars and galaxies
# along with descriptive data; for example, how much a galaxy weighs and hence
# how great of a lensing effect it would create. Another bit of data that would
# be important would be the relative scale of each object. That data would be
# important for generating realistic image scenarios.
# The objects could be randomely located within an imaginary space within certain
# predefined limits.
# For the z-plane of each object that is inserted/generated a proportional lensing
# field would be created. Then the rest is --in theory-- quite simple... for each
# pixel of the image (to be generated) a vector is traced through space... the
# vector is altered according to the value of each lensing layer that the ray
# passes through. If the ray never hits an object the pixel is assigned black a
# color. If the ray intersects an image, the pixel is assigned a corresponding color.
#
# I believe that is also solves some problems that I had expected to encounter
# later on. For example, the formula I am using calculates a simetrical distortion
# with an origion ...but what about asimetrical distortions caused by distributed
# mass? The average all of the functions that lye on the same z-plane should
# result in a realistic approximation of an asimetrical gravitational lens. It may
# even be convenient to speed the proccess up by creating vector maps of certain
# planes with complex distortions. Then instead of doing a series of calculations
# for each pixel, we could just add (?) the corresponding vector to the ray as it
# "passes through" that plane.
#
# I see no reason that I cannot accomplish this!
# ------------------------------------------------------------------------------

