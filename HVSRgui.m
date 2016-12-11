function HVSRgui
    global Ts frame_size PathName frame_diff overlap
    frame_diff = 0.1;
    frame_size = 1024;
    overlap = 0.5;
    Ts=-1;
    
    fig = figure(3);
    set(fig, 'ToolBar', 'none');
    tab_group = uitabgroup('Parent', fig, 'SelectionChangedFcn', @tab_changed);
    
    if(~exist('PathName', 'var') | PathName == 0)
        PathName = ''; end
    [FileName, PathName, ~] = uigetfile([PathName, '*.mat'],'Pick File','MultiSelect','on');
    if(~iscell(FileName))
        FileName = {FileName}; end
    if(FileName{1} == 0)
        return; end
    for idx = 1:1:length(FileName)
        createNewTab(FileName{idx}, tab_group);
    end
    createHVSRTab(tab_group);
    figure(fig);
end
function createHVSRTab(tab_group)
    global frame_size num_chans
    hvsr_tab = uitab('Parent', tab_group, 'Title', 'HVSR');
    for k=1:1:num_chans
        userdata.ax(k) = subplot(num_chans, 1, k, 'Parent', hvsr_tab,'XScale','log'); cla
    end
    window = hann(frame_size+1);
    userdata.window = repmat(window(1:end-1), 1, 3);
    set(hvsr_tab, 'UserData', userdata);
    export_button = uicontrol('Style', 'pushbutton', 'String', 'Export', ... 
        'Parent', hvsr_tab, 'Callback', @exportHVSR); %#ok<NASGU>
end
function exportHVSR(hObject, ~)
    global HVSR PathName %#ok<NUSED>
    [FileName,PathName_save] = uiputfile('*.mat', 'Save HVSR Results', PathName);
    if(FileName == 0) ;return; end
    save(fullfile(PathName_save, FileName), 'HVSR');
    fig = hObject.Parent.Parent.Parent;
    print(fig, strcat(PathName_save, FileName(1:end-4), '.png'), '-dpng', '-r0');
    savefig(fig,strcat(PathName_save, FileName(1:end-4)),'compact');
end
function tab_changed(hObject, eventdata)
    global Fs frame_size HVSR num_chans
    if(~strcmp(eventdata.NewValue.Title, 'HVSR'))
        return; end
    HVSR = struct;
    hvsr_tab = eventdata.NewValue;
    window = hvsr_tab.UserData.window;
    ax = hvsr_tab.UserData.ax; cla; hold on
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
        axes(ax(k));cla;hold on
        if(isempty(ax(k).UserData.HVSR_H)&&isempty(ax(k).UserData.HVSR_L))
            continue; end
        HmeanHVSR(:,k) = mean(ax(k).UserData.HVSR_H, 2);
        HstdHVSR(:,k) = std(ax(k).UserData.HVSR_H, 1, 2);
        LmeanHVSR(:,k) = mean(ax(k).UserData.HVSR_L, 2);
        LstdHVSR(:,k) = std(ax(k).UserData.HVSR_L, 1, 2);
        
        HVSR.HighSources(k).mean = HmeanHVSR(:,k);
        HVSR.HighSources(k).std = HstdHVSR(:,k);
        HVSR.LowSource(k).mean = LmeanHVSR(:,k);
        HVSR.LowSource(k).std = LstdHVSR(:,k);

        semilogx(freq, LmeanHVSR(:,k), 'r-', 'LineWidth', 1.5);
        semilogx(freq, LmeanHVSR(:,k)*[1 1]+LstdHVSR(:,k)*[1 -1], 'r--')
        semilogx(freq, HmeanHVSR(:,k), 'b-', 'LineWidth', 1.5); 
        semilogx(freq, HmeanHVSR(:,k)*[1 1]+HstdHVSR(:,k)*[1 -1], 'b--')
        grid on; axis tight; hold off
    end
end

