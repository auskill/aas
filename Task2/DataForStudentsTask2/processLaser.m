
% Feature Extraction from laser data 
% William Johnston 2016
% Modified from original program by Jose Guivant.


function processLaser(file)

clc(); close all;
%input default data file
if ~exist('file','var'), file ='Laser__2.mat'; end;
load(file); 

%setup dynamic plot using handles and set
figure(1) ; clf();    
Handles.H1 = plot(0,0,'b.'); hold on;   %plot for raw points
Handles.H2 = plot(0,0,'r.');            %plot for high intensity points  
Handles.H3 = plot(0,0,'g*');            %plot for brilliant OOis centers  
axis([-10,10,0,20]);                         
xlabel('Position (degrees)');
ylabel('Position (meters)');
title('Laser Scan Processed Data');           
zoom on ;  grid on; 

%skip some scans, change 3 to alter number of scans skipped
for i=1:3:dataL.N,                        
    scan_i = dataL.Scans(:,i);
    ProcessScan(scan_i, Handles);    
    pause(0.001);
end;
disp('All scans processed');

return;
end


%.............................
function ProcessScan(scan, h)

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

set(h.H1,'xdata',X,'ydata',Y);

ii = find(intensities~=0);          % find those "pixels" that had intense reflection (>0)
set(h.H2,'xdata',X(ii),'ydata',Y(ii));

% To be done (by you)
OOIs = ExtractOOIs(ranges,intensities);
PlotOOIs(OOIs, h);

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
    
function PlotOOIs(OOIs, h)
    if OOIs.N<1, return ; end;
    
    ii = find(OOIs.Colours~=0); 
    set(h.H3,'xdata',OOIs.Centers(ii,1),'ydata',OOIs.Centers(ii,2));
    
    
return;
end