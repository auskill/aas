%Will Johnston z3373093

function yaw = partA(IMUData, prevState)

G = 9.8; %gravity 
k = 180/pi; % constant, useful for converting radian to degrees.

prevX = double(prevState(1));
prevY = double(prevState(2));
prevH = double(prevState(3));
prevT = double(prevState(4));

gyros = IMUData.data(4:6,:);
times = double(IMUData.tcx(1,:));      
times = times - prevT;
times = times*0.0001;



Attitude(:,1) = IntegrateOneStepOfAttitude(gyros(:,1), 0, [prevX,prevY,prevH]);
for I=2:size(times,2),
    dt = times(I)-times(I-1);
    Attitude(:,I)= IntegrateOneStepOfAttitude(gyros(:,I), dt , Attitude(:,I-1));
end

yaw(1,:) = -1*(Attitude(3,:)) + pi/2;
yaw(2,:) = times;

for i=1:length(yaw)
    while yaw(1,i) < 0
        yaw(1,i) = yaw(1,i) + 2*pi;
    end
    
end
        