function createNewTab(file, tab_group)
    global Ts Fs frame_size PathName num_chans frame_diff overlap
    tab = uitab('Parent', tab_group, 'Title', file);
    matfile = strcat(PathName, file);
    load(matfile);
    t=D(:,1); %#ok<NODEF>
    if(Ts~=-1 && Ts~=(t(2)-t(1)))
        return
    elseif(Ts == -1)
        Ts = t(2)-t(1); Fs = 1/Ts;
    end
    data = D(:,2:end);
    num_chans = size(data,2)/3;
    vector_data = sqrt(data(:,1:3:end).^2+data(:,2:3:end).^2+data(:,3:3:end).^2);
    for kk=1:1:num_chans
        panels(kk) = uipanel('Position', [0 1-kk/num_chans 0.1 1/num_chans], ...
            'Tag', num2str(kk), 'Parent', tab);         %#ok<AGROW>
        threshold_slider = uicontrol('Style', 'slider', ...
            'Min', 0, 'Max', 1, 'Value', 0.5, ...
            'Units', 'normalized', 'Position', [0 0.1 0.45 0.8], ...
            'String', 'Threshold', 'SliderStep',[0.05 0.1], ...
            'Callback', @parameter_changed, 'Parent', panels(kk)); %#ok<NASGU>
        wind_size_slider = uicontrol('Style', 'slider', ...
            'Min', 1, 'Max', Fs*15, 'Value', Fs*7, ...
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
        chax = subplot(num_chans, 1, kk,  'Parent', tab);
        set(panels(kk), 'UserData', chax);
        set(tab, 'UserData', panels);
        plot(t,data(:,(1+(kk-1)*3):1:(3*kk)))
        axis tight; hold on
        parameter_changed(wind_size_slider);
    end
    function parameter_changed(hObject, ~, ~)
        panel = hObject.Parent;
        thisfigure = panel.UserData;
        ch_data = panel.Children(1).UserData.Data;
        ch_vector = panel.Children(1).UserData.Vector;
        traffic_duration = panel.Children(4).Value;
        traffic_threshold = panel.Children(5).Value;
        set(panel.Children(2), 'String', num2str(traffic_duration*Ts));
        set(panel.Children(3), 'String', num2str(traffic_threshold)); 
        slider_purpose = get(hObject, 'String');
        if(strcmp(slider_purpose,'Duration'))
            win_size = min(ceil(traffic_duration/2)*2, length(ch_vector)-1);
            window = bartlett(win_size+1);
            panel.Children(5).UserData = apply_window(window, ch_vector);
        end
        smooth_vector = panel.Children(5).UserData;
        maxval = max(smooth_vector);
        minval = min(smooth_vector);
        spread = maxval-minval;
        threshold = traffic_threshold * spread + minval;
        margin = spread*frame_diff;
        alow = threshold - margin;
        low_level = smooth_vector<alow;
        ahigh = threshold + margin;
        high_level = smooth_vector>ahigh;
        subplot(thisfigure); hold off
        plot(t,ch_data,':');hold on
        plot(t, smooth_vector,'k','LineWidth',2)
        plot(t,low_level*(maxval-minval)+minval,'g')
        plot(t,high_level*(maxval-minval)+minval,'m')
        plot(t([1 end]), [1 1]*alow,'r--');
        plot(t([1 end]), [1 1]*ahigh,'b--');
        plot(t([1 end]), [1 1]*threshold,'k');
        axis([0 t(end) 0 max(max(ch_data))])
        frames_Low = findFrames(low_level, frame_size, overlap);
        frames_High = findFrames(high_level, frame_size, overlap);
        count = 0;
        for id=frames_Low
            plot(   [id, id+frame_size]/Fs,...
                    maxval*0.75*[1 1]+spread/5*(mod(count,3)+1), ...
                    'LineWidth',3,'Color','g');
            count = count+1;
        end
        count = 0;
        for id=frames_High
            plot(   [id, id+frame_size]/Fs,...
                    maxval*[1 1]+spread/3*(mod(count,3)+1), ...
                    'LineWidth',3,'Color','m');
            count = count+1;
        end
        panel.Children(1).UserData.Low = frames_Low;
        panel.Children(1).UserData.High = frames_High;
    end
end