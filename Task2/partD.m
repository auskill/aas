
% Feature Extraction from laser data 
% William Johnston 2016
% Modified from original program by Jose Guivant.


function partD(folder)

fileDepths = [folder,'\Laser__2'];   
load(fileDepths);
myPosition = partB(folder);

times = double(dataL.times(1,:));      
times = times - times(1);
times = times*0.0001;



%setup dynamic plot using handles and set
figure(1) ; clf();    
Handles.H1 = plot(0,0,'b.'); hold on;   %plot OOIs
Handles.H2 = plot(0,0,'g*');%plot initial OOIs
axis([-8,2,-1,7]);                         
xlabel('Position (degrees)');
ylabel('Position (meters)');
title('Laser Scan Processed Data');           
zoom on ;  grid on; 

%skip some scans, change 3 to alter number of scans skipped
for i=3:3:dataL.N,                        
    scan_i = dataL.Scans(:,i);
    if i == 3
        initialOOIs = ProcessScan(scan_i);
        startOOIs = correctOOIs(initialOOIs, Handles.H2, myPosition(1,:));

        for i=1:length(startOOIs(1,:))
            txt = int2str(i);
            handle(i) = text(startOOIs(1,i),startOOIs(2,i), txt);
            set(handle(i), 'Visible', 'off');
        end
    end
    

    OOIs  = ProcessScan(scan_i);
    index = find(myPosition(:,4) <= times(i),1,'last');
    detectedOOIs = correctOOIs(OOIs, Handles.H1, myPosition(index,:));
    if ~isempty(detectedOOIs)
        for i=1:length(detectedOOIs(1,:))
            distance = sqrt((startOOIs(1,:) - detectedOOIs(1,i)).^2 + (startOOIs(2,:) - detectedOOIs(2,i)).^2);
            index = find(distance <= 0.5,1);
            if index > 0
                pos = [detectedOOIs(1,i) detectedOOIs(2,i) 0];
                set(handle(index),'Position',pos,'Visible', 'on');
            end
        end
    end
    
    pause(0.001);
    for i=1:length(handle)
        set(handle(i), 'Visible', 'off');
    end
end;
disp('All scans processed');

return;
end


%.............................
function OOIs = ProcessScan(scan)

% Extract range and intensity information, from raw measurements.
% Each "pixel" is represented by range and intensity of reflection.
% It is a 16 bits number whose bits 0-12 define the distance (i.e. the range)
% in cm (a number 0<=r<2^13), and bits 13-15 indicate the intensity 
%( a number 0<=i<8 ).

% We extract range and intensity, here.
%useful masks, for dealing with bits.
mask1FFF = uint16(2^13-1);
maskE000 = bitshift(uint16(7),13)  ;

intensities = bitand(scan,maskE000);

ranges    = single(bitand(scan,mask1FFF))*0.01; 
% Ranges expressed in meters, and unsing floating point format.

% 2D points, expressed in Cartesian. From the sensor's perpective.
angles = [0:360]'*0.5* pi/180 ;         % associated angle for each range of scan
X = -cos(angles).*ranges;
Y = sin(angles).*ranges;

ii = find(intensities~=0);          % find those "pixels" that had intense reflection (>0)

% To be done (by you)
OOIs = ExtractOOIs(ranges,intensities);

return;
end
function r = ExtractOOIs(ranges,intensities)
    r.N = 0;
    r.Centers = [];
    r.Sizes   = [];
    r.Colours = [];
    P = [];
    
    %convert all coordinates
    angles = [0:360]'*0.5* pi/180 ;      
    P(:,1) = -cos(angles).*ranges;
    P(:,2) = sin(angles).*ranges;
    P(:,3) = intensities;
    
    while(length(P) > 2)
        interest(1,:) = P(1,:);
        P(1,:) = [];
        while (isempty(interest) == 0) && (isempty(P) == 0)
            distance = sqrt((P(:,1) - interest(end, 1)).^2 + (P(:,2) - interest(end, 2)).^2);               
            index = find(distance < 0.08,1, 'first'); 
            if (isempty(index) == 0)
                interest = [interest; P(index,:)];
                P(index,:) = [];
                
            elseif(length(interest) > 3)
                %method provided by Karan Narula in circlefit.m
                 X = interest(:,1);
                 Y = interest(:,2);
                 A = -2*[X(1:end-1) - X(2:end), Y(1:end-1)-Y(2:end)];
                 C = Y(2:end).^2 - Y(1:end-1).^2 + X(2:end).^2 - X(1:end-1).^2;
                 center = A\C;
                 radius = mean(sqrt((X - center(1)).^2 + (Y - center(2)).^2));
                  if radius < 0.11
                      r.N = r.N + 1;
                      r.Centers(r.N,:) = center;
                      r.Sizes(r.N) = radius;
                      if isempty(find(interest(:,3)~=0,1)) == 0
                          r.Colours(r.N) = 1;
                      else
                          r.Colours(r.N) = 0;
                      end
                  end
                 
                interest = [];
            else
                interest = [];
            end
        end
        
    end
return;
end
    
function newOOIs = correctOOIs(OOIs, h, position)
    if (OOIs.N<1), return ; end;
    count = 1;
    angle = position(3) - pi/2;
    rotationMatrix = [[cos(angle), sin(angle), 0]; [-sin(angle), cos(angle), 0]; [0, 0, 1]];
    translationMatrix = [[1, 0, position(1)]; [0, 1, position(2)+0.46]; [0, 0, 1]];
    correction = [[cos(angle), -sin(angle), position(1)]; [sin(angle), cos(angle), position(2)+0.46]; [0, 0, 1]];
    
    %translationMatrix*rotationMatrix;
    
     pos=[];
     newOOIs = [];
    for i=1:OOIs.N
        if OOIs.Colours(i) == 1
            pos(1,count) = OOIs.Centers(i,1);
            pos(2,count) = OOIs.Centers(i,2);
            pos(3,count) = 1;
            
            pos(:,count) =correction * pos(:,count);

            count = count + 1;
        end
    end
    if isempty(pos), return; end;
    
    newOOIs(1,:) = pos(1,:);
    newOOIs(2,:) = pos(2,:);
    
    
    set(h,'xdata',pos(1,:),'ydata',pos(2,:));
    
    
return;
end