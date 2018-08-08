function HVSRgui
    global Ts frame_size PathName frame_margin frame_overlap wnd_sliders
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
    frame_size = 1024;
    frame_overlap = 0.5;
    Ts=-1;
    
    fig = figure(); clf
    pause(0.00001);
    set(fig, 'ToolBar', 'none');
    set(fig, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    
        
    tab_group = uitabgroup('Parent', fig, 'Units', 'normalized', ...
        'Position', [0 0, 1, 0.95], 'SelectionChangedFcn', @tab_changed);
    for idx = 1:1:length(FileName)
        createNewTab(FileName{idx}, tab_group);
    end
    createHVSRTab(tab_group);
    
    frame_size_text = uicontrol('Style','text', 'Parent', fig, ...
            'Units', 'normalized', 'Position', [0.5 0.96 0.05 0.04], ...
            'String', 'Frame Size:'); %#ok<NASGU>
    frame_size_edit = uicontrol('Style','edit', 'Parent', fig, ...
            'Units', 'normalized', 'Position', [0.15 0.96 0.1 0.04], ...
            'KeyReleaseFcn', @keydown_editbox, 'UserData', 1, ...
            'String', num2str(frame_size));
        
    frame_margin_text = uicontrol('Style','text', 'Parent', fig, ...
            'Units', 'normalized', 'Position', [0.25 0.96 0.05 0.04], ...
            'String', 'Frame Margin:'); %#ok<NASGU>
    frame_margin_edit = uicontrol('Style','edit', 'Parent', fig, ...
            'Units', 'normalized', 'Position', [0.3 0.96 0.1 0.04], ...
            'KeyReleaseFcn', @keydown_editbox, 'UserData', 2, ...
            'String', num2str(frame_margin));
        
    frame_overlap_text = uicontrol('Style','text', 'Parent', fig, ...
            'Units', 'normalized', 'Position', [0.4 0.96 0.05 0.04], ...
            'String', 'Frame Overlap:'); %#ok<NASGU>
    frame_overlap_edit = uicontrol('Style','edit', 'Parent', fig, ...
            'Units', 'normalized', 'Position', [0.45 0.96 0.1 0.04], ...
            'KeyReleaseFcn', @keydown_editbox, 'UserData', 3, ...
            'String', num2str(frame_overlap));
        
    apply_button = uicontrol('Style', 'pushbutton', 'Parent', fig, ...
            'Units', 'normalized', 'Position', [0.6 0.96 0.1 0.04], ...
            'Callback', @apply_button_cb, 'String', 'Apply', ...
            'UserData', {frame_size_edit, frame_margin_edit, frame_overlap_edit}); %#ok<NASGU>
    figure(fig);
end

function apply_button_cb(hObject, ~)
global frame_size frame_margin frame_overlap wnd_sliders hvsr_tab
    frame_size = str2double(hObject.UserData{1}.String);
    frame_margin = str2double(hObject.UserData{2}.String);
    frame_overlap = str2double(hObject.UserData{3}.String);
    
    window = hann(frame_size+1);
    hvsr_tab.UserData.window = repmat(window(1:end-1), 1, 3);
    for s = wnd_sliders
        parameter_changed(s)
    end
end

function keydown_editbox(hObject, eventData)
global frame_size frame_margin frame_overlap wnd_sliders hvsr_tab
    if(~strcmp(eventData.Key, 'return'))
        return;
    end
    val = str2double(hObject.String);
    switch hObject.UserData
        case 1
            frame_size = val;
        case 2
            frame_margin = val;
        case 3
            frame_overlap = val;
    end
    window = hann(frame_size+1);
    hvsr_tab.UserData.window = repmat(window(1:end-1), 1, 3);
    if(~isempty(wnd_sliders))
        for s = wnd_sliders
            parameter_changed(s)
        end
    end
end

function createHVSRTab(tab_group)
    global frame_size num_chans hvsr_tab
    hvsr_tab = uitab('Parent', tab_group, 'Title', 'HVSR');
    window = hann(frame_size+1);
    hvsr_tab.UserData.window = repmat(window(1:end-1), 1, 3);
    for k=1:1:num_chans
       hvsr_tab.UserData.ax(k) = subplot('Position', ...
           [0.025 1-k/num_chans+0.05 1 1/num_chans], 'Parent', hvsr_tab);
    end
    export_button = uicontrol('Style', 'pushbutton', 'String', 'Export', ... 
        'Parent', hvsr_tab, 'Callback', @exportHVSR); %#ok<NASGU>
end

function createNewTab(file, tab_group)
    global Ts Fs PathName num_chans wnd_sliders
    tab = uitab('Parent', tab_group, 'Title', file);
    matfile = strcat(PathName, file);
    load(matfile,'D');
    if(istable(D)) %#ok<NODEF>
        D = table2array(D(:,1:end-2));
    end
    t=D(:,1);
    if(Ts~=-1 && Ts~=(t(2)-t(1)))
        return
    elseif(Ts == -1)
        Ts = t(2)-t(1); Fs = 1/Ts;
    end
    data = D(:,2:end);
    data = data - ones(length(data),1)*mean(data);
    num_chans = size(data,2)/3;
    vector_data = sqrt(data(:,1:3:end).^2+data(:,2:3:end).^2+data(:,3:3:end).^2);
    for kk=1:1:num_chans
        panels(kk) = uipanel('Position', [0 1-kk/num_chans 0.04 1/num_chans], ...
            'Tag', num2str(kk), 'Parent', tab);         %#ok<AGROW>
        fig_panel = uipanel('Position', ...
            [0.04 1-kk/num_chans 1 1/num_chans], 'Parent', tab');
        threshold_slider = uicontrol('Style', 'slider', ...
            'Min', 0, 'Max', 1.1, 'Value', 0.22, ...
            'Units', 'normalized', 'Position', [0 0.1 0.45 0.8], ...
            'String', 'Threshold', 'SliderStep',[0.05 0.1], ...
            'Callback', @parameter_changed, 'Parent', panels(kk)); %#ok<NASGU>
        wind_size_slider = uicontrol('Style', 'slider', ...
            'Min', 1, 'Max', Fs*15, 'Value', Fs*11, ...
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
        chax = subplot('Position', [0 0.08 0.925 1], 'Parent',fig_panel);
        set(panels(kk), 'UserData', chax);
        set(tab, 'UserData', panels);
        axis tight; hold on
        chax.YAxisLocation = 'right';
        parameter_changed(wind_size_slider);
        wnd_sliders = [wnd_sliders wind_size_slider]; %#ok<AGROW>
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
    thisFigure.YAxisLocation = 'right';
end

function tab_changed(hObject, eventdata)
    global Fs frame_size HVSR num_chans
    if(~strcmp(eventdata.NewValue.Title, 'HVSR'))
        return; end
    HVSR = struct;
    hvsr_tab = eventdata.NewValue;
    window = hvsr_tab.UserData.window;
    ax = hvsr_tab.UserData.ax;
    for k=1:1:num_chans
        ax(k).UserData.HVSR_H =[];
        ax(k).UserData.HVSR_L =[];
    end
    tabs = hObject.Children;
    for idx = 1:1:length(tabs)-1
        tab = tabs(idx);
        chan_panels = tab.UserData;
        for k = 1:1:num_chans
            usefile = chan_panels(k).Children(1);
            userdata = usefile.UserData;
            if(usefile.Value)
                H = calculateHVSR(userdata.Data, userdata.High, window);
                L = calculateHVSR(userdata.Data, userdata.Low, window);
                ax(k).UserData.HVSR_H = [ax(k).UserData.HVSR_H H]; 
                ax(k).UserData.HVSR_L = [ax(k).UserData.HVSR_L L]; 
            end
        end
    end
    tmp = [frame_size/2, num_chans];
    HmeanHVSR = zeros(tmp);
    HstdHVSR = zeros(tmp); 
    LmeanHVSR = zeros(tmp); 
    LstdHVSR = zeros(tmp); 
    freq = Fs*(1:frame_size/2)'/frame_size;
    for k=1:1:num_chans
        axes(ax(k));cla(ax(k));hold on %#ok<LAXES>
        if(~isempty(ax(k).UserData.HVSR_H))
            HmeanHVSR(:,k) = mean(ax(k).UserData.HVSR_H, 2);
            HstdHVSR(:,k) = std(ax(k).UserData.HVSR_H, 1, 2);
        else
            HmeanHVSR(:,k) = 0;
            HstdHVSR(:,k) = 0;
        end
        if(~isempty(ax(k).UserData.HVSR_L))
            LmeanHVSR(:,k) = mean(ax(k).UserData.HVSR_L, 2);
            LstdHVSR(:,k) = std(ax(k).UserData.HVSR_L, 1, 2);
        else
            LmeanHVSR(:,k) = 0;
            LstdHVSR(:,k) = 0;
        end
        
        num_H = size(ax(k).UserData.HVSR_H,2);
        num_L = size(ax(k).UserData.HVSR_L,2);
        
        HVSR.HighSources(k).mean = HmeanHVSR(:,k);
        HVSR.HighSources(k).std = HstdHVSR(:,k);
        HVSR.LowSource(k).mean = LmeanHVSR(:,k);
        HVSR.LowSource(k).std = LstdHVSR(:,k);

        h_Lm = semilogx(freq, LmeanHVSR(:,k), 'r-', 'LineWidth', 1.5);
        h_Ls = semilogx(freq, LmeanHVSR(:,k)*[1 1]+LstdHVSR(:,k)*[1 -1], 'r--');
        h_Hm = semilogx(freq, HmeanHVSR(:,k), 'b-', 'LineWidth', 1.5); 
        h_Hs = semilogx(freq, HmeanHVSR(:,k)*[1 1]+HstdHVSR(:,k)*[1 -1], 'b--');
        legend([h_Lm h_Ls(1) h_Hm h_Hs(1)], ...
        {['Low Source mean N=', num2str(num_L)], 'Low Source \pmstd', ...
        ['High Source mean N=', num2str(num_H)], 'High Source \pmstd'}, ...
        'FontSize', 12, 'Location', 'west');
    
        grid on; axis tight; ax(k).XScale = 'log'; hold off
%         title(ax(k), ['Channel ' num2str(k)], 'Units', 'normalized', ...
%             'Rotation', 90, 'Position', [-0.02 0.5 0]);
    end
    xlabel('Frequency [Hz]');
end

function exportHVSR(hObject, ~)
    global HVSR PathName frame_margin frame_size frame_overlap Fs%#ok<NUSED>
    hvsr_tab = hObject.Parent; fig = hvsr_tab.Parent.Parent;
    if(PathName == 0); PathName = pwd; end %frame_margin = 0.1; frame_size = 1024;
%     frame_overlap = 0.5; Fs=250; end
    [FileName,PathName_save] = uiputfile('*.mat', 'Save HVSR Results', PathName);
    if(FileName == 60) ;return; end
    save(fullfile(PathName_save, FileName), 'HVSR');
    hvsr_tab.Children(1).Visible = 'off';
    fig.Units = 'inches';
    P = fig.Position;
    fig.Position = [1 0.5 14 10];
    export_fig(strcat(PathName_save, FileName(1:end-4)), '-c[26 0 0 0]', fig);
    hvsr_tab.Children(1).Visible = 'on'; fig.Position = P;
    savefig(fig,strcat(PathName_save, FileName(1:end-4)),'compact');
    disp([FileName, ' Saved'])
end
