function HVSRgui
    global HVSR PathName
    if((PathName == 0) | (~exist('PathName', 'var'))) %#ok<OR2>
        PathName = ''; end
    [FileName, PathName, ~] = uigetfile([PathName, '\*.mat'],'Pick File','MultiSelect','on');
    if(~iscell(FileName))
        FileName = {FileName}; end
	if(FileName{1} == 0)
		return; 
	end    
    frame_margin = 0.01;
    frame_size = 8192;
    frame_overlap = 0.5;
	fftSmoothN = 256;
	HVSR = struct('Fs', -1);
	HVSR.params.frame_margin = frame_margin;
	HVSR.params.frame_size = frame_size;
	HVSR.params.frame_overlap = frame_overlap;
	HVSR.params.fftSmoothN = fftSmoothN;
	HVSR.OptParams.Source = 'H1';
	HVSR.OptParams.MinPeakProminence = 0.5;
	HVSR.OptParams.CFreqRange = -1;
	HVSR.OptParams.PowerRange = [0.1 1024];
	HVSR.OptParams.GainRange = [0.1 20];
	HVSR.UIParams.wnd_sliders = [];
    
    fig = figure(1000); clf
    pause(0.00001);
    set(fig, 'ToolBar', 'none', 'Color', 'w');
    WindowAPI(fig, 'Maximize');
        
    tab_group = uitabgroup('Parent', fig, 'Units', 'normalized', ...
        'Position', [0, 0.05, 1, 0.95]);
	for idx = 1:1:length(FileName)
		createSignalTab(FileName{idx}, tab_group);
	end
	
	createHVSRTab(tab_group);
	createModelTab(tab_group);
	createTestTab(tab_group);
	
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
            'String', HVSR.OptParams.Source);%#ok<NASGU>
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
            'String', HVSR.OptParams.MinPeakProminence);%#ok<NASGU>
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
            'String', HVSR.OptParams.CFreqRange);%#ok<NASGU>
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
            'String', num2str(HVSR.OptParams.PowerRange, '[%3.2f %3.2f]'));%#ok<NASGU>
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
            'String', num2str(HVSR.OptParams.GainRange, '[%3.2f %3.2f]'));%#ok<NASGU>		
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
	next_size = [100 30];
	start_position(1) = start_position(1) + next_size(1) + 20;
	
    Test_button = uicontrol('Style', 'pushbutton', 'String', 'Load Model', ... 
        'Parent', fig, 'Callback', @loadModel, 'Units', 'pixels',...
		'Position', [start_position next_size]); %#ok<NASGU>
	next_size = [100 30];
	start_position(1) = start_position(1) + next_size(1) + 10;
	
    Test_button = uicontrol('Style', 'pushbutton', 'String', 'Test Model', ... 
        'Parent', fig, 'Callback', @testModel, 'Units', 'pixels',...
		'Position', [start_position next_size]); %#ok<NASGU>
	
	next_size = [100 30];
	start_position(1) = start_position(1) + next_size(1) + 20;
	
    hideSTD_cb = uicontrol('Style', 'checkbox', 'String', 'Hide STD', ... 
        'Parent', fig, 'Callback', @hideSTD, 'Units', 'pixels',...
		'Position', [start_position next_size], 'Value', 0); %#ok<NASGU>
	
    figure(fig);
end

function createHVSRTab(tab_group)
    global HVSR
	num_chans = HVSR.params.num_chans;
    hvsr_tab = uitab('Parent', tab_group, 'Title', 'HVSR', 'BackgroundColor', 'w');
	for k=1:1:num_chans
	   hvsr_tab.UserData.ax(k) = subplot('Position', ...
		   [0.1 1-(k/num_chans)+0.1 0.89 1/num_chans-0.12], ...
		   'DefaultLineLineWidth', 2, 'Parent', hvsr_tab, ...
			'GridColor', [1 1 1]*0.7, 'GridAlpha', 1, ...
		    'FontSize', 20);
	   grid on;
	end
end

function createModelTab(tab_group)
	model_tab = uitab('Parent', tab_group, 'Title', 'ModelHVSR', 'BackgroundColor', 'w');
	model_tab.UserData.ax = axes('Parent', model_tab, 'DefaultLineLineWidth', 2, ...
		'Units', 'normalized', 'Position', [0.1 0.1 0.89 0.88], ...
		'XScale', 'log', 'XGrid', 'on', 'YGrid', 'on', 'NextPlot', 'add', ...
		   'FontSize', 20, 'GridColor', [1 1 1]*0.7, 'GridAlpha', 1);
end

