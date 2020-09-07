% clear
load('../profile_layout2.mat')
% points(28:29)=[];
points_mat = [points(:).Lat; points(:).Lon; points(:).Altitude]';
x = rock_drift(:,1)*1000;
r = rock_drift(:,3);
d = rock_drift(:,2);
dist=distance(repmat(points_mat(north_point,1:2),length(points_mat),1),points_mat(:,1:2));
[dist, ix] = sort(dist);
dist = dist*x(end)/dist(end);
points_by_distance = points(ix);
tmp = {points.Name}';
% tmp = regexpi(tmp, 'H7LE\D*(\d+)', 'tokens','once');
tmp = regexpi(tmp, '\D*(\d+)', 'tokens','once');
tmp = unique(str2double(vertcat(tmp{:})));
mats = dir('*.mat');
HVSRs = [];
for km = 1:length(tmp)
% 	name = ['h' num2str(tmp(km)) 'D.mat'];
	name = [num2str(tmp(km)) '.mat'];
	load(name);
	disp(name);
	if(strcmp(name,'1.mat'))
		kkk=[HVSR.LowSources(1:2:end).mean];
		HVSRs = [HVSRs [kkk(1:2:end,:); zeros(4096,2)]];
	elseif(strcmp(name,'11.mat')||strcmp(name,'12.mat')||strcmp(name,'13.mat')||strcmp(name,'20.mat'))
		kkk=[HVSR.LowSources(1:2:end).mean];
		HVSRs = [HVSRs interp1(HVSR.f, kkk, f)];
	else
		HVSRs = [HVSRs HVSR.LowSources(1:2:end).mean];
	end
% 	if(strcmp(name,'h11D.mat'))
% 		HVSRs = [HVSRs HVSR.LowSources.mean];
% 	elseif(strcmp(name,'h20D.mat'))
% 	else
% 		HVSRs = [HVSRs HVSR.LowSources(1:2:end).mean];
% 	end
end
%%
HVSRs_by_distance = HVSRs(:,ix);
f = HVSR.f;
% [X, F] = meshgrid(dist, f);
% dq = sort(unique(([dist', dist(1):100:dist(end)])'));
% [Xq, Fq] = meshgrid(dq, f); 
% HVSRq = griddata(F, X, log10(HVSRs_by_distance), Fq, Xq);
%%
fig = figure(341); clf
set(fig, 'Color', 'w');
a=axes('Parent', fig, 'YScale', 'log', 'NextPlot', 'add', 'FontSize', 12, 'FontWeight', 'bold');

% lvl = linspace(-0.5, 1.5, 15);
% contourf(a, dq, f, HVSRq);%, lvl);
contourf(dist, f, log10(HVSRs_by_distance));
xlabel('Distance along Profile [m]', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Frequency [Hz]', 'FontSize', 12, 'FontWeight', 'bold')
ylim([0.1 60]);
% xlim([4900 5800]);
a.YTick = [0.1 0.5 1 2 5 10 20 50];
a.YTickLabel = a.YTick;
% a.XTick = dist;
c=colorbar;
c.Label.String = 'log_1_0(HVSR)';
c.Label.FontSize = 12;
c.Label.FontWeight = 'bold';
%%
for lk = 1:1:length(dist);
	plot(a, dist(lk)*ones(size(f)), f, 'k--');
end
