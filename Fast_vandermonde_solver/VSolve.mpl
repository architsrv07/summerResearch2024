
# Solve [     1       1   ...     1    ] [ a1 ] = [ v1 ]
#       [    m1      m2   ...    mt    ] [ a2 ] = [ v2 ]
#       [  m1^2    m2^2   ...  mt^2    ] [ a3 ] = [ v3 ]
#       [                              ] [    ]   [    ]
#       [m1^(t-1) m2^(t-1) ... mt^(t-1)] [ at ]   [ vt ]
#
# For evaluation points are [2^j,3^j,...,pn^j] for j=0,1,2,...
# m_i = M_i(2,3,...,pn)
#
# The polynomial M = (x-m1)(x-m2)...(x-mt) may be input as an additional argument.
# A shift s may be input as an additional argument in which case we solve the
# shifted Vandermonde system
#
#       [   m1^s       m2^s    ...    mt^s   ] [ a1 ] = [ v1 ]
#       [ m1^(1+s)   m2^(1+s)  ...  mt^(1+s) ] [ a2 ] = [ v2 ]
#       [ m1^(2+s)   m2^(2+s)  ...  mt^(2+s) ] [ a3 ] = [ v3 ]
#       [                                    ] [    ]   [    ]
#       [m1^(t-1+s) m2^(t-1+s) ... mt^(t-1+s)] [ at ]   [ vt ]
#
# Evaluation points are [2^j,3^j,...,pn^j] for j=s,s+1,s+2,...
# Uses Zippel's O(t^2) algorithm from 1990 which does
# O(t^2) arithmetic operations in Zp and uses O(t) space.


VandermondeSolve := proc( v::{Vector,list}, m::{Vector,list}, p::prime, shift::integer:=0 )
local t,i,j,M,x,a,q,r,s,temp;
   t := numelems(v);
   if numelems(m) <> t then error "v and m must be the same size"; fi;
   printf("Maple code Vandermonde solver: t=%d  p=%d\n",t,p);
   M := 1;
   for r in m do 
       M := Expand( M*(x-r) ) mod p; #M = (x-m1)(x-m2)...(x-mt)
   od;
   a := Vector(t);
   for j to t do
       q := Quo(M,x-m[j],x) mod p; # q = M/(x-m[j])
       r := 1/Eval(q,x=m[j]) mod p;
       s := 0;
       for i to t do s := s + v[i]*coeff(q,x,i-1); od;# a:=u^-1.b
       a[j] := r*s mod p;# q^-1(ui).q.b
       if shift=0 then next fi;
       r := 1/m[j] mod p;
       r := r &^ shift mod p;
       a[j] := r*a[j] mod p;
   od;
   if type(v,list) then a := convert(a,list); fi;
   return a;
end:

testing := false:

if testing then
p := 1153;
alpha := numtheory[primroot](p);
e := [11,45,61,72,95,116,201,234,301,310,411,454]:# 12 random exponents
t := nops(e);
c := rand(1000):
f := add( c()*x^e[i], i=1..t ):# Generating polynomial in fp[x]
m := [seq( alpha &^ e[i] mod p, i=1..t )]:# powers of alpha in Fp
v := [seq( Eval(f,x=modp(alpha &^ i,p)) mod p, i=0..t-1 )]:# Evaluating f at powers of alpha
a := VandermondeSolve( v, m, p ):
zero := add( a[i]*x^e[i], i=1..t ) - f;
if zero = 0 then printf("Passed\n") else printf("Failed\n"); fi;

t := 100:
p := 2^31-1;
alpha := numtheory[primroot](p);
r := rand(1000000):
e := {seq( r(), i=1..t )}:
while nops(e)<t do e := e union {r()} od:
m := [seq( alpha &^ e[i] mod p, i=1..t )]:
c := rand(p):
f := add( c()*x^e[i], i=1..t ):
v := [seq( Eval(f,x=modp(alpha &^ i,p)) mod p, i=0..t-1 )]:
st := time():
a := VandermondeSolve( v, m, p ):
mt := time()-st:
printf("VS1 time=%8.3f\n",mt);
zero := add( a[i]*x^e[i], i=1..t ) - f;
if zero = 0 then printf("Passed\n") else printf("Failed\n"); fi;

fi:
