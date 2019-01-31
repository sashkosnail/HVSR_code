function applyHVSRModel(HVSR)
	base_figure_id = 1000;
	d=HVSR.Data{1};
	t=(0:1:length(d)-1)/HVSR.Fs;

	main_fig = figure(base_figure_id);clf;
	ax(3) = subplot('Position', [0.1, 0.4, 0.8, 0.2], 'Parent', main_fig, ...
		'XGrid', 'on', 'YGrid', 'on', 'NextPlot', 'add');
	ax(2) = subplot('Position', [0.1, 0.6, 0.8, 0.2], 'Parent', main_fig, ...
		'XGrid', 'on', 'YGrid', 'on', 'NextPlot', 'add');
	ax(1) = subplot('Position', [0.1, 0.8, 0.8, 0.2], 'Parent', main_fig, ...
		'XGrid', 'on', 'YGrid', 'on', 'NextPlot', 'add');
	linkaxes(ax);
	axp(1) = subplot('Position', [0.075, 0.05, 0.25, 0.3], ...
		'Parent', main_fig, 'NextPlot', 'add');
	axp(2) = subplot('Position', [0.375, 0.05, 0.25, 0.3], ...
		'Parent', main_fig, 'NextPlot', 'add');
	axp(3) = subplot('Position', [0.675, 0.05, 0.25, 0.3], ...
		'Parent', main_fig, 'NextPlot', 'add');
	linkaxes(axp);
	xl=[t(1) t(end)];
	lines = [];
	hLines = [];
	hFigs = main_fig;
	hFigs(1) = [];
	mad = max(max(abs(d)));
	start_ed = uicontrol('Style','edit', 'Units', 'Pixels', ...
		'Position', [0 10 50 20], 'callback', @time_change, ...
		'String', num2str(xl(1)));
	end_ed = uicontrol('Style','edit', 'Units', 'Pixels', ...
		'Position', [60 10 50 20], 'callback', @time_change, ...
		'String', num2str(xl(end)));
	uicontrol('style', 'pushbutton', 'Units', 'Pixels', ...
		'Position' ,[120 10 70 20], 'callback', @lineMode, ...
		'String', 'LineMode');
	uicontrol('style', 'pushbutton', 'Units', 'Pixels', ...
		'Position' ,[200 10 70 20], 'callback', @clearLines, ...
		'String', 'ClearLines');
	
	l = 'TRV';
	titles = {'TR','RV','VT'};
	for n=1:1:3
		plot(ax(n), t, d(:,n));
		if(n~=3)
			ax(n).XTickLabel = [];
		end
		legend(ax(n), l(n));
		axis(ax(n), [xl [-1 1]*mad])
		
		plot(axp(n), d(:,n), d(:,mod(n,3)+1));
		title(axp(n), titles{n});
		axis(axp(n), [-1 1 -1 1]*mad);
	end
	
	function lineMode(~,~)
		done = 0;
		for k=1:1:3
			cla(axp(k));
			axp(k).NextPlot = 'add';
		end
		while 1
			disp(length(lines))
			[x, ~, button] = ginput(1);
			if(isempty(button))
				button = 2;
			end
			switch button
				case 1
					[~, fi] = min(abs(t-x));
					lines(end+1) = t(fi);  %#ok<AGROW>
				case 3
					if(~isempty(lines))
						tdist = abs(lines - x);
						[~, pidx] = min(tdist);
						lines(pidx) = [];
					end
				otherwise
					done = 1;
			end
			
			lines = sort(lines);
			plotLines(lines);
			if(done)
				break;
			end
		end
		plotSections();
	end
	
	function clearLines(~,~)
		lines=[];
		plotLines(lines);
	end

	function plotLines(lines)
		for kk = 1:1:length(hFigs)
			if(ishandle(hFigs(kk)))
				close(hFigs(kk))
			end
		end
		for k = 1:1:numel(hLines)
			if(ishandle(hLines(k)))
				delete(hLines(k));
			end
		end
		
		for jj = 1:1:3
			for nn = 1:1:length(lines)
				hLines(nn,jj) = plot(ax(jj), [1 1]*lines(nn), [1 -1]*mad);
			end
		end
		
		color = 'rgbkcmy';
		for iii = 1:1:length(lines)-1;
			[~, idx] = min(abs([t-lines(iii); t-lines(iii+1)]'));
			for np=1:1:3
				plot(axp(np), d(idx(1):idx(2),np), ...
					d(idx(1):idx(2),mod(np,3)+1), ...
					color(1+mod(iii-1, length(color))));
				hold on;
			end
		end
	end

	function plotSections()
		for kk = 1:1:length(hFigs)
			if(ishandle(hFigs(kk)))
				close(hFigs(kk))
			end
		end
		num_sections = length(lines)-1;
		for id = 1:1:num_sections
			hFigs(id) = create_figure(base_figure_id + id); %#ok<AGROW>
			[~, idx] = min(abs([t-lines(id); t-lines(id+1)]'));
			interval = idx(1):1:idx(2);
			N = length(interval);
			
			f = HVSR.Fs*(0:ceil(N/2)-1)'/N;
			freq = [f; f(end-mod(N,2):-1:1)];
			if(isfield(HVSR, 'ExternalModel'))
				params = HVSR.ExternalModel;
			else
				params = HSVR.ModelParams;
			end
			[bpf, ~] = CalculateBPFResponse(params, 'freq-sum', 0, freq);
			
			fftdata = fft(d(interval,:), N, 1);
			fftdata_mod = [repmat(1./bpf, 1, 2) bpf].*fftdata;
			d_mod = ifft(fftdata_mod, 'symmetric');
			
			fftdata = abs(fftdata(1:ceil(N/2),:) + ...
 				fftdata(end:-1:floor(N/2)+1,:))/N;
			fftdata_mod = abs(fftdata_mod(1:ceil(N/2),:) + ...
 				fftdata_mod(end:-1:floor(N/2)+1,:))/N;
			
			mads = max(max(abs(d(interval,:))));
			rng = [max(10e-6,min(min(fftdata))) max(max(fftdata))];
			for kkk = 1:1:3
				tax = hFigs(id).UserData.Tax(kkk);
				fax = hFigs(id).UserData.Fax(kkk);
				
				plot(tax, t(interval), d(interval,kkk), 'k');
				plot(tax, t(interval), d_mod(:,kkk), 'r');
				axis(tax, [lines(id) lines(id+1) [-1 1]* mads]);
				
				semilogy(fax, f, fftdata(:,kkk), 'k');
				semilogy(fax, f, fftdata_mod(:,kkk), 'r');
				if(kkk == 3)
					tax.Children = tax.Children(end:-1:1);
				end
				if(kkk ~= 3)
					tax.XTickLabel = [];
					fax.XTickLabel = [];
				end
				axis(fax, [0.1 HVSR.Fs/2 10.^ceil(log10(rng))]);
			end
		end
	end

	function hfig = create_figure(fid)
		hfig = figure(fid);clf
		WindowAPI(hfig, 'maximize');
		for nnn=1:1:3
			Tax(nnn) = axes('Parent', hfig, ...
				'DefaultLineLineWidth', 2, 'Units', 'normalized', ...
				'NextPlot', 'add', 'XScale', 'linear', 'XGrid', 'on', ...
				'YGrid', 'on', 'GridColorMode', 'manual', ...
				'GridColor', [1 1 1]*0.7, 'GridAlpha', 1, ...
				'FontSize', 20, 'Position', [0.06 0.99-nnn*0.295 0.54 0.29]); %#ok<AGROW>
			Fax(nnn) = axes('Parent', hfig, ...
				'DefaultLineLineWidth', 2, 'Units', 'normalized', ...
				'NextPlot', 'add', 'XScale', 'log', 'XGrid', 'on', ...
				'YGrid', 'on', 'YScale', 'log', 'GridColorMode', 'manual', ...
				'GridColor', [1 1 1]*0.7, 'GridAlpha', 1, ...
				'FontSize', 20, 'Position', [0.67 0.99-nnn*0.295 0.32 0.29]); %#ok<AGROW>
		end
		linkaxes(Tax);
		linkaxes(Fax);
		hfig.UserData.Tax = Tax;
		hfig.UserData.Fax = Fax;
	end

	function time_change(~,~)
		try
			xl = str2double({start_ed.String end_ed.String});
			for k=1:1:3
				xlim(ax(k), xl)
			end
		catch
			disp('BadTIme')
		end
	end	
end