function HVSRgui
    global Ts frame_size PathName frame_margin frame_overlap wnd_sliders PP fftSmoothN
    if((PathName == 0) | (~exist('PathName', 'var'))) %#ok<OR2>
        PathName = ''; end
    [FileName, PathName, ~] = uigetfile([PathName, '\*.mat'],'Pick File','MultiSelect','on');
    if(~iscell(FileName))
        FileName = {FileName}; end
    if(FileName{1} == 0)
        return; 
    end
    
    wnd_sliders = [];
    
    frame_margin = 0.1;
    frame_size = 2048;
    frame_overlap = 0.5;
    Ts=-1;
	
	fftSmoothN = 256;
	
	PP.Source = 'L1';
	PP.MinPeakProminence = 0.5;
	PP.CFreqRange = -1;
	PP.PowerRange = [1 256];
	PP.GainRange = [0.1 20];
	
    
    fig = figure(1000); clf
    pause(0.00001);
    set(fig, 'ToolBar', 'none');
%     set(fig, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    
        
    tab_group = uitabgroup('Parent', fig, 'Units', 'normalized', ...
        'Position', [0, 0.05, 1, 0.95]);
    for idx = 1:1:length(FileName)
        createSignalTab(FileName{idx}, tab_group);
    end
    createHVSRTab(tab_group);
	createModelTab(tab_group);

    start_position = [10 30];		
    next_size = [100 20];
    frame_size_text = uicontrol('Style','text', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'String', 'Frame Size:'); %#ok<NASGU>
	next_size = [100 20];
	start_position(2) = start_position(2) - next_size(2);	
    frame_size_edit = uicontrol('Style','edit', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'KeyReleaseFcn', @keydown_editbox_CB, 'UserData', 1, ...
            'String', num2str(frame_size));%#ok<NASGU>
	start_position = start_position + next_size + [10 0];	
	
	next_size = [100 20];
    frame_margin_text = uicontrol('Style','text', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'String', 'Frame Margin:'); %#ok<NASGU>
	next_size = [100 20];
	start_position(2) = start_position(2) - next_size(2);
    frame_margin_edit = uicontrol('Style','edit', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'KeyReleaseFcn', @keydown_editbox_CB, 'UserData', 2, ...
            'String', num2str(frame_margin));%#ok<NASGU>
	start_position = start_position + next_size + [10 0];
	
	next_size = [100 20];
    frame_overlap_text = uicontrol('Style','text', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'String', 'Frame Overlap:'); %#ok<NASGU>
	next_size = [100 20];
	start_position(2) = start_position(2) - next_size(2);
    frame_overlap_edit = uicontrol('Style','edit', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'KeyReleaseFcn', @keydown_editbox_CB, 'UserData', 3, ...
            'String', num2str(frame_overlap));%#ok<NASGU>
	start_position = start_position + next_size + [40 0];
	
	next_size = [100 20];
    fftSmoothN_text = uicontrol('Style','text', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'String', 'fftSmoothN:'); %#ok<NASGU>
	next_size = [100 20];
	start_position(2) = start_position(2) - next_size(2);	
    fftSmoothN_edit = uicontrol('Style','edit', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'KeyReleaseFcn', @keydown_editbox_CB, 'UserData', 9, ...
            'String', num2str(fftSmoothN));%#ok<NASGU>
	start_position = start_position + next_size + [40 0];
	
	next_size = [100 20];
    model_source_text = uicontrol('Style','text', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'String', 'Model Source'); %#ok<NASGU>
	next_size = [100 20];
	start_position(2) = start_position(2) - next_size(2);
    model_source_edit = uicontrol('Style','edit', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'KeyReleaseFcn', @keydown_editbox_CB, 'UserData', 4, ...
            'String', PP.Source);%#ok<NASGU>
	start_position = start_position + next_size + [10 0];
	
	next_size = [100 20];
    model_peak_text = uicontrol('Style','text', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'String', 'MinPeakProminence'); %#ok<NASGU>
	next_size = [100 20];
	start_position(2) = start_position(2) - next_size(2);
    model_peak_edit = uicontrol('Style','edit', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'KeyReleaseFcn', @keydown_editbox_CB, 'UserData', 5, ...
            'String', PP.MinPeakProminence);%#ok<NASGU>
	start_position = start_position + next_size + [10 0];
	
	next_size = [100 20];
    model_frange_text = uicontrol('Style','text', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'String', 'Freq Range'); %#ok<NASGU>
	next_size = [100 20];
	start_position(2) = start_position(2) - next_size(2);
    model_frange_edit = uicontrol('Style','edit', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'KeyReleaseFcn', @keydown_editbox_CB, 'UserData', 6, ...
            'String', PP.CFreqRange);%#ok<NASGU>
	start_position = start_position + next_size + [10 0];
	
	next_size = [100 20];
    model_prange_text = uicontrol('Style','text', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'String', 'Power Range'); %#ok<NASGU>
	next_size = [100 20];
	start_position(2) = start_position(2) - next_size(2);
    model_prange_edit = uicontrol('Style','edit', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'KeyReleaseFcn', @keydown_editbox_CB, 'UserData', 7, ...
            'String', num2str(PP.PowerRange, '[%3.2f %3.2f]'));%#ok<NASGU>
	start_position = start_position + next_size + [10 0];
	
	next_size = [100 20];
    model_grange_text = uicontrol('Style','text', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'String', 'Gain Range'); %#ok<NASGU>
	next_size = [100 20];
	start_position(2) = start_position(2) - next_size(2);
    model_grange_edit = uicontrol('Style','edit', 'Parent', fig, ...
            'Units', 'pixels', 'Position', [start_position next_size], ...
            'KeyReleaseFcn', @keydown_editbox_CB, 'UserData', 8, ...
            'String', num2str(PP.GainRange, '[%3.2f %3.2f]'));%#ok<NASGU>		
	start_position = start_position + next_size + [40 -next_size(2)];

	next_size = [100 30];
	Calculate_button = uicontrol('Style', 'pushbutton', 'String', 'Calculate HVSR', ... 
        'Parent', fig, 'Callback', @calcHVSR, 'Units', 'pixels',...
		'Position', [start_position next_size]); %#ok<NASGU>
	start_position(1) = start_position(1) + next_size(1) + 10;	

	next_size = [100 30];
	Model_button = uicontrol('Style', 'pushbutton', 'String', 'Model HVSR', ... 
        'Parent', fig, 'Callback', @modelHVSR, 'Units', 'pixels',...
		'Position', [start_position next_size]); %#ok<NASGU>
	next_size = [100 30];
	start_position(1) = start_position(1) + next_size(1) + 10;
	
    Export_button = uicontrol('Style', 'pushbutton', 'String', 'Export', ... 
        'Parent', fig, 'Callback', @exportHVSR, 'Units', 'pixels',...
		'Position', [start_position next_size]); %#ok<NASGU>
	
	
    figure(fig);
end

function createModelTab(tab_group)
global model_tab
	model_tab = uitab('Parent', tab_group, 'Title', 'ModelHVSR');
	
	model_tab.UserData.ax = axes('Parent', model_tab, 'DefaultLineLineWidth', 2, ...
		'Units', 'normalized', 'Position', [0.025 0.05 0.97 0.94], ...
		'XScale', 'log', 'XGrid', 'on', 'YGrid', 'on', 'NextPlot', 'add');
	
end

function createHVSRTab(tab_group)
    global num_chans hvsr_tab
    hvsr_tab = uitab('Parent', tab_group, 'Title', 'HVSR');
	
	for k=1:1:num_chans
	   hvsr_tab.UserData.ax(k) = subplot('Position', ...
		   [0.025 1-k/num_chans+0.05 0.97 1/num_chans-0.06], 'Parent', hvsr_tab);
	   grid on;
	end
end

function createSignalTab(file, tab_group)
    global Ts Fs PathName num_chans wnd_sliders
    tab = uitab('Parent', tab_group, 'Title', file);
    matfile = strcat(PathName, file);
    load(matfile,'D');
    if(istable(D)) %#ok<NODEF>
        D = table2array(D(:,1:end));
    end
    t=D(:,1);
    if(Ts~=-1 && Ts~=(t(2)-t(1)))
        return
    elseif(Ts == -1)
        Ts = t(2)-t(1); Fs = 1/Ts;
    end
    data = D(:,2:end);
    data = data - ones(length(data),1)*mean(data);
    num_chans = size(data,2)/3;if(num_chans>4); num_chans=4;end
    vector_data = sqrt(data(:,1:3:end).^2+data(:,2:3:end).^2+data(:,3:3:end).^2);
    for kk=1:1:num_chans
        panels(kk) = uipanel('Position', [0 1-kk/num_chans 0.04 1/num_chans], ...
            'Tag', num2str(kk), 'Parent', tab);         %#ok<AGROW>
        fig_panel = uipanel('Position', ...
            [0.04 1-kk/num_chans 1 1/num_chans], 'Parent', tab');
        threshold_slider = uicontrol('Style', 'slider', ...
            'Min', 0, 'Max', 1.1, 'Value', 1.1, ...
            'Units', 'normalized', 'Position', [0 0.1 0.45 0.8], ...
            'String', 'Threshold', 'SliderStep',[0.05 0.1], ...
            'Callback', @parameter_changed, 'Parent', panels(kk)); %#ok<NASGU>
        wind_size_slider = uicontrol('Style', 'slider', ...
            'Min', 1, 'Max', Fs*15, 'Value', Fs*15, ...
            'Units', 'normalized', 'Position', [0.55 0.1 0.45 0.8], ...
            'String', 'Duration', 'SliderStep', Ts*[10 100], ...
            'Callback', @parameter_changed, 'Parent', panels(kk));
        threshold_readout = uicontrol('Style','text', 'Parent', panels(kk), ...
            'Units', 'normalized', 'Position', [0 0.9 0.45 0.1]); %#ok<NASGU>
        wind_size_readout = uicontrol('Style','text', 'Parent', panels(kk), ...
            'Units', 'normalized', 'Position', [0.55 0.9 0.45 0.1]); %#ok<NASGU>
        use_file_check = uicontrol('Style', 'checkbox', ...
            'Value', 1, 'String', 'Use This Data', 'Parent', panels(kk), ...
            'Units', 'normalized', 'Position', [0 0 1 0.1]);
        use_file_check.UserData.Data = data(:,(1+(kk-1)*3):1:(3*kk));
        use_file_check.UserData.Vector = vector_data(:,kk);
        chax = subplot('Position', [0.025 0.025 0.975 0.975], 'Parent',fig_panel);
        set(panels(kk), 'UserData', chax);
        set(tab, 'UserData', panels);
        hold on; grid on
%         chax.YAxisLocation = 'right';
        parameter_changed(wind_size_slider);
        wnd_sliders = [wnd_sliders wind_size_slider]; %#ok<AGROW>
    end
end

function keydown_editbox_CB(hObject, eventData)
global frame_size frame_margin frame_overlap wnd_sliders PP fftSmoothN
	if(~strcmp(eventData.Key, 'return'))
		return;
	end
	if(hObject.UserData ~= 4)
		val = eval(hObject.String);
	else
		val = hObject.String;
	end
	calc_frames = 0;
	calc_hvsr = 0;
	switch hObject.UserData
		case 1
			frame_size = val;
			calc_frames = 1;
		case 2
			frame_margin = val;
			calc_frames = 1;
		case 3
			frame_overlap = val;
			calc_frames = 1;
		case 4
			PP.Source = hObject.String;
		case 5
			PP.MinPeakProminence = val;
		case 6
			PP.CFreqRange = val;
		case 7
			PP.PowerRange = val;
		case 8 
			PP.GainRange = val;
		case 9
			fftSmoothN = val;
			calc_hvsr = 1;
		otherwise
	end
	if(calc_frames && ~isempty(wnd_sliders))
		for s = wnd_sliders
			parameter_changed(s)
		end
	end
	if(calc_hvsr)
		calcHVSR();
	end
end

function parameter_changed(hObject, ~, ~)
    global Ts Fs frame_size  frame_margin frame_overlap
    panel = hObject.Parent;
    thisFigure = panel.UserData;
    ch_data = panel.Children(1).UserData.Data;
    ch_vector = panel.Children(1).UserData.Vector;
    traffic_duration = panel.Children(4).Value;
    traffic_threshold = panel.Children(5).Value;
    set(panel.Children(2), 'String', num2str(traffic_duration*Ts));
    set(panel.Children(3), 'String', num2str(traffic_threshold)); 
    slider_purpose = get(hObject, 'String');
    if(strcmp(slider_purpose,'Duration'))
        win_size = min(ceil(traffic_duration/2)*2, ...
            ceil((length(ch_vector)-1)/4)*2)+1;
        window = bartlett(win_size);
        panel.Children(5).UserData = apply_window(window, ch_vector);
    end
    smooth_vector = panel.Children(5).UserData;
    maxval = max(smooth_vector);
    minval = min(smooth_vector);
    spread = maxval-minval;
    threshold = traffic_threshold * spread + minval;
    margin = spread*frame_margin;
    alow = threshold - margin;
    low_level = smooth_vector<alow;
    ahigh = threshold + margin;
    high_level = smooth_vector>ahigh;
    subplot(thisFigure); hold off
    t = (0:1:length(ch_data)-1)*Ts;
    plot(t, ch_data,':');hold on
    plot(t, smooth_vector,'k','LineWidth',2)
    plot(t, low_level*(maxval-minval)+minval,'g')
    plot(t, high_level*(maxval-minval)+minval,'m')
    plot(t([1, end]), [1 1]*alow,'r--');
    plot(t([1, end]), [1 1]*ahigh,'b--');
    plot(t([1, end]), [1 1]*threshold,'k');
%     axis([0 t(end) min(min(ch_data)) 1.1*max(max([ch_data smooth_vector]))]);%[-0.707 0.707]])
    frames_Low = findFrames(low_level, frame_size, frame_overlap);
    frames_High = findFrames(high_level, frame_size, frame_overlap);
    count = 0;
    
    frame_low_bound = min(min(ch_data))*[1 1];
    for id=frames_Low
        plot(   [id, id+frame_size]/Fs,...
                frame_low_bound*(1-0.9/3*(mod(count,3)+1)), ...
                'LineWidth',3,'Color','g');
        count = count+1;
    end
    count = 0;
    for id=frames_High
        plot(   [id, id+frame_size]/Fs,...
                frame_low_bound*(1-0.9/3*(mod(count,3)+1)), ...
                'LineWidth',3,'Color','m');
        count = count+1;
    end
    panel.Children(1).UserData.Low = frames_Low;
    panel.Children(1).UserData.High = frames_High;
