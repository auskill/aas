function myPosition = partB(folder)
fileDepths = [folder,'\speed_data'];   
load(fileDepths);
heading = partA(folder);

times = double(Vel.times(1,:));      
times = times - times(1);
times = times*0.0001;

speeds = Vel.speeds; 
myPosition(1,:) = [0;0;pi/2;times(1)];
for i=2:length(speeds);
    dt = times(i) - times(i-1);
    X = PredictVehiclePose(myPosition(i-1,:),speeds(i),dt);
    myPosition(i,1) = X(1);
    myPosition(i,2) = X(2);
    index = find(heading(2,:) <= times(i),1,'last');
    myPosition(i,3) = heading(1,index);
    
end

myPosition(:,4) = times;

figure(2) ;  clf() ; hold on ;
plot(myPosition(:,1),myPosition(:,2));
xlabel('x (M)');
ylabel('Y (M)');
title('Part b: Position')
grid on;
zoom on;
