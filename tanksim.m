function [vd, vo1, vh1, electrode_nodes] = tanksim(c,r,x,y, name)
% tanksim utilized the Eidors tool set to simulate
% the voltage measurements for a rectangular tank
% with a 10 electride linear array

ELEC_COUNT = 10;
GND_ELEC_IDX = 10;
meter_per_in = 0.0254; % meters per inch
salt_water_conductivity = 0.305; % ohms_meter
tank_dims = [40,40]; % elements

tank_mdl =  mk_common_model('f2s',ELEC_COUNT);
e = size(tank_mdl.fwd_model.elems,1);

for ii = 1:length(tank_mdl.fwd_model.electrode)
    tank_mdl.fwd_model.electrode(ii).nodes = ii*2 + 10;
end

tank_mdl.fwd_model.gnd_node = ii*2 + 10;

tank_shape = [30,30]; % in
tank_shape = tank_shape * meter_per_in; % convert to meter

single_element_dim = tank_shape./tank_dims;
element_conductivity = salt_water_conductivity / single_element_dim(1);
bkgnd = element_conductivity;
fprintf('Conductivity of Water: %f', bkgnd);

img = mk_image(tank_mdl.fwd_model, bkgnd);


stim = mk_stim_patterns(ELEC_COUNT,1,'{mono}','{mono}',{},1);
img.fwd_model.stimulation = stim;
for i=1:ELEC_COUNT  
    img.fwd_model.stimulation(i).stim_pattern = [1,zeros(1,ELEC_COUNT-2),-1]'; 
end
img.fwd_model.meas_select = [0 1];

img_h = img;
img_o = img;

select_fcn = inline(sprintf('(x+%f).^2+(y+%f).^2<%f^2', x, y, r),'x','y','z');
img_o.elem_data = (bkgnd*1+(c-bkgnd)*elem_select(img.fwd_model, select_fcn));

winsize = [ 0 0 800 600];
f = figure('Position',winsize);
axis tight

img_h.fwd_solve.get_all_meas = 1;
vh= fwd_solve(img_h);

img_o.fwd_solve.get_all_meas = 1;
vo= fwd_solve(img_o);

img_v = rmfield(img_o, 'elem_data');

% Show homoeneous image
a = subplot(231);
title(a,'Object Position');
show_fem(img_o);
axis tight

% Show inhomoeneous image
b = subplot(232);
show_current(img_o,vo.volt(:,1));
axis tight
title(b,'Current Path Tank');
axis([-1,1,-1,1]);

% Show difference image
b = subplot(233);
img_v.node_data = vh.volt(:,1) - vo.volt(:,1);
img_v.calc_colours.cb_shrink_move = [0.3,0.6,+0.03];
show_current(img_o,vh.volt(:,1)-vo.volt(:,1));
axis tight
title(b,'Change in Current Path');
axis([-1,1,-1,1]);
electrode_nodes = [img.fwd_model.electrode.nodes];
vd = abs(vh.volt(electrode_nodes,1) - vo.volt(electrode_nodes,1));
vh1 = vh.volt(electrode_nodes,1);
vh1d = diff(flipud(vh1));
vo1 = diff(flipud(vo.volt(electrode_nodes,1)));
title('Differential Current Image');
d= subplot(2,3,[4,5,6]);

bar(vo1-vh1d);
axis tight

vd = vo1-vh1d;

title(d,'Voltage Measured by Electrodes');
ylabel('Volts');
xlabel('Electrode ID#')
ylim([-5.5e-4 2.0e-4]);

fname = sprintf('%s-%dohm_m-rod%.2f-x%1.1f-y%1.1f',name,c,r,x,y);
fname = strrep(fname, '.', '_');
saveas(f,sprintf('%s.png',fname),'png');
end

