###################################################################################
##                                                                               ##
## Giving rational vector spaces category a structure of a triangulated category ##
##                                                                               ##
###################################################################################

## ReadPackage( "TriangulatedCategoriesForCAP", "examples/VectorSpacesTriangulatedCategory.gi" );

######################################
##
##  Loading needed packages
##
######################################

LoadPackage( "MatricesForHomalg" );

LoadPackage( "Gauss" );

LoadPackage( "GaussForHomalg" );

LoadPackage( "LinearAlgebraForCap" );

LoadPackage( "TriangulatedCategoriesForCap" );

########################################
##
## Declarations, Representations ...
##
########################################


DeclareRepresentation( "IsHomalgRationalVectorSpaceRep",
                        IsCapCategoryObjectRep,
                        [ ] );
                        
BindGlobal( "TheTypeOfHomalgRationalVectorSpaces",
        NewType( TheFamilyOfCapCategoryObjects,
                IsHomalgRationalVectorSpaceRep ) );

DeclareRepresentation( "IsHomalgRationalVectorSpaceMorphismRep",
                       IsCapCategoryMorphismRep,
                       [ ] );

BindGlobal( "TheTypeOfHomalgRationalVectorSpaceMorphism",
        NewType( TheFamilyOfCapCategoryMorphisms,
                IsHomalgRationalVectorSpaceMorphismRep ) );

## Attributes 


DeclareAttribute( "Dimension",
                  IsHomalgRationalVectorSpaceRep );
 
DeclareAttribute( "AsSpaceInMatrixCategory", IsHomalgRationalVectorSpaceRep ); 

DeclareAttribute( "AsMorphismInMatrixCategory", IsHomalgRationalVectorSpaceMorphismRep );


##  Methods

DeclareOperation( "QVectorSpace",
                  [ IsInt ] );
 
DeclareOperation( "QVectorSpace",
                  [ IsVectorSpaceObject ] );


DeclareOperation( "QVectorSpaceMorphism",
                  [ IsHomalgRationalVectorSpaceRep, IsObject, IsHomalgRationalVectorSpaceRep ] );
                  

DeclareOperation( "QVectorSpaceMorphism",
                  [ IsObject ] );

#################################
##
## Creation of category
##
#################################
 
BindGlobal( "vecspaces", CreateCapCategory( "category of rational vector spaces" ) );

# SetIsAbelianCategory( vecspaces, true );

BindGlobal( "Q", HomalgFieldOfRationals( ) );

###########################################
##
## Constructors for objects and morphisms 
##
###########################################

InstallMethod( QVectorSpace,
               [ IsInt ],
               
  function( dim )
    local space;
    
    space := rec( );
    
    ObjectifyWithAttributes( space, TheTypeOfHomalgRationalVectorSpaces,
                             Dimension, dim,
                             AsSpaceInMatrixCategory, VectorSpaceObject( dim, Q )
    );
    
    Add( vecspaces, space );
    
    return space;
    
end );

InstallMethod( QVectorSpace, 
              [ IsVectorSpaceObject ], 
         
   function( space )
   
    return QVectorSpace( Dimension( space ) );
    
end );

InstallMethod( QVectorSpaceMorphism,
                  [ IsHomalgRationalVectorSpaceRep, IsObject, IsHomalgRationalVectorSpaceRep ],
                  
  function( source, matrix, range )
    local morphism, homalg_matrix;

    if not IsHomalgMatrix( matrix ) then
    
      homalg_matrix := HomalgMatrix( matrix, Dimension( source ), Dimension( range ), Q );

    else

      homalg_matrix := matrix;

    fi;

    if NrRows( homalg_matrix ) <> Dimension( source ) or NrColumns( homalg_matrix ) <> Dimension( range ) then 
                             
      Error( "The inputs are not compatible" );
    
    fi;
    
    morphism := rec( morphism := homalg_matrix );
    
    ObjectifyWithAttributes( morphism, TheTypeOfHomalgRationalVectorSpaceMorphism,
                      Source, source,
                      Range, range,
                      AsMorphismInMatrixCategory, VectorSpaceMorphism(  AsSpaceInMatrixCategory( source ), homalg_matrix, AsSpaceInMatrixCategory( range ) )
    );

    Add( vecspaces, morphism );
    
    return morphism;
    
end );

 
InstallMethod( QVectorSpaceMorphism, 
                 [ IsObject ],
                 
  function( matrix )
  local mor;
  
  if IsVectorSpaceMorphism( matrix ) then 
   
     mor := matrix;
     
     return QVectorSpaceMorphism( QVectorSpace( Source( mor ) ), mor!.UnderlyingMatrix, QVectorSpace( Range( mor ) ) );
 
  fi;
  
  if not IsHomalgMatrix( matrix ) then 
  
     mor := HomalgMatrix( matrix, Q );
     
  else 
  
     mor := matrix;
     
  fi;
  
  
  return QVectorSpaceMorphism( QVectorSpace( NrRows( mor ) ), mor, QVectorSpace( NrColumns( mor ) ) );
  
end );

