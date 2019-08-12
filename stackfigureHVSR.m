global PathName
[FileName, PathName, ~] = uigetfile([PathName, '*.mat'], ...
	'Pick File','MultiSelect','on');
if(~iscell(FileName))
	FileName = {FileName}; end
if(FileName{1} == 0)
	return; 
end    
folders = {'D:\Projects\PhD\AutoDRM\P2data\20170711\', ...
	'D:\Projects\PhD\AutoDRM\P2data\20090605\', ...
	'D:\Projects\PhD\AutoDRM\P2data\20051020\', ...
	'D:\Projects\PhD\AutoDRM\P2data\20040804\'};
folders = sort(folders);
fig=figure(3);clf;
fig.Color = 'w';
colors = 'rgbm';
for k=1:1:length(FileName)
	load([PathName FileName{k}]);
	station = regexp(FileName{k},'[A-Z]{4}','match');
	freq = HVSR.f;
	% hvsr_tab = tab_grp.Children(end-2);
	% tab_grp.SelectedTab = hvsr_tab;
	% ax = hvsr_tab.UserData.ax;
	% delete(ax.Children(1:3))
	% 
	% ax.Childern(1).Color = [0 0 0];
	% ax.Childern(2).Color = [0 0 0];
	% ax.Childern(3).Color = [0 0 0];
	ax = subaxis(3,2,k,'sv',0,'mt',0.0,'mb',0.075,'ml',0.05,'sh',0.05,'mr',0);
	h = semilogx(freq, HVSR.LowSources.mean, 'k-', 'LineWidth', 2, ...
		'DisplayName', 'Noise HVSR mean');
	hold on;
	hh = semilogx(freq, ...
		HVSR.LowSources.mean*[1 1] + HVSR.LowSources.std*[1 -1], ...
		'k--', 'LineWidth', 1.5);
	hh(1).DisplayName = 'Noise HVSR \pmstd';
	h = [h; hh(1)]; %#ok<AGROW>
	for n=1:1:length(folders)
		year = regexp(folders{n},'20[0-9]{2}','match');
		tmp = load([folders{n} station{1} year{1} '.mat']);
		h = [h; semilogx(tmp.HVSR.f, tmp.HVSR.LowSources.mean, ...
			colors(n), 'DisplayName', year{1}, 'LineWidth', 1)];  %#ok<AGROW>
	end
	grid on; axis(ax, 'tight'); ax.XScale = 'log'; hold off
	xlim([0.1 50]);
	ax.XTickLabel = ax.XTick;
	xlabel('Frequency [Hz]', 'FontSize', 18);
% 	ax.XAxis.Visible = 'off';
	ylabel('H/V', 'FontSize', 18);
	title(station, 'FontSize', 20, 'Units', 'normalized', 'Position', [0.9 0.85 0]);
	if(k==6)
		l=legend(h);
		set(l, 'FontSize', 18, 'Location', 'NorthWest');
	end
	if(k<5)
% 		ax.XAxis.Visible = 'on';
	ax.XTickLabel = [];
	end
end
export_fig -painters -r200 D:\Documents\PhD\Writing\HVSRs.png