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
    frame_size = 2048;
    frame_overlap = 0.5;
	fftSmoothN = 256;
	HVSR = struct('Fs', -1);
	HVSR.params.frame_margin = frame_margin;
	HVSR.params.frame_size = frame_size;
	HVSR.params.frame_overlap = frame_overlap;
	HVSR.params.fftSmoothN = fftSmoothN;
	HVSR.OptParams.Source = 'L1';
	HVSR.OptParams.MinPeakProminence = 0.5;
	HVSR.OptParams.CFreqRange = -1;
	HVSR.OptParams.PowerRange = [1 256];
	HVSR.OptParams.GainRange = [0.1 20];
	HVSR.UIParams.wnd_sliders = [];
    
    fig = figure(1000); clf
    pause(0.00001);
    set(fig, 'ToolBar', 'none');
%     set(fig, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    WindowAPI(fig, 'Maximize');
        
    tab_group = uitabgroup('Parent', fig, 'Units', 'normalized', ...
        'Position', [0, 0.05, 1, 0.95]);
	HVSR.UIParams.tab_group = tab_group;
    for idx = 1:1:length(FileName)
        createSignalTab(FileName{idx});
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
	
    figure(fig);
end

function createModelTab(tab_group)
global HVSR
	model_tab = uitab('Parent', tab_group, 'Title', 'ModelHVSR');
	model_tab.UserData.ax = axes('Parent', model_tab, 'DefaultLineLineWidth', 2, ...
		'Units', 'normalized', 'Position', [0.06 0.075 0.935 0.92], ...
		'XScale', 'log', 'XGrid', 'on', 'YGrid', 'on', 'NextPlot', 'add', ...
		   'FontSize', 16, 'GridColor', [1 1 1]*0.7, 'GridAlpha', 1);
	HVSR.UIParams.model_tab = model_tab;
end

function createHVSRTab(tab_group)
    global HVSR
	num_chans = HVSR.params.num_chans;
    hvsr_tab = uitab('Parent', tab_group, 'Title', 'HVSR');
	for k=1:1:num_chans
	   hvsr_tab.UserData.ax(k) = subplot('Position', ...
		   [0.06 1-(k/num_chans)+0.075 0.935 1/num_chans-0.1], ...
		   'DefaultLineLineWidth', 2, 'Parent', hvsr_tab, ...
			'GridColor', [1 1 1]*0.7, 'GridAlpha', 1, ...
		    'FontSize', 16);
	   grid on;
	end
	HVSR.UIParams.hvsr_tab = hvsr_tab;
end

function createTestTab(tab_group)
	global HVSR
	test_tab = uitab('Parent', tab_group, 'Title', 'Test Model');
	for n=1:1:3
		test_tab.UserData.Tax(n) = axes('Parent', test_tab, ...
			'DefaultLineLineWidth', 2, 'Units', 'normalized', ...
			'NextPlot', 'add', 'XScale', 'linear', 'XGrid', 'on', ...
			'YGrid', 'on', 'GridColorMode', 'manual', ...
			'GridColor', [1 1 1]*0.7, 'GridAlpha', 1, ...
		   'FontSize', 16, 'Position', [0.06 0.99-n*0.295 0.935 0.29]);
		 if(n~=3)
			 test_tab.UserData.Tax(n).XAxis.Visible = 'off';
		 end
	end
	linkaxes(test_tab.UserData.Tax);
	fff = figure(182754); clf(fff)
	test_tab.UserData.Fax = axes('Parent', fff, 'DefaultLineLineWidth', 2, ...
		'XScale', 'log', 'YScale', 'log', 'XGrid', 'on', 'YGrid', 'on', 'NextPlot', 'add', ...
		   'FontSize', 16, 'GridColor', [1 1 1]*0.7, 'GridAlpha', 1);
	   %'Units', 'normalized', 'Position', [0.025 0.02 0.97 0.20], ...
	HVSR.UIParams.test_tab = test_tab;
end

function createSignalTab(file)
    global HVSR PathName
	tab_group = HVSR.UIParams.tab_group;
    tab = uitab('Parent', tab_group, 'Title', file);
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
	
	sensitivity = 8E-8;
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
	
    data = sensitivity*1E3*(data - ones(length(data),1)*mean(data));%mm/s

    num_chans = size(data,2)/3;if(num_chans>4); num_chans=4;end
	HVSR.params.num_chans = num_chans;
    vector_data = sqrt(data(:,1:3:end).^2+data(:,2:3:end).^2+data(:,3:3:end).^2);
    for kk=1:1:num_chans
		tmp = data(:,(1+(kk-1)*3):1:(3*kk));
		tmp = tmp*rotM';%%%%%%%%%%%%%
        panels(kk) = uipanel('Position', [0 1-kk/num_chans 0.04 1/num_chans], ...
            'Tag', num2str(kk), 'Parent', tab);         %#ok<AGROW>
        fig_panel = uipanel('Position', ...
            [0.04 1-kk/num_chans 0.95 1/num_chans], 'Parent', tab');
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
        chax = subplot('Position', [0.06 0.05 0.935 0.94], ...
		   'FontSize', 16, 'Parent',fig_panel);
		set(fig_panel, 'UserData', panels(kk));
        set(panels(kk), 'UserData', chax);
        set(tab, 'UserData', panels);
        hold on; grid on
%         chax.YAxisLocation = 'right';
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
    thisFigure = panel.UserData;
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
    subplot(thisFigure); hold off
    t = (0:1:length(ch_data)-1)/Fs;
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
    bound = min(min(ch_data))*[1 1];
	plot_frames(frames_Low, bound, 'g', 0)
	plot_frames(frames_High, bound, 'm', 1)
    panel.Children(1).UserData.Low = frames_Low;
    panel.Children(1).UserData.High = frames_High;
%     thisFigure.YAxisLocation = 'right';
	xlabel('Time [s]');ylabel('Amplitude [mm/s]');
	axis tight;
	
	function plot_frames(frames, bound, color, type)
		count = 0;
		for fi=frames
			h = plot([fi, fi+frame_size]/Fs,...
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

function calcHVSR(~,~)
	global HVSR isHVSRChanged
	Fs = HVSR.Fs;
	frame_size = HVSR.params.frame_size;
	num_chans = HVSR.params.num_chans;
	hvsr_tab = HVSR.UIParams.hvsr_tab;
	
	tab_grp = HVSR.UIParams.tab_group;
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
                [H, ~, ~, H_V, H_R] = calculateHVSR(userdata.Data, userdata.High, window, 0);
                [L, ~, ~, L_V, L_R] = calculateHVSR(userdata.Data, userdata.Low, window, 0);
% 				T = calculateHVSR(userdata.Data, 1, build_taper((1:1:length(userdata.Data))/Fs, 5),0);
                ax(k).UserData.HVSR_H = [ax(k).UserData.HVSR_H H]; 
                ax(k).UserData.HVSR_L = [ax(k).UserData.HVSR_L L];
				ax(k).UserData.HV = [ax(k).UserData.HVert H_V]; 
                ax(k).UserData.LV = [ax(k).UserData.LVert L_V]; 
				ax(k).UserData.HR = [ax(k).UserData.HVert H_R]; 
                ax(k).UserData.LR = [ax(k).UserData.LVert L_R]; 
% 				ax(k).UserData.T = T;
            end
        end
    end
    tmp = [frame_size/2, num_chans];
    HmeanHVSR = zeros(tmp);
    HstdHVSR = zeros(tmp); 
    LmeanHVSR = zeros(tmp); 
    LstdHVSR = zeros(tmp);
	LmeanV = zeros(tmp);  
	HmeanV = zeros(tmp); 
	LmeanR = zeros(tmp);  
	HmeanR = zeros(tmp); 
    freq = Fs*(0:frame_size/2-1)'/frame_size;
    for k=1:1:num_chans
        axes(ax(k));cla(ax(k));hold on %#ok<LAXES>
        if(~isempty(ax(k).UserData.HVSR_H))
            HmeanHVSR(:,k) = mean(ax(k).UserData.HVSR_H, 2);
            HstdHVSR(:,k) = std(ax(k).UserData.HVSR_H, 1, 2);
			HmeanV = mean(ax(k).UserData.HV, 2);
			HmeanR = mean(ax(k).UserData.HR, 2);
        else
            HmeanHVSR(:,k) = 0;
            HstdHVSR(:,k) = 0;
			HmeanV(:,k) = 0;
			HmeanR(:,k) = 0;
        end
		if(~isempty(ax(k).UserData.HVSR_L))
			LmeanHVSR(:,k) = mean(ax(k).UserData.HVSR_L, 2);
			LstdHVSR(:,k) = std(ax(k).UserData.HVSR_L, 1, 2);
			LmeanV = mean(ax(k).UserData.LV, 2);
			LmeanR = mean(ax(k).UserData.LR, 2);
		else
			LmeanHVSR(:,k) = 0;
			LstdHVSR(:,k) = 0;
			LmeanV(:,k) = 0;
			LmeanR(:,k) = 0;
		end
		  
        num_H = size(ax(k).UserData.HVSR_H,2);
        num_L = size(ax(k).UserData.HVSR_L,2);
        
        HVSR.HighSources(k).mean = HmeanHVSR(:,k);
        HVSR.HighSources(k).std = HstdHVSR(:,k);
		HVSR.HighSources(k).V = HmeanV(:,k);
		HVSR.HighSources(k).R = HmeanR(:,k);
        HVSR.LowSources(k).mean = LmeanHVSR(:,k);
        HVSR.LowSources(k).std = LstdHVSR(:,k);
		HVSR.LowSources(k).V = LmeanV(:,k);
		HVSR.LowSources(k).R = LmeanR(:,k);
		HVSR.f = freq;
		
% 		tot = ax(k).UserData.T;
% 		h_tot = semilogx(Fs*(0:tot/2-1)'/length(tot), tot, 'k--', 'LineWidth', 1.5);
        h_Lm = semilogx(freq, LmeanHVSR(:,k), 'r-');
        h_Ls = semilogx(freq, LmeanHVSR(:,k)*[1 1]+LstdHVSR(:,k)*[1 -1], ...
			'r--', 'LineWidth', 1);
        h_Hm = semilogx(freq, HmeanHVSR(:,k), 'b-'); 
        h_Hs = semilogx(freq, HmeanHVSR(:,k)*[1 1]+HstdHVSR(:,k)*[1 -1], ...
			'b--', 'LineWidth', 1);
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
		ax(k).XTickLabel = ax(k).XTick;
	end
    xlabel('Frequency [Hz]');
	ylabel('H/V');
	
	isHVSRChanged = 1;
end

function modelHVSR(~, ~)
global HVSR isHVSRChanged
persistent fpeaks upeaks params

	model_tab = HVSR.UIParams.model_tab;
	OptParams = HVSR.OptParams;

	tab_grp = HVSR.UIParams.tab_group;
	tab_grp.SelectedTab = model_tab;
	ax = model_tab.UserData.ax;
	all_peaks=[];

	if(isempty(isHVSRChanged))
		return
	end
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
		
		p1 = semilogx(f, data , 'b-', 'Parent', ax);
		grid on; axis tight; ax.XScale = 'log'; 
		xlim(ax, [min(f) 50]); hold on
		ax.XTickLabel = ax.XTick;
		
		if(isfield(HVSR, 'ExternalModel'))
			fpeaks = HVSR.ExternalModel(:,1);
			fpeaks = [fpeaks, data(arrayfun(@(x) find(f==x, 1), fpeaks))];
		else
			[pk, loc] = findpeaks(data, f, 'MinPeakProminence', ...
				OptParams.MinPeakProminence);
			fpeaks = [loc, pk];
		end
		problem = SetupProblem();
		if(isstruct(problem))
			params = fmincon(problem);
	% 		result = CalculateBPFResponse(params, 'freq-prod', 0);
	% 		p3 = semilogx(f, result, 'r--', 'Parent', ax);
			params = [all_peaks(:,1) reshape(params, numel(params)/2, 2)];
			[result, Wbpf]= CalculateBPFResponse(params,'freq-sum',0,f);
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
			HVSR.ModelParams = params;
			xlabel('Frequency [Hz]');
			ylabel('Ratio Amplitude');
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
		
		params = reshape(params,1,numel(params));
		LB = reshape(LB,1,numel(LB));
		UB = reshape(UB,1,numel(UB));
		
% 		params = [reshape(params(:,1:2)',1, numel(params(:,1:2))) params(:,3)'];
% 		LB = [reshape(LB(:,1:2)',1, numel(LB(:,1:2))) LB(:,3)'];
% 		UB = [reshape(UB(:,1:2)',1, numel(UB(:,1:2))) UB(:,3)'];

		options = optimoptions('fmincon');
		options.Algorithm = 'sqp';
% 		options.TolX = 1e-10;
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

	function res = ObjFunctionFreqSum(params)
% 		K = 2*length(params)/3;
% 		ff = params((K+1):end);
% 		fo = params(1:K);
% 		params = [reshape(fo',2,numel(fo)/2)' ff'];	
		params = reshape(params, numel(params)/2, 2);
		response = CalculateBPFResponse([all_peaks(:,1) params], 'freq-sum', ax, f);
		res = sum(sqrt((response - data).^2));
	end
end

function testModel(~,~)
global HVSR
	test_tab = HVSR.UIParams.test_tab;
	tab_grp = HVSR.UIParams.tab_group;
	tab_grp.SelectedTab = test_tab;
	HV = HVSR.HighSources.V;
	HR = HVSR.HighSources.R;
	LV = HVSR.LowSources.V;
	LR = HVSR.LowSources.R;
	HLVR = [HV HR LV LR];
	if(isfield(HVSR, 'ExternalModel'))
		params = HVSR.ExternalModel;
	else
		params = HVSR.ModelParams;
	end
	
	[bpf, ~] = CalculateBPFResponse(params, 'freq-sum', 0);
	k = repmat([bpf 1./bpf], 1, 2);
	calcVR = HLVR.*k;
	if(ishandle(test_tab.UserData.Fax))
		cla(test_tab.UserData.Fax);
		h = loglog(HVSR.f, HLVR, 'Parent', test_tab.UserData.Fax);
		set(h, {'Color'}, {[0 0 1]; [0 1 0]; [1 0 0]; [0 0 0]});
		h=loglog(HVSR.f, calcVR, '--', 'Parent', test_tab.UserData.Fax);
		set(h, {'Color'}, {[0 1 0]; [0 0 1]; [0 0 0]; [1 0 0]});
		legend(test_tab.UserData.Fax, 'HV', 'HR', 'LV', 'LR', ...
			'HV*HVSR', 'HR/HVSR', 'LV*HVSR', 'LR/HVSR')
		xlim(test_tab.UserData.Fax, [0.1 50]);
		xlabel(test_tab.UserData.Fax, 'Frequency[Hz]')
		ylabel(test_tab.UserData.Fax, 'Velolcity [mm/s]$/\sqrt{Hz}$', ...
			'Interpreter','latex');
		
		test_tab.UserData.Fax.XTickLabel = test_tab.UserData.Fax.XTick;
	end
	
	data = HVSR.Data{1};
	
	freq = HVSR.Fs*(0:(length(data)-1)/2)'/length(data);
	freq = [freq; freq(end-mod(length(data),2):-1:1)];

	[bpf, ~] = CalculateBPFResponse(params, 'freq-sum', 0, freq);
	fftdata = fft(data, length(data), 1);
	
	ampl = abs(fftdata);
	theta = angle(fftdata);
	
	ampl = ampl.*[repmat(1./bpf, 1, 2) bpf];
	theta = [theta(:,1) theta(:,2) theta(:,3)];
	fftdata_mod = ampl.*exp(1j*theta);
% 	fftdata_mod = fftdata.*[repmat(1./bpf, 1, 2) bpf];
	 
	data_mod = ifft(fftdata_mod, 'symmetric');
% 	data = [data sqrt(data(:,1).^2+data(:,2).^2)];
% 	data_mod = [data_mod sqrt(data_mod(:,1).^2+data_mod(:,2).^2)];
	
	d1 = {'T', 'R', 'V'};
	d2 = {'T/HVSR', 'R/HVSR', 'V*HVSR'};
	
	for n=1:1:3
		ax = test_tab.UserData.Tax(n);
		cla(ax);
		ax.YTickLabelMode = 'auto';
		t = (1:1:length(data))./HVSR.Fs;
		h = plot(t, data(:,n), 'k', 'Parent', ax);
% 		set(h, {'Color'}, {[0 0 1]; [0 1 0]; [1 0 0]});
		if(n~=3)
			h = plot(t, data_mod(:,n), 'r', 'Parent', ax);
% 		set(h, {'Color'}, {[0 0 1]; [0 1 0]; [1 0 0]});
			legend(ax, d1{n}, d2{n});
		else
			legend(ax, d1{n});
		end
% 		xlim(ax, [245 252]);
		axis(ax, [t(1) t(end) max(max(abs([data data_mod(:,1:2)])))*[-1.1 1.1]]);
% 		ax.YTick = ax.YTick(1:end-1);
% 		ax.YTickLabel = ax.YTick;
		if(n==2)
			ylabel(ax, 'Velocity [mm/s]')
		end
	end
	
	xlabel(ax, 'Time [s]')
	
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

function exportHVSR(hObject, ~)
    global HVSR PathName 
	fig = hObject.Parent;
	test_tab = HVSR.UIParams.test_tab;
    if(PathName == 0); PathName = pwd; end 
    [FileName,PN_save] = uiputfile('*.mat', ...
		'Save HVSR Results and Model', PathName);
    if(FileName == 60) ;return; end
    save(fullfile(PN_save, FileName), 'HVSR');
    fig.Units = 'inches';
    fig.Position = [1 0.5 14 10];
    export_fig(strcat(PN_save, FileName(1:end-4)), '-c[0 0 0 0]', fig);
	WindowAPI(fig, 'Maximize');
	WindowAPI(test_tab.UserData.Fax.Parent, 'Maximize');
	savefig(fig,strcat(PN_save, FileName(1:end-4)),'compact');
    savefig(test_tab.UserData.Fax.Parent,strcat(PN_save, FileName(1:end-4),'_spec'),'compact');
    disp([FileName, ' Saved'])
end
function exportHVSR2(hObject, ~)
    global HVSR PathName 
	fig = hObject.Parent;
    if(PathName == 0); PathName = pwd; end 
    [FileName,PN_save] = uiputfile('*.mat', ...
		'Save HVSR Results and Model', PathName);
    if(FileName == 60) ;return; end
    fig.Units = 'inches';
    fig.Position = [1 0.5 14 10];
    export_fig(strcat(PN_save, FileName(1:end-4)), '-c[0 0 0 0]', fig);
	WindowAPI(fig, 'Maximize');
	disp([FileName, ' Saved'])
end