#################################
##
## View
##
#################################

InstallMethod( ViewObj,
               [ IsHomalgRationalVectorSpaceRep ],

  function( obj )

    Print( "<A rational vector space of dimension ", 
    String( Dimension( obj ) )," as an object in ",vecspaces, ">" );

end );

InstallMethod( ViewObj,
               [ IsHomalgRationalVectorSpaceMorphismRep ],

  function( obj )

    Print( "A rational vector space homomorphism with matrix: \n" );
  
    Display( obj!.morphism );

end );

##################################
##
##  Display
##
##################################

InstallMethod( Display,
               [ IsHomalgRationalVectorSpaceRep ],

  function( obj )

    Print( "Q^(1 X ", String( Dimension( obj ) ),") as an object in ",vecspaces );

end );

InstallMethod( Display,
               [ IsHomalgRationalVectorSpaceMorphismRep ],

  function( mor )

    
    Print( "A rational vector space homomorphism ",
    "Q^(1 X ", String( Dimension( Source( mor ) ) ), ") --> ",
    "Q^(1 X ", String( Dimension( Range( mor ) ) ),
    
    ") with matrix: \n" );
  
    Display( mor!.morphism );

end );



########################################
##
## Adding additive methods
##
########################################

##
identity_morphism := function( obj )

    return QVectorSpaceMorphism( obj, HomalgIdentityMatrix( Dimension( obj ), Q ), obj );
    
end;

AddIdentityMorphism( vecspaces, identity_morphism );

##
pre_compose := function( mor_left, mor_right )
    local composition;

    composition := mor_left!.morphism * mor_right!.morphism;

    return QVectorSpaceMorphism( Source( mor_left ), composition, Range( mor_right ) );

end;

AddPreCompose( vecspaces, pre_compose );

##
is_equal_for_objects := function( vecspace_1, vecspace_2 )
    
    return Dimension( vecspace_1 ) = Dimension( vecspace_2 );
    
end;

AddIsEqualForObjects( vecspaces, is_equal_for_objects );

##
is_equal_for_morphisms := function( a, b )
  
    return a!.morphism = b!.morphism;
  
end;

AddIsEqualForMorphisms( vecspaces, is_equal_for_morphisms );

is_zero_for_obj := function( obj )

return Dimension( obj )=0;
end;

AddIsZeroForObjects( vecspaces, is_zero_for_obj );


is_zero_for_mors := function( mor )

return IsZero( EntriesOfHomalgMatrixAsListList( mor!.morphism ) );

end;

AddIsZeroForMorphisms( vecspaces, is_zero_for_mors );

AddAdditiveInverseForMorphisms( vecspaces, function( mor )
                                           local matrix;

                                           matrix := EntriesOfHomalgMatrixAsListList( mor!.morphism );

                                           matrix := -1*matrix;

                                           return QVectorSpaceMorphism( Source( mor ) , matrix,  Range( mor )  );

                                           end );

AddZeroObject( vecspaces, function( )
                          
                          return QVectorSpace( 0 );
                          
                          end );

###############################################
##
## Adding triangulation structure
##
###############################################

AddShiftOfObject( vecspaces, IdFunc );

AddReverseShiftOfObject( vecspaces, IdFunc );

AddShiftOfMorphism( vecspaces, IdFunc );

AddReverseShiftOfMorphism( vecspaces, IdFunc );

AddIsomorphismFromObjectToReverseShiftAfterShiftOfTheObject( vecspaces, function( obj )
                                                                        
                                                                        return IdentityMorphism( obj );
                                                                        
                                                                        end );
                                                                        
AddIsomorphismFromObjectToShiftAfterReverseShiftOfTheObject( vecspaces, function( obj )
                                                                        
                                                                        return IdentityMorphism( obj );
                                                                        
                                                                        end );
                                                                       