function createTestTab(tab_group)
	test_tab = uitab('Parent', tab_group, 'Title', 'Test Model', 'BackgroundColor', 'w');
	for n=1:1:3
		test_tab.UserData.Tax(n) = axes('Parent', test_tab, ...
			'DefaultLineLineWidth', 2, 'Units', 'normalized', ...
			'NextPlot', 'add', 'XScale', 'linear', 'XGrid', 'on', ...
			'YGrid', 'on', 'GridColorMode', 'manual', ...
			'GridColor', [1 1 1]*0.7, 'GridAlpha', 1, ...
		    'FontSize', 20, 'Position', [0.06 0.99-n*0.295 0.54 0.29]);
	   test_tab.UserData.Fax(n) = axes('Parent', test_tab, ...
			'DefaultLineLineWidth', 2, 'Units', 'normalized', ...
			'NextPlot', 'add', 'XScale', 'log', 'XGrid', 'on', ...
			'YGrid', 'on', 'YScale', 'log', 'GridColorMode', 'manual', ...
			'GridColor', [1 1 1]*0.7, 'GridAlpha', 1, ...
		    'FontSize', 20, 'Position', [0.67 0.99-n*0.295 0.32 0.29]);
		 if(n~=3)
% 			 test_tab.UserData.Tax(n).XAxis.Visible = 'off';
% 			 test_tab.UserData.Fax(n).XAxis.Visible = 'off';
		 end
	end
	linkaxes(test_tab.UserData.Tax);
	linkaxes(test_tab.UserData.Fax);
end

