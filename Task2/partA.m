%Will Johnston z3373093

function yaw = partA(folder)
fileDepths = [folder,'\IMU_data'];   
load(fileDepths);
G = 9.8; %gravity 
k = 180/pi; % constant, useful for converting radian to degrees.

gyros = IMU.DATAf(4:6,:);
times = double(IMU.times(1,:));      
times = times - times(1);
times = times*0.0001;


Time = find(times<=6,1,'last');
 
AvgWx = mean(gyros(1,1:Time))  ;
gyros(1,:) = (gyros(1,:)-AvgWx);
AvgWy = mean(gyros(2,1:Time))  ;
gyros(2,:) = (gyros(2,:)- AvgWy);
AvgWz = mean(gyros(3,1:Time))  ;
gyros(3,:) = (gyros(3,:)-AvgWz);

Attitude(:,1) = IntegrateOneStepOfAttitude(gyros(:,1), 0, [0,0,0]);
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
        


figure(1) ;  clf() ; hold on ;
plot(yaw(2,:),yaw(1,:)*k);
xlabel('time (in seconds)');
ylabel('Attitude (degrees)');
title('Part A: Attitude vs. Time')
grid on;
zoom on;
end