AddIsExactForTriangles( vecspaces, function( trian )
                                   local f,g,h;
                                  
                              if not IsEvenInt( Dimension( trian!.object1 ) + Dimension( trian!.object2 ) - Dimension( trian!.object3 ) ) then 
                                
                                 return false;
                                
                              fi;
                              
                              f:= AsMorphismInMatrixCategory( trian!.morphism1 );
                              g:= AsMorphismInMatrixCategory( trian!.morphism2 );
                              h:= AsMorphismInMatrixCategory( trian!.morphism3 );
                              
                              if not IsZeroForMorphisms( PreCompose( f, g ) ) or 
                                  not IsZeroForMorphisms( PreCompose( g, h ) ) or 
                                  not IsZeroForMorphisms( PreCompose( h, f ) ) then 
                                
                              return false;
                              
                              fi;
                              
                              ## in abelian categories, for f:A ---> B we have
                              ## im( f )   = ker( coker( f ) )
                              ## coim( f ) = coker( ker( f ) )
                             
                              if not Dimension( KernelObject( g ) ) = Dimension( KernelObject( CokernelProjection( f ) ) ) or
                                   not Dimension( KernelObject( h ) ) = Dimension( KernelObject( CokernelProjection( g ) ) ) or
                                     not Dimension( KernelObject( f ) ) = Dimension( KernelObject( CokernelProjection( h ) ) ) then
                              
                              return false;
                              
                              fi;
                              
                              return true;
                              end );
##
AddCompleteMorphismToExactTriangle( vecspaces, function( mor )
       local f,ker_f, m, f1,n,f2,g1,t,C,G2,g2,g,h1,h;
       
       f := AsMorphismInMatrixCategory( mor );
       
       ker_f:= KernelEmbedding( f );
       m := Dimension( KernelObject( f ) );
       
       f1:= CokernelProjection( ker_f );
       n:= Dimension( CokernelObject ( ker_f ) );
       
       f2:= CokernelColift( ker_f, f );
       
       g1:= CokernelProjection( f );
       t:= Dimension( CokernelObject( f ) );
       
       C :=  VectorSpaceObject( t+m, Q );
       
       G2 := TransposedMat( Concatenation( IdentityMat( t ), NullMat( m, t ) ) );
       G2 := HomalgMatrix( G2, t, m+t, Q );
       
       g2:= VectorSpaceMorphism( Range( g1 ), G2, C );
       g := PreCompose( g1, g2 );
       
       h1 := CokernelProjection( g );
       h := PreCompose( h1, ker_f );
       
       return CreateExactTriangle( mor, QVectorSpaceMorphism( g ), QVectorSpaceMorphism( h ) );
       
       end );

## Input is two triangles T1, T2 and two morphisms u, v such that vf1 = g1u.
##
##             f1          f2              f3
##  T1:  A ---------> B ----------> C ------------> A[ 1 ]
##       |            |             |                |
##     u |          v |             | ?              | u[ 1 ]
##       V            V             V                V
##  T2:  A' --------> B'----------> C'------------> A'[ 1 ]
##             g1            g2            g3
##
## Output is w: C ---> C' such that the diagram is commutative
##
AddCompleteToMorphismOfExactTriangles( vecspaces, function( t1, t2, u_, v_ )
                   local f,g,h,h2,h1,f_,g_,h_,h_2,h_1, beta,u,v, bar_H_1, bar_h_1,g1,g2, bar_G2, bar_g2, g_1,g_2, alpha, part1, part2, w; 
                   
                   f:= AsMorphismInMatrixCategory( t1!.morphism1 );
                   g:= AsMorphismInMatrixCategory( t1!.morphism2 );
                   h:= AsMorphismInMatrixCategory( t1!.morphism3 );
                   
                   h2:= KernelEmbedding( f );
                   h1:= KernelLift( f, h );     
                   
                   f_:= AsMorphismInMatrixCategory( t2!.morphism1 );
                   g_:= AsMorphismInMatrixCategory( t2!.morphism2 );
                   h_:= AsMorphismInMatrixCategory( t2!.morphism3 );
                   
                   h_2:= KernelEmbedding( f_ );
                   h_1:= KernelLift( f_, h_ );     
                   
                   u:= AsMorphismInMatrixCategory( u_ );
                   v:= AsMorphismInMatrixCategory( v_ );
                   
                   beta := KernelLift( f_, PreCompose( h2, u ) );
                   bar_H_1 := RightDivide( HomalgIdentityMatrix( Dimension( Range( h_1 ) ), Q ), h_1!.UnderlyingMatrix );
                   bar_h_1 := VectorSpaceMorphism( Range( h_1 ), bar_H_1, Source( h_1 ) );
                   
                   g1:= CokernelProjection( f );
                   g2:= CokernelColift( f, g );
                   
                   bar_G2 := LeftDivide( g2!.UnderlyingMatrix, HomalgIdentityMatrix( Dimension( Source( g2 ) ), Q ) );
                   bar_g2 := VectorSpaceMorphism( Range( g2 ), bar_G2, Source( g2 ) );
                   
                   g_1:= CokernelProjection( f_ );
                   g_2:= CokernelColift( f_, g_ );
                   
                   alpha := CokernelColift( f, PreCompose( v, g_1 ) );
                   
                   part1:= PreCompose( PreCompose( bar_g2, alpha ), g_2 );
                   part2:= PreCompose( PreCompose( h1, beta ), bar_h_1 );
                   
                   w:= part1+part2;
                   
                   return QVectorSpaceMorphism( w );
                   
                   end );