function createSignalTab(file, tab_group)
    global HVSR PathName
    tab = uitab('Parent', tab_group, 'Title', file, 'BackgroundColor', 'w');
    matfile = strcat(PathName, file);
    load(matfile,'D');
    if(istable(D)) %#ok<NODEF>
        D = table2array(D(:,1:end));
    end
    t=D(:,1);
	if(HVSR.Fs~=-1 && HVSR.Fs~=1.0/(t(2)-t(1)))
		return
	else
		Fs = 1/(t(2)-t(1));
	end
	HVSR.Fs = Fs;
	
	sensitivity = (8E8)^1;
	if(~isempty(strfind(matfile, 'TYNO')))
		station = [43.09498,-79.87018]; %TYNO
	elseif(~isempty(strfind(matfile, 'BRCO')))
		station = [44.243720, -81.442250]; %BRCO
	elseif(~isempty(strfind(matfile, 'WLVO')))
		station = [43.923560, -78.396990]; %WLVO
	elseif(~isempty(strfind(matfile, 'ACTO')))
		station = [43.608670, -80.062360]; %ACTO
	elseif(~isempty(strfind(matfile, 'STCO')))
		station = [43.209630, -79.170530]; %STCO
	elseif(~isempty(strfind(matfile, 'PKRO')))
		station = [43.964310, -79.071430]; %PKRO
	end
	
	if(strcmp(file(1:4),'2005'))
		event = [44.677, -80.482];
	elseif(strcmp(file(1:4),'2009'))
		event = [42.864, -78.252];
	elseif(strcmp(file(1:4),'2017'))
		event = [43.436, -78.589];
	elseif(strcmp(file(1:4),'2004'))
		event = [43.672, -78.232];
	else
		event = station;
	end	
	
	baz = azimuth(station, event);
	rotM = [cosd(baz) -sind(baz) 0; sind(baz) cosd(baz) 0; 0 0 1];
	
    data = D(:,2:end);
	
	[b, a] = butter(1, 2*0.3/Fs, 'high');
	data = filtfilt(b, a, data);
    data = 1.0/sensitivity*1E3*(data - ones(length(data),1)*mean(data));%mm/s

    num_chans = size(data,2)/3;if(num_chans>4); num_chans=4;end
	HVSR.params.num_chans = num_chans;
    vector_data = sqrt(data(:,1:3:end).^2+data(:,2:3:end).^2+data(:,3:3:end).^2);
	for kk=1:1:num_chans
		tmp = data(:,(1+(kk-1)*3):1:(3*kk));
		tmp = tmp*rotM';%%%%%%%%%%%%%
		panels(kk) = uipanel('Position', [0 1-kk/num_chans 0.04 1/num_chans], ...
			'Tag', num2str(kk), 'Parent', tab);         %#ok<AGROW>
		fig_panel = uipanel('Position', ...
			[0.04 1-kk/num_chans 0.98 1/num_chans], 'Parent', tab', 'BackgroundColor', 'w');
		threshold_slider = uicontrol('Style', 'slider', ...
			'Min', 0, 'Max', 1.1, 'Value', 1.1, ...
			'Units', 'normalized', 'Position', [0 0.1 0.45 0.8], ...
			'String', 'Threshold', 'SliderStep',[0.05 0.1], ...
			'Callback', @parameter_changed, 'Parent', panels(kk)); %#ok<NASGU>
		wind_size_slider = uicontrol('Style', 'slider', ...
			'Min', 1, 'Max', Fs*15, 'Value', Fs*15, ...
			'Units', 'normalized', 'Position', [0.55 0.1 0.45 0.8], ...
			'String', 'Duration', 'SliderStep', [10 100]./Fs, ...
			'Callback', @parameter_changed, 'Parent', panels(kk));
		threshold_readout = uicontrol('Style','text', 'Parent', panels(kk), ...
			'Units', 'normalized', 'Position', [0 0.9 0.45 0.1]); %#ok<NASGU>
		wind_size_readout = uicontrol('Style','text', 'Parent', panels(kk), ...
			'Units', 'normalized', 'Position', [0.55 0.9 0.45 0.1]); %#ok<NASGU>
		use_file_check = uicontrol('Style', 'checkbox', ...
			'Value', 1, 'String', 'Use This Data', 'Parent', panels(kk), ...
			'Units', 'normalized', 'Position', [0 0 1 0.1]);

		use_file_check.UserData.Data = tmp;
		use_file_check.UserData.Vector = vector_data(:,kk);
		chax = subplot('Position', [0.06 0.1 0.9 0.85], ...
		   'FontSize', 20, 'Parent',fig_panel);
		set(fig_panel, 'UserData', panels(kk));
		set(panels(kk), 'UserData', chax);
		set(tab, 'UserData', panels);
		hold on; grid on
		parameter_changed(wind_size_slider);
		HVSR.UIParams.wnd_sliders = [HVSR.UIParams.wnd_sliders wind_size_slider];
	end
end

function keydown_editbox_CB(hObject, eventData)
global HVSR
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
			HVSR.params.frame_size = val;
			calc_frames = 1;
		case 2
			HVSR.params.frame_margin = val;
			calc_frames = 1;
		case 3
			HVSR.params.frame_overlap = val;
			calc_frames = 1;
		case 4
			HVSR.OptParams.Source = hObject.String;
		case 5
			HVSR.OptParams.MinPeakProminence = val;
		case 6
			HVSR.OptParams.CFreqRange = val;
		case 7
			HVSR.OptParams.PowerRange = val;
		case 8 
			HVSR.OptParams.GainRange = val;
		case 9
			HVSR.fftSmoothN = val;
			calc_hvsr = 1;
		otherwise
	end
	if(calc_frames && ~isempty(HVSR.UIParams.wnd_sliders))
		for s = HVSR.UIParams.wnd_sliders
			parameter_changed(s)
		end
	end
	if(calc_hvsr)
		calcHVSR();
	end
end

function parameter_changed(hObject, ~, ~)
    global HVSR 
	Fs = HVSR.Fs;
	frame_size = HVSR.params.frame_size;
	frame_margin = HVSR.params.frame_margin;
	frame_overlap = HVSR.params.frame_overlap;
	
    panel = hObject.Parent;
    ax = panel.UserData;
    ch_data = panel.Children(1).UserData.Data;
    ch_vector = panel.Children(1).UserData.Vector;
    traffic_duration = panel.Children(4).Value;
    traffic_threshold = panel.Children(5).Value;
    set(panel.Children(2), 'String', num2str(traffic_duration/Fs));
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
    cla(ax)
	ax.FontSize = 20;
    t = (0:1:length(ch_data)-1)/Fs;
    plot(ax, t, ch_data,':');hold on
    plot(ax, t, smooth_vector,'k','LineWidth',2)
    plot(ax, t, low_level*(maxval-minval)+minval,'g')
    plot(ax, t, high_level*(maxval-minval)+minval,'m')
    plot(ax, t([1, end]), [1 1]*alow,'r--');
    plot(ax, t([1, end]), [1 1]*ahigh,'b--');
    plot(ax, t([1, end]), [1 1]*threshold,'k');
    frames_Low = findFrames(low_level, frame_size, frame_overlap);
    frames_High = findFrames(high_level, frame_size, frame_overlap); 
    bound = min(min(ch_data))*[1 1];
	plot_frames(frames_Low, bound, 'g', 0)
	plot_frames(frames_High, bound, 'm', 1)
    panel.Children(1).UserData.Low = frames_Low;
    panel.Children(1).UserData.High = frames_High;
	xlabel(ax, 'Time [s]');ylabel(ax, 'Amplitude [mm/s]');
	axis(ax, 'tight');
	
	HVSR.params.HighLevel = high_level;
	
	function plot_frames(frames, bound, color, type)
		count = 0;
		for fi=frames
			h = plot(ax, [fi, fi+frame_size]/Fs,...
					bound*(1-0.9/5*(mod(count,5)+1)), ...
					'LineWidth',3,'Color',color);
			count = count+1;
			h.HitTest = 'on';
			h.ButtonDownFcn = @frame_click;
			h.UserData = [type fi];
		end
	end
	function frame_click(hObject, ~)
		pnl = hObject.Parent.Parent.UserData;
		fL = pnl.Children(1).UserData.Low;
		fH = pnl.Children(1).UserData.High;
		
		id = hObject.UserData;
		if(id(1))
			fH(fH == id(2)) = [];
			pnl.Children(1).UserData.High = fH;
		else
			fL(fL == id(2)) = [];	
			pnl.Children(1).UserData.Low = fL;
		end
		
		delete(hObject);
	end
end

function calcHVSR(hObject,~)
	global HVSR isHVSRChanged
	Fs = HVSR.Fs;
	frame_size = HVSR.params.frame_size;
	num_chans = HVSR.params.num_chans;
	tab_grp = hObject.Parent.Children(end);
	hvsr_tab = tab_grp.Children(end-2);
	tab_grp.SelectedTab = hvsr_tab;
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
    for idx = 1:1:length(tabs)-3
        tab = tabs(idx);
        chan_panels = tab.UserData;
        for k = 1:1:num_chans
            usefile = chan_panels(k).Children(1);
            userdata = usefile.UserData;
			HVSR.Data{k} = userdata.Data;
            if(usefile.Value)
% 				[HVSR_R, HVSR_X, HVSR_Y, XX, YY, VV, RR]
                [H, ~, ~, H_T, H_R, H_V, H_H] = calculateHVSR(userdata.Data, userdata.High, window, 0);
                [L, ~, ~, L_T, L_R, L_V, L_H] = calculateHVSR(userdata.Data, userdata.Low, window, 0);

                ax(k).UserData.HVSR_H = [ax(k).UserData.HVSR_H H]; 
                ax(k).UserData.HVSR_L = [ax(k).UserData.HVSR_L L];
				ax(k).UserData.HT = [ax(k).UserData.HVert H_T]; 
                ax(k).UserData.LT = [ax(k).UserData.LVert L_T]; 
				ax(k).UserData.HR = [ax(k).UserData.HVert H_R]; 
                ax(k).UserData.LR = [ax(k).UserData.LVert L_R]; 
				ax(k).UserData.HV = [ax(k).UserData.HVert H_V]; 
                ax(k).UserData.LV = [ax(k).UserData.LVert L_V]; 
				ax(k).UserData.HH = [ax(k).UserData.HVert H_H]; 
                ax(k).UserData.LH = [ax(k).UserData.LVert L_H]; 
            end
        end
    end
    tmp = [frame_size/2, num_chans];
    HmeanHVSR = zeros(tmp);
    HstdHVSR = zeros(tmp); 
    LmeanHVSR = zeros(tmp); 
    LstdHVSR = zeros(tmp);
	LmeanT = zeros(tmp);  
	HmeanT = zeros(tmp); 
	LmeanR = zeros(tmp);  
	HmeanR = zeros(tmp); 
	LmeanV = zeros(tmp);  
	HmeanV = zeros(tmp); 
	LmeanH = zeros(tmp);  
	HmeanH = zeros(tmp); 
    freq = Fs*(0:frame_size/2-1)'/frame_size;
	for k=1:1:num_chans
		axes(ax(k));cla(ax(k));hold on %#ok<LAXES>
		if(~isempty(ax(k).UserData.HVSR_H))
			HmeanHVSR(:,k) = mean(ax(k).UserData.HVSR_H, 2);
			HstdHVSR(:,k) = std(ax(k).UserData.HVSR_H, 1, 2);
			HmeanT = mean(ax(k).UserData.HT, 2);
			HmeanR = mean(ax(k).UserData.HR, 2);
			HmeanV = mean(ax(k).UserData.HV, 2);
			HmeanH = mean(ax(k).UserData.HH, 2);
		else
			HmeanHVSR(:,k) = 0;
			HstdHVSR(:,k) = 0;
			HmeanT(:,k) = 0;
			HmeanR(:,k) = 0;
			HmeanV(:,k) = 0;
			HmeanH(:,k) = 0;
		end
		if(~isempty(ax(k).UserData.HVSR_L))
			LmeanHVSR(:,k) = mean(ax(k).UserData.HVSR_L, 2);
			LstdHVSR(:,k) = std(ax(k).UserData.HVSR_L, 1, 2);
			LmeanT = mean(ax(k).UserData.LT, 2);
			LmeanR = mean(ax(k).UserData.LR, 2);
			LmeanV = mean(ax(k).UserData.LV, 2);
			LmeanH = mean(ax(k).UserData.LH, 2);
		else
			LmeanHVSR(:,k) = 0;
			LstdHVSR(:,k) = 0;
			LmeanT(:,k) = 0;
			LmeanR(:,k) = 0;
			LmeanV(:,k) = 0;
			LmeanH(:,k) = 0;
		end

		num_H = size(ax(k).UserData.HVSR_H,2);
		num_L = size(ax(k).UserData.HVSR_L,2);

		HVSR.HighSources(k).mean = HmeanHVSR(:,k);
		HVSR.HighSources(k).std = HstdHVSR(:,k);
		HVSR.HighSources(k).T = HmeanT(:,k);
		HVSR.HighSources(k).R = HmeanR(:,k);
		HVSR.HighSources(k).V = HmeanV(:,k);
		HVSR.HighSources(k).H = HmeanH(:,k);
		HVSR.LowSources(k).mean = LmeanHVSR(:,k);
		HVSR.LowSources(k).std = LstdHVSR(:,k);
		HVSR.LowSources(k).T = LmeanT(:,k);
		HVSR.LowSources(k).R = LmeanR(:,k);
		HVSR.LowSources(k).V = LmeanV(:,k);
		HVSR.LowSources(k).H = LmeanH(:,k);
		HVSR.f = freq;
		
		h_Lm = semilogx(freq, LmeanHVSR(:,k), 'r-');
		h_Ls = semilogx(freq, LmeanHVSR(:,k)*[1 1]+LstdHVSR(:,k)*[1 -1], ...
			'r--', 'LineWidth', 1);
		h_Hm = semilogx(freq, HmeanHVSR(:,k), 'b-'); 
		h_Hs = semilogx(freq, HmeanHVSR(:,k)*[1 1]+HstdHVSR(:,k)*[1 -1], ...
			'b--', 'LineWidth', 1);
		legend([h_Lm h_Ls(1) h_Hm h_Hs(1)], ...
		{['Low Source mean N=', num2str(num_L)], 'Low Source \pmstd', ...
		['High Source mean N=', num2str(num_H)], 'High Source \pmstd'}, ...
		'FontSize', 20, 'Location', 'NorthWest');
		HVSR.UIParams.hSTD{k} = [h_Ls h_Hs];
		HVSR.UIParams.hMean{k} = [h_Lm h_Hm]; 
		grid on; axis(ax(k), 'tight'); ax(k).XScale = 'log'; hold off
		xlim([min(freq) 51]);
		if(k~=num_chans)
			set(gca,'Xticklabel',[]);
		end
		ax(k).XTickLabel = ax(k).XTick;
	end
    xlabel('Frequency [Hz]');
	ylabel('H/V');
	
	isHVSRChanged = 1;
end

function modelHVSR(hObject, ~)
global HVSR isHVSRChanged
persistent fpeaks upeaks params
	tab_grp = hObject.Parent.Children(end);
	model_tab = tab_grp.Children(end-1);
	OptParams = HVSR.OptParams;
	tab_grp.SelectedTab = model_tab;
	ax = model_tab.UserData.ax;
	all_peaks=[];

	if(isHVSRChanged)
		fpeaks = [];
		upeaks = [];
		isHVSRChanged = 0;
		params = [];
	end
	data_idx = str2num(OptParams.Source(2:end)); %#ok<ST2NM>
	switch upper(OptParams.Source(1))
		case 'L'
			data = HVSR.LowSources(data_idx).mean;
		case 'H'
			data = HVSR.HighSources(data_idx).mean;
	end
	f = HVSR.f;
	
	f = logspace(-1, log10(HVSR.f(end)), length(f))';
	data = interp1(HVSR.f, data, f); 
	OptimizeAndPlot()
	
	function OptimizeAndPlot()
		cla(ax);
		ax.NextPlot = 'add';
		ax.FontSize = 20;
		p1 = semilogx(f, data , 'b-', 'LineWidth', 2, 'Parent', ax);
		grid on; axis(ax, 'tight'); ax.XScale = 'log'; 
		xlim(ax, [min(f) 50]); hold on
		ax.XTickLabel = ax.XTick;
		
		upeaks = [];
		if(isfield(HVSR, 'ExternalModel'))
			fpeaks = HVSR.ExternalModel(:,1);
			fpeaks = [fpeaks, interp1(f,data,fpeaks)];%data(arrayfun(@(x) find(f==x, 1), fpeaks))];
		elseif(isfield(HVSR, 'ModelParams'))
			fpeaks = HVSR.ModelParams(:,1);
			fpeaks = [fpeaks, data(arrayfun(@(x) find(f==x, 1), fpeaks))];
		else
			[pk, loc] = findpeaks(data, f, 'MinPeakProminence', ...
				OptParams.MinPeakProminence);
			fpeaks = [loc, pk];
		end
		problem = SetupProblem();
		if(isstruct(problem))
