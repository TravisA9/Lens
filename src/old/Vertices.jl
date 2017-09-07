#  Static definition of the object's vertices
type Point
    x::Float64
    y::Float64
    z::Float64
    Point(x,y,z) = new(x,y,z)
end
# ==============================================================================
 sqr(x) = x*x
# ==============================================================================
#  Offset pIn by pOffset into pOut
# ==============================================================================
function VectorOffset(p::Point, Offset::Point)
    return Point( p.x-Offset.x, p.y-Offset.y, p.z-Offset.z)
end
# ==============================================================================
#  Compute the cross product a X b into pOut
# ==============================================================================
function VectorGetNormal(a::Point, b::Point)
  return Point( a.y * b.z - a.z * b.y,
                  a.z * b.x - a.x * b.z,
                  a.x * b.y - a.y * b.x )
end
# ==============================================================================
#  Normalize pIn vector into pOut
# ==============================================================================
function VectorNormalize(pIn::Point)
   len = (sqrt(sqr(pIn.x) + sqr(pIn.y) + sqr(pIn.z)));
   #if len
     return Point(  pIn.x / len,   pIn.y / len,   pIn.z / len )
   #end
   #return nothing;
end
# ==============================================================================
#  Compute p1,p2,p3 face normal into pOut
# ==============================================================================
function ComputeFaceNormal(p1, p2, p3)
   #  Uses p2 as a new origin for p1,p3
   a = VectorOffset(p3, p2);
   b = VectorOffset(p1, p2);
   pn = VectorGetNormal( a, b);  #  Compute the cross product a X b to get the face normal
   pOut = VectorNormalize(pn); #  Return a normalized vector
   return pOut
end
a = Point(1,1,1)
b = Point(4,3,1)
c = Point(2,2,3)
ComputeFaceNormal(a, b, c)
# ==============================================================================
#= from spudocode
function CalculateSurfaceNormal(Input Triangle)
	 Vector U = (Triangle.p2 - Triangle.p1)
	 Vector V = (Triangle.p3 - Triangle.p1)

	 Normal.x = ( U.y * V.z ) - ( U.z * V.y )
	 Normal.y = ( U.z * V.x ) - ( U.x * V.z )
	 Normal.z = ( U.x * V.y ) - ( U.y * V.x )
	Returning Normal
end =#
# ==============================================================================




















OBJ_VERTICES =
    [54.111641, -0.007899, 37.141083;
    55.552414, -5.571973, 41.828125;
   #  ... #
    49.429958, 5.559381, 35.695301;
    54.111732, -0.007808, 37.141174]
end
#  Static definition of the object's faces
type GLFace
   v1::
   v2::
   v3::
end

OBJ_FACES =
    [0, 11, 12;
    0, 12, 1;

   #  ... #
    878, 9, 0;
    878, 0, 869]
end
# ==============================================================================
# ==============================================================================
function ComputeVerticeNormal(int ixVertice)

   #  Allocate a temporary storage to store adjacent faces indexes
   if (!m_pStorage)
      m_pStorage = new int[m_nbFaces];
      if (!m_pStorage)
         return;
   end
   #  Store each face which has an intersection with the ixVertice'th vertex
   nbAdjFaces = 0;
   GLFace * pFace = (GLFace *) OBJ_FACES;
   for (int ix = 0; ix < m_nbFaces; ix++, pFace++)
      if (pFace.v1 == ixVertice)
         m_pStorage[nbAdjFaces++] = ix;
      else
         if (pFace.v2 == ixVertice)
            m_pStorage[nbAdjFaces++] = ix;
         else
            if (pFace.v3 == ixVertice)
               m_pStorage[nbAdjFaces++] = ix;
   #  Average all adjacent faces normals to get the vertex normal
   Point pn;
   pn.x = pn.y = pn.z = 0;
   for (int jx = 0; jx < nbAdjFaces; jx++)

      int ixFace= m_pStorage[jx];
      pn.x += m_pFaceNormals[ixFace].x;
      pn.y += m_pFaceNormals[ixFace].y;
      pn.z += m_pFaceNormals[ixFace].z;
   end
   pn.x /= nbAdjFaces;
   pn.y /= nbAdjFaces;
   pn.z /= nbAdjFaces;

   #  Normalize the vertex normal
   VectorNormalize( pn,  m_pVertNormals[ixVertice]);
end