##
AddOctohedralAxiom( vecspaces, function( f, g )
                   local i,j,T, S, W, N, u,v, w;
                   
                   T := CompleteMorphismToExactTriangle( f );
                   
                   S := CompleteMorphismToExactTriangle( PreCompose( f, g ) );
                   
                   u := CompleteToMorphismOfExactTriangles( T, S, IdentityMorphism( Source( f ) ), g );
                   
                   W := CompleteMorphismToExactTriangle( g );
                   
                   v := CompleteToMorphismOfExactTriangles( S, W, f, IdentityMorphism( Range( g ) ) );
                   
                   j:= T!.morphism2;
                   i:= W!.morphism3;
                   
                   w:= PreCompose( i, ShiftOfMorphism( j ) );
                   
                   return [ T, W, S, CreateExactTriangle( u, v, w ) ];
                   
                   end );
                  
SetIsTriangulatedCategory( vecspaces, true );

Finalize( vecspaces );

## Demo

T := ShiftFunctor( vecspaces );
#! Shift functor in category of rational vector spaces
S := ReverseShiftFunctor( vecspaces );
#! Reverse Shift functor in category of rational vector spaces
Id_TS := NaturalIsomorphismFromIdentityToShiftAfterReverseShiftFunctor( vecspaces );
# Autoequivalence from identity functor to Shift after ReverseShift functor in category of rational vector spaces
Id_ST := NaturalIsomorphismFromIdentityToReverseShiftAfterShiftFunctor( vecspaces );
# Autoequivalence from identity functor to ReverseShift after Shift functor in category of rational vector spaces
A := QVectorSpace( 3 );
# <A rational vector space of dimension 2 as an object in category of rational vector spaces>
ApplyFunctor( T, A );
# <A rational vector space of dimension 2 as an object in category of rational vector spaces>
f := QVectorSpaceMorphism( [ [ 2,3,4,5,2], [ 0,0,1,0,1 ] ] );
#! A rational vector space homomorphism with matrix: 
#! [ [  2,  3,  4,  5,  2 ],
#!   [  0,  0,  1,  0,  1 ] ]
#!
#
A := Source( f );
#! <A rational vector space of dimension 2 as an object in category of rational vector spaces>
#
B := Range( f );
#! <A rational vector space of dimension 5 as an object in category of rational vector spaces>
T := CompleteMorphismToExactTriangle( f );
#! < An exact triangle in category of rational vector spaces >
Display( T );
#! object1 --(morphism1)--> object2 --(morphism2)--> object3 --(morphism3)--> ShiftOfObject( object1 )
#! 
#! 
#! object1 is
#! Q^(1 X 2) as an object in category of rational vector spaces
#! 
#! morphism1 is 
#! A rational vector space homomorphism Q^(1 X 2) --> Q^(1 X 5) with matrix: 
#! [ [  2,  3,  4,  5,  2 ],
#!   [  0,  0,  1,  0,  1 ] ]
#! 
#! 
#! object2 is
#! Q^(1 X 5) as an object in category of rational vector spaces
#! 
#! morphism2 is 
#! A rational vector space homomorphism Q^(1 X 5) --> Q^(1 X 3) with matrix: 
#! [ [  -3/2,  -5/2,     1 ],
#!   [     1,     0,     0 ],
#!   [     0,     0,    -1 ],
#!   [     0,     1,     0 ],
#!   [     0,     0,     1 ] ]
#! 
#! 
#! object3 is
#! Q^(1 X 3) as an object in category of rational vector spaces
#! 
#! morphism3 is 
#! A rational vector space homomorphism Q^(1 X 3) --> Q^(1 X 2) with matrix: 
#! [ [  0,  0 ],
#!   [  0,  0 ],
#!   [  0,  0 ] ]
#! 
#! 
#! ShiftOfObject( object1 ) is 
#! Q^(1 X 2) as an object in category of rational vector spaces