% 			params = lsqcurvefit(problem);
			params = lsqnonlin(problem);
			params = [all_peaks(:,1) reshape(params, numel(params)/2, 2)];
			[result, Wbpf]= CalculateBPFResponse(params,'freq-sum',0,f);
			error = abs(result-data)./data;

			p4 = semilogx(f, result, 'k','LineWidth', 2, 'Parent', ax);
			p5 = semilogx(f, Wbpf, 'k--','LineWidth', 1, 'Parent', ax);
			p6 = semilogx(f, error,'r--','LineWidth', 2, 'Parent', ax);
			grid on; axis(ax, 'tight'); ax.XScale = 'log'; hold off
			xlim(ax, [min(f) 50]);

			legend(ax, [p1(1) p4(1) p5(1) p6(1)], ...
				{'HVSR', 'Model Response', 'Bandpass Filters', ...
				['Error RMS:' num2str(round(rms(error),3))]}, ...
				'FontSize', 20, 'Location', 'northwest');
			HVSR.ModelParams = params;
			xlabel(ax,'Frequency [Hz]', 'FontSize', 20);
			ylabel(ax,'H/V', 'FontSize', 20);
			ax.XTickLabel = ax.XTick;
		end
	end
	
	function problem = SetupProblem()
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
				button = 3;
			elseif(button == 27)
				problem = 0;
				return;
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
		params = zeros(Num_Filters, 2);
		LB = zeros(Num_Filters, 2);
		UB = zeros(Num_Filters, 2);

		for fi = 1:1:length(all_peaks)
			params(fi,2) = 2;
			params(fi,1) = all_peaks(fi,2);
			LB(fi,:) = [OptParams.GainRange(1) OptParams.PowerRange(1)];
			UB(fi,:) = [OptParams.GainRange(2) OptParams.PowerRange(2)];
		end
		
		if(isfield(HVSR, 'ExternalModel'))
			params = HVSR.ExternalModel(:,2:end);
		end
		
		params = reshape(params,1,numel(params));
		LB = reshape(LB,1,numel(LB));
		UB = reshape(UB,1,numel(UB));