%     thisFigure.YAxisLocation = 'right';
	axis tight;
end

function calcHVSR(~,~)
	global Fs frame_size HVSR num_chans hvsr_tab isHVSRChanged
	tab_grp = hvsr_tab.Parent;
	tab_grp.SelectedTab = hvsr_tab;
    HVSR = struct('Fs', Fs);
    window = hann(frame_size + 1);
	window = window(1:end-1);
    ax = hvsr_tab.UserData.ax;
    for k=1:1:num_chans
        ax(k).UserData.HVSR_H =[];
        ax(k).UserData.HVSR_L =[];
		ax(k).UserData.HVert =[];
		ax(k).UserData.LVert =[];		
    end
    tabs = hvsr_tab.Parent.Children;
    for idx = 1:1:length(tabs)-2
        tab = tabs(idx);
        chan_panels = tab.UserData;
        for k = 1:1:num_chans
            usefile = chan_panels(k).Children(1);
            userdata = usefile.UserData;
			HVSR.Data{k} = userdata.Data;
            if(usefile.Value)
                [H, HVert, ~, ~] = calculateHVSR(userdata.Data, userdata.High, window, ax(k));
                [L, LVert, ~, ~] = calculateHVSR(userdata.Data, userdata.Low, window, ax(k));
                ax(k).UserData.HVSR_H = [ax(k).UserData.HVSR_H H]; 
                ax(k).UserData.HVSR_L = [ax(k).UserData.HVSR_L L];
				ax(k).UserData.HVert = [ax(k).UserData.HVert HVert]; 
                ax(k).UserData.LVert = [ax(k).UserData.LVert LVert]; 
            end
        end
    end
    tmp = [frame_size/2, num_chans];
    HmeanHVSR = zeros(tmp);
    HstdHVSR = zeros(tmp); 
    LmeanHVSR = zeros(tmp); 
    LstdHVSR = zeros(tmp);
	LmeanVert = zeros(tmp);  
	HmeanVert = zeros(tmp); 
    freq = Fs*(0:frame_size/2-1)'/frame_size;
    for k=1:1:num_chans
        axes(ax(k));cla(ax(k));hold on %#ok<LAXES>
        if(~isempty(ax(k).UserData.HVSR_H))
            HmeanHVSR(:,k) = mean(ax(k).UserData.HVSR_H, 2);
            HstdHVSR(:,k) = std(ax(k).UserData.HVSR_H, 1, 2);
			HmeanVert = mean(ax(k).UserData.HVert, 2);
        else
            HmeanHVSR(:,k) = 0;
            HstdHVSR(:,k) = 0;
			HmeanVert(:,k) = 0;
        end
        if(~isempty(ax(k).UserData.HVSR_L))
            LmeanHVSR(:,k) = mean(ax(k).UserData.HVSR_L, 2);
            LstdHVSR(:,k) = std(ax(k).UserData.HVSR_L, 1, 2);
			LmeanVert(:,k) = mean(ax(k).UserData.LVert, 2);
        else
            LmeanHVSR(:,k) = 0;
            LstdHVSR(:,k) = 0;
			LmeanVert(:,k) = mean(ax(k).UserData.LVert);
        end
        
        num_H = size(ax(k).UserData.HVSR_H,2);
        num_L = size(ax(k).UserData.HVSR_L,2);
        
        HVSR.HighSources(k).mean = HmeanHVSR(:,k);
        HVSR.HighSources(k).std = HstdHVSR(:,k);
		HVSR.HighSources(k).Vert = HmeanVert(:,k);
        HVSR.LowSources(k).mean = LmeanHVSR(:,k);
        HVSR.LowSources(k).std = LstdHVSR(:,k);
		HVSR.LowSources(k).Vert = LmeanVert(:,k);
		HVSR.f = freq;

        h_Lm = semilogx(freq, LmeanHVSR(:,k), 'r-', 'LineWidth', 1.5);
        h_Ls = semilogx(freq, LmeanHVSR(:,k)*[1 1]+LstdHVSR(:,k)*[1 -1], 'r--');
        h_Hm = semilogx(freq, HmeanHVSR(:,k), 'b-', 'LineWidth', 1.5); 
        h_Hs = semilogx(freq, HmeanHVSR(:,k)*[1 1]+HstdHVSR(:,k)*[1 -1], 'b--');
        legend([h_Lm h_Ls(1) h_Hm h_Hs(1)], ...
        {['Low Source mean N=', num2str(num_L)], 'Low Source \pmstd', ...
        ['High Source mean N=', num2str(num_H)], 'High Source \pmstd'}, ...
        'FontSize', 12, 'Location', 'west');
    
        grid on; axis tight; ax(k).XScale = 'log'; hold off
        xlim([min(freq) 50]);
        if(k~=num_chans)
            set(gca,'Xticklabel',[]);
        end