## Demo
#                   f1:= [ [ 2, 1 ],        f2:=[ [ -1/2, 0 ],         f3:=[ [  0, 0 ],
#                          [ 4, 2 ] ]             [   1 , 0 ] ]              [ -2, 1 ] ]
#                  Q^2 ------------------> Q^2 -----------------> Q^2 --------------------> Q^2  
#                   |                       |                      |
# u:=[ [ 1, 1/2 ],  |                       | v :=[ [ 2, 0 ],      | 
#      [ 2, 1   ] ] |                       |       [ 1, 0 ] ]     | ?
#                   |                       |                      |
#                   V                       V                      V
#                  Q^2 ------------------> Q^2 -----------------> Q^2 --------------------> Q^2
#                       g1:=[ [ 4, 0 ],        g2:=[ [  0, 0 ],      g3:=[ [  0  , 0 ],
#                             [ 2, 0 ] ]             [  1, 0 ] ]           [ -1/2, 1 ] ]
f1 := QVectorSpaceMorphism( [ [ 2,1 ], [ 4,2 ] ] );
#! A rational vector space homomorphism with matrix: 
#! [ [  2,  1 ],
#!   [  4,  2 ] ]
#! 
f2:= QVectorSpaceMorphism( [ [-1/2, 0 ], [ 1, 0 ] ] );
#! A rational vector space homomorphism with matrix: 
#! [ [  -1/2,     0 ],
#!   [     1,     0 ] ]
#! 
f3 := QVectorSpaceMorphism( [ [ 0, 0 ], [ -2,1 ] ] );
#! A rational vector space homomorphism with matrix: 
#! [ [   0,   0 ],
#!   [  -2,   1 ] ]
#! 
T:= CreateExactTriangle( f1, f2, f3 );
#! < An exact triangle in category of rational vector spaces >
Display( T );
#! object1 --(morphism1)--> object2 --(morphism2)--> object3 --(morphism3)--> ShiftOfObject( object1 )
#! 
#! 
#! object1 is
#! Q^(1 X 2) as an object in category of rational vector spaces
#! 
#! morphism1 is 
#! A rational vector space homomorphism Q^(1 X 2) --> Q^(1 X 2) with matrix: 
#! [ [  2,  1 ],
#!   [  4,  2 ] ]
#! 
#! 
#! object2 is
#! Q^(1 X 2) as an object in category of rational vector spaces
#! 
#! morphism2 is 
#! A rational vector space homomorphism Q^(1 X 2) --> Q^(1 X 2) with matrix: 
#! [ [  -1/2,     0 ],
#!   [     1,     0 ] ]
#! 
#! 
#! object3 is
#! Q^(1 X 2) as an object in category of rational vector spaces
#! 
#! morphism3 is 
#! A rational vector space homomorphism Q^(1 X 2) --> Q^(1 X 2) with matrix: 
#! [ [   0,   0 ],
#!   [  -2,   1 ] ]
#! 
#! 
#! ShiftOfObject( object1 ) is 
#! Q^(1 X 2) as an object in category of rational vector spaces
g1 := QVectorSpaceMorphism( [ [ 4,0 ], [ 2,0 ] ] );   
#! A rational vector space homomorphism with matrix: 
#! [ [  4,  0 ],
#!   [  2,  0 ] ]
#! 
g2:= QVectorSpaceMorphism( [ [ 0, 0 ], [ 1, 0 ] ] );   
#! A rational vector space homomorphism with matrix: 
#! [ [  0,  0 ],
#!   [  1,  0 ] ]
#! 
g3 := QVectorSpaceMorphism( [ [ 0, 0 ], [ -1/2,1 ] ] );
#! A rational vector space homomorphism with matrix: 
#! [ [     0,     0 ],
#!   [  -1/2,     1 ] ]
#! 
S := CreateExactTriangle( g1, g2, g3 );
#! < An exact triangle in category of rational vector spaces >
Display( S );
#! object1 --(morphism1)--> object2 --(morphism2)--> object3 --(morphism3)--> ShiftOfObject( object1 )
#! 
#! 
#! object1 is
#! Q^(1 X 2) as an object in category of rational vector spaces
#! 
#! morphism1 is 
#! A rational vector space homomorphism Q^(1 X 2) --> Q^(1 X 2) with matrix: 
#! [ [  4,  0 ],
#!   [  2,  0 ] ]
#! 
#! 
#! object2 is
#! Q^(1 X 2) as an object in category of rational vector spaces
#! 
#! morphism2 is 
#! A rational vector space homomorphism Q^(1 X 2) --> Q^(1 X 2) with matrix: 
#! [ [  0,  0 ],
#!   [  1,  0 ] ]
#! 
#! 
#! object3 is
#! Q^(1 X 2) as an object in category of rational vector spaces
#! 
#! morphism3 is 
#! A rational vector space homomorphism Q^(1 X 2) --> Q^(1 X 2) with matrix: 
#! [ [     0,     0 ],
#!   [  -1/2,     1 ] ]
#! 
#! 
#! ShiftOfObject( object1 ) is 
#! Q^(1 X 2) as an object in category of rational vector spaces
u := QVectorSpaceMorphism( [ [ 1, 1/2 ], [ 2,1 ] ] );
#! A rational vector space homomorphism with matrix: 
#! [ [    1,  1/2 ],
#!   [    2,    1 ] ]
#! 
v := QVectorSpaceMorphism( [ [2,0 ], [ 1, 0 ] ] );
#! A rational vector space homomorphism with matrix: 
#! [ [  2,  0 ],
#!   [  1,  0 ] ]
#! 
CompleteToMorphismOfExactTriangles( T, S, u, v );
#! A rational vector space homomorphism with matrix: 
#! [ [  0,  0 ],
#!   [  0,  0 ] ]
#! 