% 		options = optimoptions('fmincon');
% 		options.Algorithm = 'sqp';
% % 		options.TolX = 1e-10;
% 		options.MaxIter = 1000;
% 		options.MaxFunEvals = Inf;
% 		options.Display = 'iter';
% 
% 		problem.objective = @ObjFunctionFreqSum;
% 		problem.x0 = params;
% 		problem.solver = 'fmincon';
% 		problem.options = options;
% 		problem.lb = LB;
% 		problem.ub = UB;
		options = optimoptions('lsqnonlin');
		options.MaxIter = 1000;
		options.MaxFunEvals = Inf;
		options.Display = 'iter';

		problem.objective = @ObjFunctionFreqSum;
		problem.x0 = params;
		problem.solver = 'lsqnonlin';
		problem.options = options;
		problem.lb = LB;
		problem.ub = UB;
% 		problem.ydata = data;
% 		problem.xdata = f;
	end

	function res = ObjFunctionFreqSum(params,xdata)
		params = reshape(params, numel(params)/2, 2);
		response = CalculateBPFResponse([all_peaks(:,1) params], 'freq-sum', ax, f);
		res = response-data;
	end
end

function testModel(hObject,~)
global HVSR
	tab_grp = hObject.Parent.Children(end);
	test_tab = tab_grp.Children(end);
	tab_grp.SelectedTab = test_tab;
	HT = HVSR.HighSources.T;
	HR = HVSR.HighSources.R;
	HV = HVSR.HighSources.V;
	HH = HVSR.HighSources.H;
	LT = HVSR.LowSources.T;
	LR = HVSR.LowSources.R;
	LV = HVSR.LowSources.V;
	LH = HVSR.LowSources.H;
	
	pDataHV = [HV HH LV LH];
	pDataTRV = [HT HR HV LT LR LV];
	if(isfield(HVSR, 'ExternalModel'))
		params = HVSR.ExternalModel;
	else
		params = HVSR.ModelParams;
	end
	
	[bpf, ~] = CalculateBPFResponse(params, 'freq-sum', 0);
	k = repmat([bpf 1./bpf], 1, 2);
	calcHV = pDataHV.*k;
	k = repmat([1./bpf 1./bpf bpf], 1, 2);
	calcTRV = pDataTRV.*k;
	
	fff = figure(182754); clf(fff); fff.Color = 'w';
	ax = axes('Parent', fff, 'DefaultLineLineWidth', 2, ...
		'XScale', 'log', 'YScale', 'log', 'XGrid', 'on', 'YGrid', 'on', 'NextPlot', 'add', ...
		   'FontSize', 20, 'GridColor', [1 1 1]*0.7, 'GridAlpha', 1);
	
	h = loglog(HVSR.f, pDataHV, 'Parent', ax);
	set(h, {'Color'}, {[0 0 1]; [0 1 0]; [1 0 0]; [0 0 0]});
	h=loglog(HVSR.f, calcHV, '--', 'Parent', ax);
	set(h, {'Color'}, {[0 1 0]; [0 0 1]; [0 0 0]; [1 0 0]});
