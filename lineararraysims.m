% Simulation Environment for 10 elctrode linear array
% Require EIDORS
% http://eidors3d.sourceforge.net/

%% Startup
run eidors-svn/eidors/startup.m
 
%% Constants
ELEC_COUNT = 10;
GND_ELEC_IDX = 10;
meter_per_in = 0.0254; % meters per inch
salt_water_conductivity = 2.0e-1; % ohms per meter

%% Simulate Voltage vs Distance 

x = [-0.9:.1:0.9];
ys = [];
for i=x
    y = tanksim(500,0.1,0.0,i,'simvvsd');
    ys = [ys y];
    close all;
end
xs = (x - 0.9)*15;

%% Plot Voltage vs Distance
f = figure();
plot(xs, ys(2,:));
ylabel('Voltage Change from Empty Tank (V)');
xlabel('Distance from Electrode Array (in)');
title('Distance vs Change in Voltage Electrode 5'); 

%% Plot Surface V vs D

f1 = figure();
surf([1:9],xs,ys')
title('Simulated Voltage vs Distance vs Electrode (approaching center)')
zlabel('Voltage (V)')
xlabel('Electrode (diff pair)')
ylabel('Distance (inches)')

    
%% Simulate Voltage vs Position 

x = [-0.9:.1:0.9];
ys = [];
for i=x
    y = tanksim(500,0.1,i,0.4,'simvvspos');
    ys = [ys y];
    close all;
end
xs = (x)*15;

%% Plot Surface V vs P
f1 = figure();
surf([1:9],xs,ys')
title('Simulated Voltage vs Position in Front of Array vs Electrode')
zlabel('Voltage (V)')
xlabel('Electrode (diff pair)')
ylabel('Position (inches) [*Center is zero]')

%% Plot Voltage vs Pos
f = figure();
plot(xs, ys(2,:));
ylabel('Voltage Change from Empty Tank (V)');
xlabel('Position in from of Electrode Array (in)[*zero is center]');
title('Distance vs Position in Voltage Electrode 5 @ 6 inches'); 

%% Simulate Voltage vs Material 

x = 2.^[0:8];
ys = [];
for i=x
    y = tanksim(i,0.1,0.0,0.3,'simvvsmat');
    ys = [ys y];
    close all;
end
%% Plot Voltage vs Material
f = figure();
plot(x, ys(5,:));
ylabel('Simulated Voltage Change at Electrode(V)');
xlabel('Resistance of Object Elements in Ohms * meter');
title('Voltage change vs Resistance of Material Elements'); 

%% Simulate Voltage vs Size 

r = [0.02:0.02:.9];
ys = [];
for i=r
    y = tanksim(100,i,0.0,0.2-i,'simvvssz');
    ys = [ys y];
    close all;
end
flu
%% Plot Voltage vs Size
f = figure();
plot(r*15, ys(5,:));
ylabel('Simulated Voltage Change at Electrode(V)');
xlabel('Size of Object (inches)');
title('Voltage change vs Object Size'); 

%% Surface V vs Size
rs = r*15;
surf([1:9],rs,ys')
title('Surface Plot of the Object Size vs the Measured Disturbance Voltage')
xlabel('Electrode Channel')
ylabel('Object Size (inches)')
zlabel('Disturbance Voltage (V)')