f := QVectorSpaceMorphism( [ [ 1, 2 ], [ 2, 4 ] ] );
# A rational vector space homomorphism with matrix: 
# [ [  1,  2 ],
#   [  2,  4 ] ]

g := QVectorSpaceMorphism( [ [ 1 ], [ 0 ] ] );
# A rational vector space homomorphism with matrix: 
# [ [  1 ],
#   [  0 ] ]

t := OctohedralAxiom( f, g );
# [ < An exact triangle in category of rational vector spaces >, < An exact triangle in category of rational vector spaces >, < An exact triangle in category of rational vector spaces >, < An exact triangle in category of rational vector spaces > ]
Display( t[ 1 ] );
# object1 --(morphism1)--> object2 --(morphism2)--> object3 --(morphism3)--> ShiftOfObject( object1 )
# 
# 
# object1 is
# Q^(1 X 2) as an object in category of rational vector spaces
# 
# morphism1 is 
# A rational vector space homomorphism Q^(1 X 2) --> Q^(1 X 2) with matrix: 
# [ [  1,  2 ],
#   [  2,  4 ] ]
# 
# 
# object2 is
# Q^(1 X 2) as an object in category of rational vector spaces
# 
# morphism2 is 
# A rational vector space homomorphism Q^(1 X 2) --> Q^(1 X 2) with matrix: 
# [ [  -2,   0 ],
#   [   1,   0 ] ]
# 
# 
# object3 is
# Q^(1 X 2) as an object in category of rational vector spaces
# 
# morphism3 is 
# A rational vector space homomorphism Q^(1 X 2) --> Q^(1 X 2) with matrix: 
# [ [   0,   0 ],
#   [  -2,   1 ] ]
# 
# 
# ShiftOfObject( object1 ) is 
# Q^(1 X 2) as an object in category of rational vector spaces
Display( t[ 2 ] );
# object1 --(morphism1)--> object2 --(morphism2)--> object3 --(morphism3)--> ShiftOfObject( object1 )
# 
# 
# object1 is
# Q^(1 X 2) as an object in category of rational vector spaces
# 
# morphism1 is 
# A rational vector space homomorphism Q^(1 X 2) --> Q^(1 X 1) with matrix: 
# [ [  1 ],
#   [  0 ] ]
# 
# 
# object2 is
# Q^(1 X 1) as an object in category of rational vector spaces
# 
# morphism2 is 
# A rational vector space homomorphism Q^(1 X 1) --> Q^(1 X 1) with matrix: 
# [ [  0 ] ]
# 
# 
# object3 is
# Q^(1 X 1) as an object in category of rational vector spaces
# 
# morphism3 is 
# A rational vector space homomorphism Q^(1 X 1) --> Q^(1 X 2) with matrix: 
# [ [  0,  1 ] ]
# 
# 
# ShiftOfObject( object1 ) is 
# Q^(1 X 2) as an object in category of rational vector spaces