% 	legend(ax, 'Strong Source Vertical', ...
% 		'Strong Source Horizontal', 'Noise Source Vertical', ...
% 		'Noise Source Horizontal', ...
% 		'HV*HVSR', 'HR/HVSR', 'LV*HVSR', 'LR/HVSR')
	xlim(ax, [0.1 50]);
	xlabel(ax, 'Frequency[Hz]')
	ylabel(ax, 'Velolcity [mm/s]$/\sqrt{Hz}$', ...
		'Interpreter','latex');

	ax.XTickLabel = ax.XTick;
% 	test_tab.UserData.FFF = fff;
	
	data = HVSR.Data{1};
	f = HVSR.Fs*(0:(length(data)-1)/2)'/length(data);
	freq = [f; f(end-mod(length(data),2):-1:1)];
	[bpf, ~] = CalculateBPFResponse(params, 'freq-sum', 0, freq);
	fftdata = fft(data, length(data), 1);
	
	ampl = abs(fftdata);
	theta = angle(fftdata);
	
	ampl = ampl.*[repmat(1./bpf, 1, 2) bpf];
	theta = [theta(:,1) theta(:,2) theta(:,3)];
	fftdata_mod = ampl.*exp(1j*theta);	 
% 	fftdata_mod = [repmat(1./bpf, 1, 2) bpf].*fftdata;
	data_mod = ifft(fftdata_mod, 'symmetric');

	d1 = {'Transverse', 'Radial', 'Vertical'};
	d1e = cellfun(@(x) [x ' EQ'], d1, 'UniformOutput', 0);
	d2 = {'Transverse/HVSR', 'Radial/HVSR', 'Vertical*HVSR'};
	d2e = {'Transverse EQ/HVSR', 'Radial EQ/HVSR', 'Vertical EQ*HVSR'};
	t = (1:1:length(data))./HVSR.Fs;
	
	for n=1:1:3
		tax = test_tab.UserData.Tax(n); cla(tax);
		fax = test_tab.UserData.Fax(n); cla(fax);
		tax.YTickLabelMode = 'auto';
		fax.YTickLabelMode = 'auto';
