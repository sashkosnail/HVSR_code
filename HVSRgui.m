function HVSRgui
    global Fs Ts frame_size PathName
    frame_size = 1024;
    fig = figure(1);
    set(fig, 'ToolBar', 'none');
    tab_group = uitabgroup('Parent', fig, 'SelectionChangedFcn', @tab_changed);
    
    if(~exist('PathName', 'var') | PathName == 0)
        PathName = '';
    end
    [FileName, PathName, ~] = uigetfile([PathName, '*.mat'],'Pick File','MultiSelect','on');
    if(~iscell(FileName))
        FileName = {FileName};
    end
    if(FileName{1} == 0)
        return;
    end
    Ts=-1;
    
    for idx = 1:1:length(FileName)
        createNewTab(FileName{idx}, tab_group);
    end
    
    createHVSRTab(tab_group);
end
function createHVSRTab(tab_group)
    global frame_size
    window = hann(frame_size+1);
    window = repmat(window(1:end-1), 1, 6);
    hvsr_tab = uitab('Parent',tab_group,'Title', 'HVSR', ...
        'UserData', window); %#ok<NASGU>
end
function tab_changed(hObject, eventdata)
    global Fs frame_size
    if(~strcmp(eventdata.NewValue.Title, 'HVSR'))
        return
    end
    hvsr_tab = eventdata.NewValue;
    window = get(hvsr_tab, 'UserData');
    
    HVSR_H =[];
    HVSR_L =[];
    tabs = hObject.Children;
    for idx = 1:1:length(tabs)-1
        tab = tabs(idx);
        if(~strcmp(eventdata.NewValue.Title, 'HVSR'))
            break;
        end
        DataStruct = tab.UserData;
        if(~DataStruct.UseFile)
            continue;
        end
        DataStruct.HVSR_H = calculateHVSR(DataStruct.Data, DataStruct.frames_High, window);
        DataStruct.HVSR_L = calculateHVSR(DataStruct.Data, DataStruct.frames_Low, window);
        HVSR_H = [HVSR_H DataStruct.HVSR_H]; %#ok<AGROW>
        HVSR_L = [HVSR_L DataStruct.HVSR_L]; %#ok<AGROW>
    end
    
    HmeanHVSR = zeros(frame_size/2, 2);
    HstdHVSR = zeros(frame_size/2, 2);
    LmeanHVSR = zeros(frame_size/2, 2);
    LstdHVSR = zeros(frame_size/2, 2);
    
    freq = Fs*(1:frame_size/2)'/frame_size;
    colors = 'rg';
    subplot(2,1,2, 'Parent', hvsr_tab); cla
    subplot(2,1,1, 'Parent', hvsr_tab); cla
    for f=1:1:2
        subsetH = HVSR_H(:,:,f:2:end);
        subsetL = HVSR_L(:,:,f:2:end);
        HmeanHVSR(:,f) = mean(reshape(subsetH, frame_size/2,2*numel(subsetH)/frame_size), 2);
        HstdHVSR(:,f) = std(reshape(subsetH, frame_size/2,2*numel(subsetH)/frame_size), 1, 2);
        LmeanHVSR(:,f) = mean(reshape(subsetL, frame_size/2,2*numel(subsetL)/frame_size), 2);
        LstdHVSR(:,f) = std(reshape(subsetL, frame_size/2,2*numel(subsetL)/frame_size), 1, 2);

        subplot(2,1,1, 'Parent', hvsr_tab)
        semilogx(freq, LmeanHVSR(:,f), [colors(f) '-']); hold on
        semilogx(freq, LmeanHVSR(:,f)*[1 1]+LstdHVSR(:,f)*[1 -1], [colors(f) '--'])
    %     axis([0.1 30 0 1]); axis autoy; 
        grid on; title('Low')
        axis tight
        subplot(2,1,2, 'Parent', hvsr_tab)
        semilogx(freq, HmeanHVSR(:,f), [colors(f) '-']); hold on
        semilogx(freq, HmeanHVSR(:,f)*[1 1]+HstdHVSR(:,f)*[1 -1], [colors(f) '--'])
    %     axis([0.1 30 0 1]); axis autoy; 
        grid on; title('High')
        axis tight
    end
end