Display( t[ 3 ] );
# object1 --(morphism1)--> object2 --(morphism2)--> object3 --(morphism3)--> ShiftOfObject( object1 )
# 
# 
# object1 is
# Q^(1 X 2) as an object in category of rational vector spaces
# 
# morphism1 is 
# A rational vector space homomorphism Q^(1 X 2) --> Q^(1 X 1) with matrix: 
# [ [  1 ],
#   [  2 ] ]
# 
# 
# object2 is
# Q^(1 X 1) as an object in category of rational vector spaces
# 
# morphism2 is 
# A rational vector space homomorphism Q^(1 X 1) --> Q^(1 X 1) with matrix: 
# [ [  0 ] ]
# 
# 
# object3 is
# Q^(1 X 1) as an object in category of rational vector spaces
# 
# morphism3 is 
# A rational vector space homomorphism Q^(1 X 1) --> Q^(1 X 2) with matrix: 
# [ [  -2,   1 ] ]
# 
# 
# ShiftOfObject( object1 ) is 
# Q^(1 X 2) as an object in category of rational vector spaces

Display( t[ 4 ] );
# object1 --(morphism1)--> object2 --(morphism2)--> object3 --(morphism3)--> ShiftOfObject( object1 )
# 
# 
# object1 is
# Q^(1 X 2) as an object in category of rational vector spaces
# 
# morphism1 is 
# A rational vector space homomorphism Q^(1 X 2) --> Q^(1 X 1) with matrix: 
# [ [  0 ],
#   [  1 ] ]
# 
# 
# object2 is
# Q^(1 X 1) as an object in category of rational vector spaces
# 
# morphism2 is 
# A rational vector space homomorphism Q^(1 X 1) --> Q^(1 X 1) with matrix: 
# [ [  0 ] ]
# 
# 
# object3 is
# Q^(1 X 1) as an object in category of rational vector spaces
# 
# morphism3 is 
# A rational vector space homomorphism Q^(1 X 1) --> Q^(1 X 2) with matrix: 
# [ [  1,  0 ] ]
# 
# 
# ShiftOfObject( object1 ) is 
# Q^(1 X 2) as an object in category of rational vector spaces

##           f:= [ [ 1, 2 ],                      [ [-2, 0 ],                   [ [  0, 0 ],
##                 [ 2, 4 ] ]                       [ 1, 0 ] ]                    [ -2, 1 ] ]
##         Q^2 -----------------------> Q^2 -------------------------> Q^2 ----------------------> Q^2
##          |                            |                              |                           |
##          |                            |                              | [ [ 0 ],                  | 
##       id |                          g |                              |   [ 1 ] ]                 |  id
##          |                            |                              |                           |
##          V       gf :=                V                              V                           V 
##         Q^2 -----[ [ 1 ],-----------> Q   ------ [ [ 0 ] ]---------> Q ------[ [ -2, 1 ] ]-----> Q^2
##                    [ 2 ] ]
##          |                            |                              |                           |
##          |                            |                              |                           |
##        f |                        id  |                           [ [ 0 ] ]                      | f
##          |                            |                              |                           |
##          V                            V                              V                           V 
##         Q^2 -- g := [ [ 1 ], -------> Q   ------ [ [ 0 ] ]---------> Q -------[ [ 0, 1 ] ]-----> Q^2
##                       [ 0 ] ] 
##          |                            |                              |                           |
##[[-2,0 ], |                            |                              |                           |
## [1, 0] ] |                        [ [ 0 ] ]                          | id                        | [ [-2, 0 ],
##          |                            |                              |                           |   [ 1, 0 ] ]
##          V                            V                              V                           V 
##         Q^2 -- [ [ 0 ],-------------> Q   ------ [ [ 0 ] ]---------> Q -------[ [ 1, 0 ] ]-----> Q^2
##                  [ 1 ] ]
##


