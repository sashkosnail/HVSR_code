function [frames_Low, frames_High] = differentiate_traffic(signal, filename) 
    global Fs Ts traffic_threshold frame_size traffic_duration;
    vector_data = signal(:,1:3:end).^2+signal(:,2:3:end).^2+signal(:,3:3:end).^2;
    t = (0:1:length(vector_data)-1)./Fs;
    th_data=[];
    mid = 0;
    figure; clf
    %create UI controls
    threshold_slider = uicontrol('UserData','thrsh', 'Style', 'slider', ...
        'Min', 0, 'Max', 1, 'Value', traffic_threshold, ...
        'Position', [20 20 300 20], 'String', 'Threshold', ...
        'Callback', @parameter_changed);
    threshold_readout = uicontrol('Style','text','String', ...
        ['Threshold:', num2str(traffic_threshold)], 'Position', [320 20 100 20]);
    wind_size_slider = uicontrol('UserData','width', 'Style', 'slider', ...
        'Min', 1, 'Max', 25, 'SliderStep', [1 1]/24, 'Value', traffic_duration, ...
        'Position', [20 40 300 20], 'String', 'Duration', ...
        'Callback', @parameter_changed);
    wind_size_readout = uicontrol('Style','text','String', ...
        ['Duration:', num2str(traffic_duration)], 'Position', [320 40 100 20]);
    
    subaxis(2,1,1)
    plot(t,vector_data)
    title(filename);
    axis tight; hold on
    parameter_changed(wind_size_slider);
    wait = ~waitforbuttonpress;
    while(wait)
        wait = ~waitforbuttonpress;
    end
    delete(wind_size_slider)
    delete(threshold_slider)
    return
    
    function parameter_changed(hObject, eventdata, handles)
        slider_value = get(hObject,'Value');
        slider_purpose = get(hObject, 'UserData');
        if(strcmp(slider_purpose,'width'))
            traffic_duration = slider_value;
            win_size = ceil(traffic_duration/Ts/2)*2;
            window = bartlett(win_size+1);
            th_data = apply_window(window, vector_data);
            set(threshold_slider,'Max',max(reshape(th_data,numel(th_data),1)));
            set(threshold_slider,'Min',min(reshape(th_data,numel(th_data),1)));
            set(wind_size_readout, 'String', ['Duration:', num2str(traffic_duration)]);
            mid = (max(reshape(th_data,numel(th_data),1))+min(reshape(th_data,numel(th_data),1)))/2;
        else
            traffic_threshold = slider_value;
            set(threshold_readout, 'String', ['Threshold:', num2str(traffic_threshold)]);
        end
        
        comb = rms(th_data, 2);
        subaxis(2,1,2); hold off
        plot(t, comb,'k');hold on
        plot(t, th_data, '--');
        axis([0 t(end) 0 1]); axis autoy

        low_level = comb<traffic_threshold*0.9;
        high_level = comb>traffic_threshold*1.1;
        
        plot(t,low_level*mid,'g-')
        plot(t,high_level*mid,'m-')
        plot(t([1 end]), [1 1]*0.9*traffic_threshold,'r');
        plot(t([1 end]), [1 1]*1.1*traffic_threshold,'b');

        overlap=0.5;
        frames_Low = findFrames(low_level, frame_size, overlap);
        frames_High = findFrames(high_level, frame_size, overlap);
        count = 0;
        for id=frames_Low
            plot([id, id+frame_size]/Fs,...
                    mid/2*[1 1]+0.1*(mod(count,3)+1),'LineWidth',3,'Color','g');
            count = count+1;
        end
        for id=frames_High
            plot([id, id+frame_size]/Fs,...
                    mid/2*[1 1]+0.1*(mod(count,3)+1),'LineWidth',3,'Color','m');
            count = count+1;
        end
    end    
end