%         title(ax(k), ['Channel ' num2str(k)], 'Units', 'normalized', ...
%             'Rotation', 90, 'Position', [-0.02 0.5 0]);
    end
    xlabel('Frequency [Hz]');
	
	isHVSRChanged = 1;
end

function modelHVSR(~, ~)
global HVSR model_tab PP isHVSRChanged
persistent fpeaks upeaks params

	tab_grp = model_tab.Parent;
	tab_grp.SelectedTab = model_tab;
	ax = model_tab.UserData.ax;

	if(isempty(isHVSRChanged))
		return
	end
	if(isHVSRChanged)
		fpeaks = [];
		upeaks = [];
		isHVSRChanged = 0;
		params = [];
	end
	data = [];
	f = HVSR.f;
	OptimizeAndPlot()
	
	function OptimizeAndPlot()
		data_idx = str2num(PP.Source(2:end)); %#ok<ST2NM>
		switch upper(PP.Source(1))
			case 'L'
				data = HVSR.LowSources(data_idx).mean;
			case 'H'
				data = HVSR.HighSources(data_idx).mean;
		end
		data(1) = data(2);

		cla(ax);
		
		p1 = semilogx(f, data , 'b', 'Parent', ax);
		grid on; axis tight; ax.XScale = 'log'; 
		xlim(ax, [min(f) 50]); hold on
		
		if(isempty(fpeaks))
			[pk, loc] = findpeaks(data, f, 'MinPeakProminence', ...
				PP.MinPeakProminence);
			fpeaks = [loc, pk];
		end
		problem = SetupProblem(params);
		
		params = fmincon(problem);
