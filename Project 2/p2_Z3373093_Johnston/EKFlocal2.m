function [P, X] = EKFlocal(Xe, landmarks, OOIs, P, R)

numOOISs = length(OOIs(1,:));
numLandmarks = length(OOIs(1,:));

X = Xe;

if numOOISs > 0
    for u=1:numLandmarks
        ID = find(OOIs(3,:) == u,1,'last');
        if ~isempty(ID)
            eDX = (landmarks(1,u)-Xe(1)) ;      % (xu-x)
            eDY = (landmarks(2,u)-Xe(2)) ;      % (yu-y)
            eD2 = eDX*eDX + eDY*eDY;
            eDD = sqrt( eD2 ) ; %   so : sqrt( (xu-x)^2+(yu-y)^2 )
            eDB = atan2(eDY,eDX) - Xe(3) + pi/2;
            
            mDX = (OOIs(1,ID)) ;      % (xu-x)
            mDY = (OOIs(2,ID)) ;      % (yu-y)
            mD2 = mDX*mDX + mDY*mDY;
            mDD = sqrt( mD2 ) ; %   so : sqrt( (xu-x)^2+(yu-y)^2 )
            mDB = atan2(mDY,mDX);


            H = [   -eDX/eDD , -eDY/eDD , 0 , 0; eDY/eD2 , -eDX/eD2, -1, 0 ];
            ExpectedRange = eDD;  
            ExpectedBearing = eDB;
            
            MeasuredRange = mDD;
            MeasuredBearing = mDB;
            
            z = [MeasuredRange - ExpectedRange ; MeasuredBearing - ExpectedBearing];      
            z(2) = mod(z(2) + pi, 2*pi)-pi;

            S = R + H*P*H' ;
            iS = inv(S);  
            K = P*H'*iS;           
            
            X = Xe+K*z ;   
            P = P-P*H'*iS*H*P ;
            
            
            
            
        end
    end
    
end

end
        