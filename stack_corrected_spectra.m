global PathName
[FileName, PathName, ~] = uigetfile([PathName, '*.mat'], ...
	'Pick File','MultiSelect','on');
if(~iscell(FileName))
	FileName = {FileName}; end
if(FileName{1} == 0)
	return; 
end    
smooth = 1;
fig=figure(2+smooth);clf;
fig.Color = 'w';
colors = 'krgbmc';
for n=1:1:length(FileName)
	load([PathName FileName{n}]);
	station = regexp(FileName{n},'[A-Z]{4}','match');
	if(smooth)
		HT = HVSR.HighSources.T;
		HR = HVSR.HighSources.R;
		HV = HVSR.HighSources.V;
		fftdata = [HT HR HV];
		freq = HVSR.f;
		L = length(fftdata);
	else
		L=length(HVSR.Data{1});
		fftdata = abs(fft(HVSR.Data{1}, L, 1));
		freq = HVSR.Fs*(0:(L-1)/2)'/L;
		fftdata = fftdata(1:L/2,:)+fftdata(end:-1:1+L/2,:);
	end
	fftdata = fftdata.*repmat((2*pi*freq),1,3);
	params = HVSR.ExternalModel;
	[bpf, ~] = CalculateBPFResponse(params, 'freq-sum', 0, freq);
	correction = [1./bpf 1./bpf bpf];
	mod_fftdata = fftdata.*correction;
	tmp={'NS','EW','V'};
	for k=1:3
		ax1 = subaxis(3,2,2*k-1,'sv',0,'mt',0.0,'mb',0.075,'ml',0.05,'sh',0.05,'mr',0);
		ax2 = subaxis(3,2,2*k,'sv',0,'mt',0.0,'mb',0.075,'ml',0.05,'sh',0.05,'mr',0);
		linkaxes([ax1 ax2]); grid(ax1,'on'); grid(ax2,'on');
		set(ax1, 'NextPlot', 'add', 'XScale', 'log', 'YScale', 'log');
		set(ax2, 'NextPlot', 'add', 'XScale', 'log', 'YScale', 'log');
		h=loglog(freq, fftdata(:,k), colors(n), 'Parent', ax1, 'LineWidth', 1.5);
		h.DisplayName = [station{1} ' original ' tmp{k}];
		h=loglog(freq, mod_fftdata(:,k), colors(n), 'Parent', ax2, 'LineWidth', 1.5);
		h.DisplayName = [station{1} ' modified' tmp{k}];
		xlim([0.1 50]);
		ax1.XTickLabel = ax1.XTick;
		ax2.XTickLabel = ax2.XTick;
		if(k<3)
			ax1.XTickLabel = [];
			ax2.XTickLabel = [];
		else
			xlabel(ax1,'Frequency [Hz]', 'FontSize', 18);
			xlabel(ax2,'Frequency [Hz]', 'FontSize', 18);
		end
		if(k==1)
			title(ax1, 'Original', 'FontSize', 20, 'Units', 'normalized', ...
				'Position', [0.9 0.85 0]);
			title(ax2, 'Modified', 'FontSize', 20, 'Units', 'normalized', ...
				'Position', [0.9 0.85 0]);
		end
		ylabel('Amplitude', 'FontSize', 18);
		legend(ax1,'off');
		l=legend(ax1,'show');
		set(l, 'FontSize', 12, 'Location', 'NorthWest');
		legend(ax2,'off');
		l=legend(ax2,'show');
		set(l, 'FontSize', 12, 'Location', 'NorthWest');
	end
end
% export_fig -painters -r200 D:\Documents\PhD\Writing\spectra_stack.png