# read "./projection_phi.mpl":
# anchor points=[[2,3],[4,9],[8,27],[16,81],[32,243]...]:
# Shift=[5]
evaluation_num_den:=proc(B,anchor_points,shift_,num_var,p,num_points)
    local correct_degree,T,alpha,m,phi_,_phi,Y,u,f,g,dq,lcg,np,nv:
    print("---------------------------------------------------------------------");
    print("In evaluation_num_den");
    print("anchor_points: ",anchor_points):
    # print("shift_: ",shift_):
    correct_degree:=false:
    T:=num_points:
    while(not(correct_degree)) do
        
        print("T:= ",T):
# we need to come up with some values of alpha
        # alpha:=[seq(i-1,i=1..T)]:
        r:=rand(p):
        alpha:=[seq(r()+r() mod p,i=1..T)]:
        print("alpha: ",alpha):
        # print("alpha[1]: ",alpha[1]):
        m:=expand(product(x-alpha[i],i=1..T)) mod p:
        print("m: ",m):
        # Y:= shift[1]*(alpha[1]-anchor_points[1])+anchor_points[2] mod p:
        # for np from 1 to T do # projection ring_homomorphism
        #     phi_[np][1]:=alpha[np]:
        #     for nv from 2 to num_var do 
        #         phi_[np][2]:=shift_[nv-1]*alpha[np]-shift_[nv-1]*anchor_points[1]+anchor_points[2] mod p:
        #     end do:
        # end do:
        # _phi:=[seq(convert(phi_[i],list),i=1..T)]:
        _phi:=projection_image_phi(num_var,alpha,shift_,anchor_points,p,T):
        print("_phi: ",_phi):
        Y:=[seq(B(_phi[i],p),i=1..T)]:
        print("Y: ",Y):
        u:=Interp(alpha,Y,x)mod p:
       
        print("u: ",u):

        f,g,dq,lcg:=MQRFR(m,u,0,1,p):
        



        # print("dq: ",dq):
        if dq > 1 then 
            
            break:
        else 
            print("MQRFR failed. Trying again with more points"):
            T:=T*2:
        end if:
        print("====================================================="):
    end do:
    if num_points <> T then  
    print("====================================================="):
        return f,g,lcg,T:
        # return m,u,f,g,lcg,T:

    else
    print("====================================================="):
    return f,g,lcg:
    # Checking for Ratrecon
        # return m,u,f,g,lcg:
    end if:
end proc:
    # We need to calculate m, y and u  