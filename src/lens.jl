module lens
using ImageView, Images, TestImages
using ImageFiltering, Colors, ImageMetadata, FixedPointNumbers

# include("Utility.jl")
# include("Draw.jl")

# ==============================================================================
# a few convenience variables...
# NOTE: be sure to change the directory if needed
#    blueGalaxy.jpg    Galaxy.JPG    Spiral.jpg
     buffer = load("/home/travis/Julia Stuff/lens/images/Galaxy.JPG")
     imgc = load("/home/travis/Julia Stuff/lens/images/Galaxy.JPG")
     width, height = size(imgc)
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
# to the distance. I am using the following method: calculat the distance (d),
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
# ==============================================================================
function warp(x,y, ox,oy, degree)
    dx, dy = round(Int64, x), round(Int64, y)
        D = distance(ox,oy, x,y)

        D==Inf ? d=0 : d = D              # 1/0 = Inf (infinit) let's make that 0 instead
        if D!=0                           # No point in doing anything if it's zero
            d = (1/d) * degree;           #
        end

# cx,cy is the origion so (cx-x), for example, gets the +/- x distance from origion.
        dx = (ox-x)*d
        dy = (oy-y)*d

    # round these to Ints because they'll have to translate to pixel coords.
    return (round(Int64,x+dx),round(Int64,y+dy)) # hmmm.. I don't remember why: x+dx, y+dy
end
# ==============================================================================
# Apply function warp() to all pixels:
# ==============================================================================
function paintThis()
    for x in 1:width
        for y in 1:height

            # The last value determins the degree of lensing!
            X, Y = warp(x,y, halfWidth, halfHeight-8, 200)

                if Y < height && Y > 0 && X < width && X > 0
                    imgc[x,y] =  buffer[X,Y]
                else
                    # plot black pixel because the value falls outside the image's bounds
                    imgc[x,y] = RGB(0,0,0)
                end
        end
    end
end
# ==============================================================================


paintThis()
imshow(imgc, aspect=:auto)

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