% 		result = CalculateBPFResponse(params, 'freq-prod', 0);
% 		p3 = semilogx(f, result, 'r--', 'Parent', ax);
		[result, Wbpf]= CalculateBPFResponse(params,'freq-sum',0);
		error = abs(result-data)./data;
		
		p4 = semilogx(f, result, 'r', 'Parent', ax);
		p5 = semilogx(f, Wbpf, 'k--','LineWidth', 1, 'Parent', ax);
		p6 = semilogx(f, error,'g--', 'Parent', ax);
		grid on; axis tight; ax.XScale = 'log'; hold off
        xlim(ax, [min(f) 50]);
		
		legend([p1(1) p4(1) p5(1) p6(1)], ...
			{'HVSR', 'ParallelEq', 'BPFs', ...
			['Error RMS:' num2str(rms(error))]}, ...
			'FontSize', 12, 'Location', 'west');
		params = reshape(params, numel(params)/3, 3);
		HVSR.ModelParams = params;
	end
	
	function problem = SetupProblem(old_params)
		while 1
			if(~isempty(upeaks))
				hupeaks = semilogx(upeaks(:,1), upeaks(:,2), ...
					'ks', 'Parent', ax);
			end
			if(~isempty(fpeaks))
				hfpeaks = semilogx(fpeaks(:,1), fpeaks(:,2), ...
					'mh', 'Parent', ax);
			end
			[x, y, button] = ginput(1);
			
			if (isempty(button))
				continue;
			end
	
			switch button
				case 1
					[~, fi] = min(abs(f-x));
					upeaks(end+1,:) = [f(fi) data(fi)]; %#ok<AGROW>
				case 2
					break;
				case 3
					fdist = sqrt((x-fpeaks(:,1)).^2+(y-fpeaks(:,2)).^2);
					if(~isempty(upeaks))
						udist = sqrt((x-upeaks(:,1)).^2+(y-upeaks(:,2)).^2);
						[~, pidx] = min([fdist; udist]);
					else
						[~, pidx] = min(fdist);
					end
					
					Nfpeaks = size(fdist,1);
					if(pidx<=Nfpeaks)
						fpeaks(pidx, :) = [];
					else
						upeaks(pidx-Nfpeaks, :) = [];
					end
			end	
			try
				delete(hfpeaks);
			catch
			end
			try
				delete(hupeaks);
			catch
			end
		end
		all_peaks = [fpeaks; upeaks];
		all_peaks = sortrows(all_peaks, 1);
		
		Num_Filters = length(all_peaks);
		params = zeros(Num_Filters, 3);
		LB = zeros(Num_Filters, 3);
		UB = zeros(Num_Filters, 3);

		for fi = 1:1:length(all_peaks)
			params(fi,3) = all_peaks(fi,1);
			params(fi,1) = 2;
			params(fi,2) = all_peaks(fi,2);
			if(numel(PP.CFreqRange) == 1)
				CFreqRange = all_peaks(fi,1)*[1 1];
			else
				CFreqRange = PP.CFreqRange;
			end
			LB(fi,:) = [PP.PowerRange(1) PP.GainRange(1) CFreqRange(1)];
			UB(fi,:) = [PP.PowerRange(2) PP.GainRange(2) CFreqRange(2)];
		end
		
		params = reshape(params,1,numel(params));
		LB = reshape(LB,1,numel(LB));
		UB = reshape(UB,1,numel(UB));

		options = optimoptions('fmincon');
		options.Algorithm = 'sqp';
		options.TolX = 1e-10;
		options.MaxIter = 1000;
		options.MaxFunEvals = Inf;
		options.Display = 'iter';

		problem.objective = @ObjFunctionFreqSum;
		problem.x0 = params;
		problem.solver = 'fmincon';
		problem.options = options;
		problem.lb = LB;
		problem.ub = UB;
	end

	function res = ObjFunctionFreqProd(params) %#ok<DEFNU>
		response = CalculateBPFResponse(params, 'freq-prod', ax);
		res = sqrt(sum((response - data).^2));
	end

	function res = ObjFunctionTimeSum(params) %#ok<DEFNU>
		response = CalculateBPFResponse(params, 'time-sum', ax);
		res = sqrt(sum((response - data).^2));
	end

	function res = ObjFunctionFreqSum(params) %#ok<DEFNU>
		response = CalculateBPFResponse(params, 'freq-sum', ax);
		res = sum(sqrt((response - data).^2));
	end
end

function exportHVSR(hObject, ~)
    global HVSR PathName frame_margin frame_size frame_overlap Fs%#ok<NUSED>
    hvsr_tab = hObject.Parent; fig = hvsr_tab.Parent.Parent;
    if(PathName == 0); PathName = pwd; end %frame_margin = 0.1; frame_size = 1024;
%     frame_overlap = 0.5; Fs=250; end
    [FileName,PathName_save] = uiputfile('*.mat', 'Save HVSR Results and Model', PathName);
    if(FileName == 60) ;return; end
    save(fullfile(PathName_save, FileName), 'HVSR');
    hvsr_tab.Children(1).Visible = 'off';
    fig.Units = 'inches';
    P = fig.Position;
    fig.Position = [1 0.5 14 10];
    export_fig(strcat(PathName_save, FileName(1:end-4)), '-c[70 0 0 0]', fig);
    hvsr_tab.Children(1).Visible = 'on'; fig.Position = P;
    savefig(fig,strcat(PathName_save, FileName(1:end-4)),'compact');
    disp([FileName, ' Saved'])
end


