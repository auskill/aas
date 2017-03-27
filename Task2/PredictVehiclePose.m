% X0 current state ( [x; y; heading] )
% X estimated next state ( [x; y; heading] at time t+dt)
% speed : current speed (m/s)
% steering : current steering angle (at time t)(in radians)
% dt is the "integration" horizon (should be a fraction of second)
% Original program by Jose Guivant
%modified by will johnston

function X = PredictVehiclePose(X0,speed,dt)
% Remember: state vector X = [x; y; heading]
X=X0 ;
dL = dt*speed ;
X(1) = X0(1)+ dL * cos(X0(3));
X(2) = X0(2)+ dL * sin(X0(3));

return ;