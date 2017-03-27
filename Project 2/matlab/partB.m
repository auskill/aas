function myPosition = partB(IMUData,SpeedData, prevState)

heading = partA(IMUData, prevState);

prevX = double(prevState(1));
prevY = double(prevState(2));
prevH = double(prevState(3));
prevT = double(prevState(6));

times = double(SpeedData.tcx(1,:));      
times = times - prevT;
times = times*0.0001;

speeds = SpeedData.data;



myPosition(1,:) = [prevX;prevY;prevH;prevT];

for i=2:length(speeds);
    dt = times(i) - times(i-1);
    X = PredictVehiclePose(myPosition(i-1,:),speeds(i),dt);
    myPosition(i,1) = X(1);
    myPosition(i,2) = X(2);
    index = find(heading(2,:) <= times(i),1,'last');
    myPosition(i,3) = heading(1,index);
    
end

myPosition(:,4) = times;