function createNewTab(file, tab_group)
    global Ts Fs frame_size PathName traffic_duration traffic_threshold
    tab = uitab('Parent', tab_group, 'Title', file);
    matfile = strcat(PathName, file);
    load(matfile);
    t=D(:,1); %#ok<NODEF>
    if(Ts~=-1& Ts~=(t(2)-t(1)))
        return
    elseif(Ts == -1)
        Ts = t(2)-t(1);
        Fs = 1/Ts;
    end
    data = D(:,2:end);
    vector_data = sqrt(data(:,[1 4]).^2+data(:,[2 5]).^2+data(:,[3 6]).^2);
    DataStruct.t = t;
    DataStruct.Data = data;
    DataStruct.Vector = vector_data;
    DataStruct.traffic_duration = traffic_duration;
    DataStruct.traffic_threshold= traffic_threshold;
    
    threshold_slider = uicontrol('Style', 'slider', ...
        'Min', 0, 'Max', 1, 'Value', DataStruct.traffic_threshold, ...
        'Position', [20 20 300 20], 'String', 'Threshold', ...
        'SliderStep',[0.05 0.1], ...
        'Callback', @parameter_changed, 'Parent', tab);
    threshold_readout = uicontrol('Style','text','String', ...
        ['Threshold:', num2str(DataStruct.traffic_threshold)], ...
        'Position', [320 20 100 20], 'Parent', tab);
    wind_size_slider = uicontrol('Style', 'slider', ...
        'Min', 1, 'Max', 25, 'SliderStep', [1 1]/24, ...
        'Value', DataStruct.traffic_duration, ...
        'Position', [20 40 300 20], 'String', 'Duration', ...
        'Callback', @parameter_changed, 'Parent', tab);
    wind_size_readout = uicontrol('Style','text','String', ...
        ['Duration:', num2str(DataStruct.traffic_duration)], ...
        'Position', [320 40 100 20], 'Parent', tab);
    use_file_check = uicontrol('Style', 'checkbox', ...
        'Value', 1, 'String', 'Use This File', 'Parent', tab, ...
        'Position', [20 60 60 20], 'Callback', @checked_changed);
    DataStruct.UseFile = use_file_check.Value;
    
    subplot(2,1,1, 'Parent', tab)
    plot(t,vector_data)
    axis tight; hold on
    parameter_changed(wind_size_slider);
    
    function checked_changed(hObject, eventdata, handles)
        parent = get(hObject, 'Parent');
        userdata = get(parent, 'UserData');
        userdata.UseFile = get(hObject, 'Value');
        set(parent, 'UserData', userdata);
    end
    
    function parameter_changed(hObject, eventdata, handles)
        slider_value = get(hObject,'Value');
        slider_purpose = get(hObject, 'String');
        if(strcmp(slider_purpose,'Duration'))
            DataStruct.traffic_duration = slider_value;
            win_size = ceil(DataStruct.traffic_duration/Ts/2)*2;
            window = bartlett(win_size+1);
            DataStruct.th_data = apply_window(window, DataStruct.Vector);
        else
            DataStruct.traffic_threshold = slider_value;
        end
        maxval = max(reshape(DataStruct.th_data,numel(DataStruct.th_data),1));
        minval = min(reshape(DataStruct.th_data,numel(DataStruct.th_data),1));
        if(threshold_slider.Value>maxval)
            threshold_slider.Value = maxval;
            DataStruct.traffic_threshold = maxval;
        elseif(threshold_slider.Value<minval)
            threshold_slider.Value = minval;
            DataStruct.traffic_threshold = minval;
        end
        set(wind_size_readout, 'String', ...
            ['Duration:', num2str(DataStruct.traffic_duration)]);
        set(threshold_readout, 'String', ...
            ['Threshold:', num2str(DataStruct.traffic_threshold)]);
        set(threshold_slider,'Max', maxval);
        set(threshold_slider,'Min', minval);            
        mid = (maxval + minval)/2;
        
        comb = rms(DataStruct.th_data, 2);
        subplot(2,1,2, 'Parent', tab); hold off
        plot(t, comb,'k');hold on
        plot(t, DataStruct.th_data, '--');
        axis([0 t(end) 0 1]); axis autoy

        low_level = comb<DataStruct.traffic_threshold*0.9;
        high_level = comb>DataStruct.traffic_threshold*1.1;
        
        plot(t,low_level*mid,'g-')
        plot(t,high_level*mid,'m-')
        plot(t([1 end]), [1 1]*0.9*DataStruct.traffic_threshold,'r');
        plot(t([1 end]), [1 1]*1.1*DataStruct.traffic_threshold,'b');

        overlap=0.5;
        DataStruct.frames_Low = findFrames(low_level, frame_size, overlap);
        DataStruct.frames_High = findFrames(high_level, frame_size, overlap);
        count = 0;
        for id=DataStruct.frames_Low
            plot([id, id+frame_size]/Fs,...
                    mid/2*[1 1]+0.1*(mod(count,3)+1),'LineWidth',3,'Color','g');
            count = count+1;
        end
        for id=DataStruct.frames_High
            plot([id, id+frame_size]/Fs,...
                    mid/2*[1 1]+0.1*(mod(count,3)+1),'LineWidth',3,'Color','m');
            count = count+1;
        end
        set(tab, 'UserData', DataStruct);
    end
end