% 		plot(tax, t, HVSR.params.HighLevel*max(max(data))*1.1,'m','DisplayName','')
		a = plot(t, data(:,n), 'k', 'Parent', tax);
		loglog(HVSR.f, pDataTRV(:,n) , 'k', 'Parent', fax);
		if(n~=3)
			b = plot(t, data_mod(:,n), 'r', 'Parent', tax);
			loglog(HVSR.f, calcTRV(:,n), 'r', 'Parent', fax);
			legend(tax, [a b], {d1{n}, d2{n}});
			legend(fax, d1e{n}, d2e{n},'Location','northwest');
			tax.XTickLabel = [];
			fax.XTickLabel = [];
		else
			legend(tax, a, d1{n});
			legend(fax, d1e{n},'Location','northwest');
			rng = [max(10e-5,min(min(pDataTRV))) max(max(pDataTRV))];
			axis(fax, [0.1 HVSR.Fs/2 10.^ceil(log10(rng))]);
			fax.XTickLabel = fax.XTick;
		end
		axis(tax, [t(1) t(end) max(max(abs([data data_mod(:,1:2)])))*[-1.1 1.1]]);
		
		fax.YMinorTick = 'on';
		fax.YTick = 10.^(-6:1:1);
		
		if(n==2)
			ylabel(tax, 'Velocity [mm/s]', 'Interpreter','tex')
			ylabel(fax, 'Velolcity [mm/s]/\surd{Hz}', ...
		'Interpreter','tex');
		end
	end
	xlabel(tax, 'Time [s]');
	xlabel(fax, 'Frequency [Hz]');
	
	HVSR.ModifiedData = data_mod;
end

function loadModel(~,~)
global PathName HVSR
	[FileName, PathName, ~] = uigetfile([PathName, '\*.mat'],'Pick File');
    if(~iscell(FileName))
        FileName = {FileName}; end
	if(FileName{1} == 0)
		return; 
	end
	m = matfile([PathName FileName{1}]);
	try
		tmp = m.HVSR;
		HVSR.ExternalModel = tmp.ModelParams;
	catch
		tmp = m.HVSR;
		HVSR.ExternalModel = tmp.ExternalModel;
	end
end

function hideSTD(hObject, ~)
global HVSR
	tab_grp = hObject.Parent.Children(end);
	hvsr_tab = tab_grp.Children(end-2);
	h_std = HVSR.UIParams.hSTD;
	h_mean = HVSR.UIParams.hMean;
	if(hObject.Value == 0)
		state = 'on';
	else
		state = 'off';
	end
	for k=1:1:HVSR.params.num_chans
		for n=1:1:numel(h_std{k})
			h_std{k}(n).Visible = state;
		end
		ax = hvsr_tab.UserData.ax(k);
		num_H = size(ax.UserData.HVSR_H,2);
		num_L = size(ax.UserData.HVSR_L,2);
		if(strcmp(state, 'on'))
			legend(ax, [h_mean{k}(1) h_std{k}(1) h_mean{k}(2) h_std{k}(3)], ...
		{['Low Source mean N=', num2str(num_L)], 'Low Source \pmstd', ...
		['High Source mean N=', num2str(num_H)], 'High Source \pmstd'}, ...
		'FontSize', 20, 'Location', 'NorthWest');
		else
			legend(ax, [h_mean{k}(1) h_mean{k}(2)], ...
		{['Low Source mean N=', num2str(num_L)], ...
		['High Source mean N=', num2str(num_H)]}, ...
		'FontSize', 20, 'Location', 'NorthWest');
		end
	end
