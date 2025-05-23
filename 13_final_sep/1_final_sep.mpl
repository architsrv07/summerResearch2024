# 1. Have a black box for f/g. Change black box implementation- it only takes in the point and the prime.
Construct_Blackbox:=proc(f,g,vars)
    local BB:
    BB:=proc(point_,p)
        local var,num,denom_,a,i:
        var:=vars:
        num:=f:
        denom_:=g:
        a:=num/denom_:
        # print("a: ",a):
        return Eval(a,{seq(var[i]=point_[i],i=1..numelems(point_))}) mod p: 
    end proc:
    return BB:
end proc:
generate_random_vector:=proc(n,p)
    local r,i:
    r:=rand(p):
    return [seq(r(),i=1..n)]:
end proc:

# MQRFR(m,u,0,1,p)
MQRFR:=proc(r0,r1,t0,t1,p)
    local r,t,q,i,f,g,qmax,lcg:
    r[0]:=r0:
    r[1]:=r1:
    t[0]:=t0:
    t[1]:=t1:
    #  print("t0= ",t0):
    #  print("t1= ",t1):
    f:=r0:
    g:=t1:
    qmax:=0:
    i:=1:
    while r[i] <> 0 do
    #  1. find quotient and remainder
    q[i]:= Quo(r[i-1],r[i],x,'r[i+1]') mod p:
    #  print("r[",i,"]=",r[i]):
    #  print("q[",i,"]=",q[i]):
    #  print("t[",i,"]=",t[i]):
     print("Degree of q[",i,"]=",degree(q[i],x)):
     print("--------------------------------------"):
    #  print("r[",i+1,"]=",r[i+1]):
    if degree(q[i],x)>= qmax then 
        qmax:=degree(q[i],x):
        f:=r[i]:
        g:=t[i]:
    end if:
    #   reduction step to update t.
    t[i+1]:=Expand(t[i-1]-q[i]*t[i])mod p:
    #  Normalization step for r and t 
    #  if r[i+1]<> 0 then 
    #     rho:=lcoeff(r[i+1]):
    #     r[i+1]:=r[i+1]/rho mod p:
    #     t[i+1]:=t[i+1]/rho mod p:
    # end if:
    #  print("f=",f):
    #  print("g=",g):
    #  print("______________________________________"):
    i:=i+1:
    if qmax <=1 or gcd(f,g) <> 1 then 
        FAIL:
    end if:
    end do:
    lcg:=lcoeff(g):
    # print("lcg= ",lcg):
    return f/lcg mod p,g/lcg mod p,qmax,lcg:# make g monic. Also add a check to see that g !=0
end proc:
# Monte Carlo algorithm for early termination separation
Early_termination_seperation:=proc(B,p)
    local r,u,f,g,dq,num_points,correct_degree,points,Y,m,check,lc_u,sigma_,shift_,alpha,phi_,nv,np,m_u,i,lcg:
    r:=rand(p):
    num_points:=1:
    correct_degree:=true:
    while(correct_degree) do
        print("num_points: ",num_points):
        r:=rand(p):
        # alpha:=[seq(i*100,i=1..num_points)]:
        alpha:=[seq(r(),i=1..num_points)]:
        # print("alpha: ",alpha):
        sigma_:=generate_random_vector(numelems(vars),p):
        # points:=[seq([seq(j+i,i=1..2)],j=0..num_points-1)]:
        shift_:=generate_random_vector(numelems(vars)-1,p):
        # _phi:=[seq([seq(0,nv=1..num_var)],np=1..num_points)]:\
        # phi_:=convert(_phi,Array):
        # print("phi_: ",phi_):
        # phi_[np][1]=alpha[np]:
        for np from 1 to num_points do 
            phi_[np][1]:=alpha[np]:
            for nv from 2 to num_var do 
                phi_[np][2]:=shift_[nv-1]*alpha[np]-shift_[nv-1]*sigma_[1]+sigma_[2] mod p:
            end do:
        end do:
        print("phi_: ",phi_):
        Y:=[seq(B(phi_[i],p),i=1..num_points)]:
        # Y:=[B(phi_[1],p)]:
        # print("Y: ",Y):

        m:=Expand(product(x-alpha[i],i=1..num_points)) mod p:
        u:=Interp(alpha,Y,x)mod p:
        # print("u: ",u):
        # checking:=[seq(Eval(u,x=alpha[i]) mod p,i=1..num_points)]:
        # print("Y: ",Y):
        # print("checking: ",checking):
        m_u:=u/lc_u mod p:
        f,g,dq,lcg:=MQRFR(m,u,0,1,p):
        # print("In early termination seperation"):
        # print("f= ",f):
        # print("g= ",g):
        # print("lcg= ",lcg):
        if dq > 1 then 
            break:
        else 
            num_points:=num_points*2:
        end if:
        print("====================================================="):
    end do:
    return f,g,lcg,sigma_,shift_:
end proc:


# Test 1 
# vars:={x,y}:
# p:=2^61-1:
# num_var:=numelems(vars):
# num_deg:=45:
# denom_deg:=30:
# ff:=randpoly(vars,sparse,degree=num_deg) mod p:
# gg:=randpoly(vars,sparse,degree=denom_deg) mod p:
# # gg:=gg/lcoeff(gg) mod p:
# # print("ff ",ff):
# # print("gg ",gg):
# # degree n=70 and d=52 CAUSING PROBLEM
# B:=Construct_Blackbox(ff,gg,vars):
# print(B):
# f,g,lc_g,sigma_,shift_:=Early_termination_seperation(B,p):
# Phi:=shift_[1]*x-shift_[1]*sigma_[1]+sigma_[2] mod p:
# f_x:=Expand(subs(y=Phi,ff)) mod p:
# # print("f_x= ",f_x):
# g_x:=Expand(subs(y=Phi,gg)) mod p:
# print("lcoeff(gg)= ",lcoeff(gg) mod p):
# print("f= ",f):
# print("f_x= ",f_x):
# print("g_x= ",g_x):
# f_x:=f_x/lcoeff(g_x) mod p:
# g_x:=g_x/lcoeff(g_x) mod p:
# # print("lc_g= ",lc_g mod p):
# # print("g_x= ",g_x):
# # print("g= ",g):
# print("checking numerator: ",f-f_x):
# print("checking denominator: ",g-g_x):

# test:=proc(num_deg,denom_deg,vars,p)
#     ff:=randpoly(vars,sparse,degree=num_deg) mod p:
#     gg:=randpoly(vars,sparse,degree=denom_deg) mod p:
#     B:=Construct_Blackbox(ff,gg,vars):
#     f,g,lc_g,sigma_,shift_:=Early_termination_seperation(B,p):
#     Phi:=shift_[1]*x-shift_[1]*sigma_[1]+sigma_[2] mod p:
#     f_x:=Expand(subs(y=Phi,ff)) mod p:
#     g_x:=Expand(subs(y=Phi,gg)) mod p:
#     f_x:=f_x/lcoeff(g_x) mod p:
#     g_x:=g_x/lcoeff(g_x) mod p:
#     print("checking numerator: ",f-f_x):
#     print("checking denominator: ",g-g_x):
# end proc:
# vars:={x,y}:
# num_var:=numelems(vars):
# p:=2^31-1:
# # Test 1
# num_deg:=20:
# denom_deg:=10:
# test(num_deg,denom_deg,vars,p);