end

function exportHVSR(hObject, ~)
    global HVSR PathName tmpLegend
	fig = hObject.Parent;
	tab_group = hObject.Parent.Children(end);
	test_tab = tab_group.Children(end);
	model_tab = tab_group.Children(end-1);
	hvsr_tab = tab_group.Children(end-2);
	chan_tabs = tab_group.Children(1:end-3);
    if(PathName == 0); PathName = pwd; end 
    [FileName,PN_save] = uiputfile('*.mat', ...
		'Save HVSR Results and Model', PathName);
    if(FileName == 0) ;return; end
	
	hvsr_tab.Children(1).String = {'Noise H/V', 'Earthquake H/V'};
	
    save(fullfile(PN_save, FileName), 'HVSR');
	
	tmpFN = strcat(PN_save, FileName(1:end-4));
	
	for k=1:1:length(chan_tabs)
		tab_group.SelectedTab = chan_tabs(k);
		export_fig(strcat(tmpFN, '_frames', num2str(k)), ...
			'-c[30 0 50 100]', fig);
	end
	tab_group.SelectedTab = test_tab;
	export_fig(strcat(tmpFN, '_test'), '-c[25 10 50 20]', fig);
	
	tab_group.SelectedTab = hvsr_tab;
	
    fig.Units = 'inches';
    fig.Position = [1 1 9 9.25];
    export_fig(strcat(tmpFN, '_HVSR'), '-c[25 5 48 0]', fig);
	tab_group.SelectedTab = model_tab;
	export_fig(strcat(tmpFN, '_model'), '-c[25 5 48 0]', fig);
	
	WindowAPI(fig, 'Maximize');
	savefig(fig,tmpFN,'compact');
% 	if(ishandle(test_tab.UserData.FFF))
% 		test_tab.UserData.FFF.Units = 'inches';
% 		test_tab.UserData.FFF.Position = [1 1 9 9.25];
% 		export_fig(strcat(tmpFN, '_spec'), ...
% 			'-c[0 0 0 0]', test_tab.UserData.FFF);
% 		WindowAPI(test_tab.UserData.FFF, 'Maximize');
% 		savefig(test_tab.UserData.FFF, ...
% 			strcat(tmpFN,'_spec'),'compact');
% 	end
	
	if(isfield(HVSR, 'ModelParams'))
		params = HVSR.ModelParams;
	else
		params = HVSR.ExternalModel;
	end
	Q = sqrt(1./(2.^(2./params(:,3))-1));
	D = 1./(2*Q);
	id = (1:1:length(params))';
	tbl = array2table(round([params Q D], 3), ...
		'VariableNames', {'Fc', 'Gain', 'n', 'Q', 'D'}, ...
		'RowNames', arrayfun(@(x) ['BPF #' num2str(x)], id, 'UniformOutput', 0));
	writetable(tbl, strcat(tmpFN,'_model'), 'FileType', 'text', 'WriteRowNames', 1);

	disp([FileName, ' Saved'])
end

function exportHVSR2(hObject, ~)
    global PathName tmpLegend
	fig = hObject.Parent;
	tab_group = fig.Children(end);
	test_tab = tab_group.Children(end);
	hvsr_tab = tab_group.Children(end-2);
	hvsr_tab.Children(1).String = tmpLegend;
	
    if(PathName == 0); PathName = pwd; end 
    [FileName,PN_save] = uiputfile('*.mat', ...
		'Save HVSR Results and Model', PathName);
    if(FileName == 0) ;return; end
	
	tmpFN = strcat(PN_save, FileName(1:end-4));
	
	tab_group.SelectedTab = test_tab;
	export_fig(strcat(tmpFN, '_test'), '-c[25 10 50 20]', fig);
	
	tab_group.SelectedTab = hvsr_tab;
	
    fig.Units = 'inches';
    fig.Position = [1 1 9 9.25];
    export_fig(strcat(tmpFN, '_HVSR'), '-c[25 5 48 0]', fig);
end

function exportHVSR3(hObject, ~)
    global PathName 
	fig = hObject.Parent;
	tab_group = fig.Children(end);
	test_tab = tab_group.Children(end);
    if(PathName == 0); PathName = pwd; end 
    [FileName,PN_save] = uiputfile('*.mat', ...
		'Save HVSR Results and Model', PathName);
    if(FileName == 0) ;return; end
	tmpFN = strcat(PN_save, FileName(1:end-4));
	tab_group.SelectedTab = test_tab;
	export_fig(strcat(tmpFN, '_test'), '-c[25 10 50 20]', fig);
end