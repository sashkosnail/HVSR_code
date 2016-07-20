%HVSR MAT
global Fs Ts traffic_threshold frame_size traffic_duration;
clear data out_files datfile Ts Fs FileName
close all
if(~exist('PathName','var'))
    PathName = '';
end
[FileName, PathName, ~] = uigetfile([PathName, '*.mat'],'Pick File','MultiSelect','on');
if(~iscell(FileName)&FileName == 0)
    return;
end
data = [];
Ts=-1;
if(iscell(FileName))
     for ii=1:1:length(FileName)
        matfile = strcat(PathName, FileName{ii});
        load(matfile)
        t = D(:,1);
        if(Ts~=-1& Ts~=(t(2)-t(1)))
            return
        elseif(Ts == -1)
            Ts = t(2)-t(1);
            Fs = 1/Ts;
        end
        data = [data D(:,2:end)]; %#ok<AGROW>
    end
else
        matfile = strcat(PathName, FileName);
        load(matfile)
        t = D(:,1);
        Ts = t(2)-t(1);
        Fs = 1/Ts;
        data =D(:,2:end);
end
frame_size = 1024;
window_size = frame_size;
traffic_duration = 13;
traffic_threshold = 0.6;
Nch = min(size(data));
Nsens = Nch/3;
SperF = 2;

filter_cutoff = 30;
[fnum, fden] = butter(4, filter_cutoff*2/Fs, 'low');
% data = filtfilt(fnum, fden, data);

window = hann(window_size+1);
window = repmat(window(1:end-1), 1, Nch);
ws = 1;
minmax = [max(max(data)) min(min(data))];
%%
OL={};OH={};
if(Nsens<=2)
    [OL, OH] = differentiate_traffic(data, FileName);
else
    for ch_pair = 1:1:Nsens/2;
        pair_data = data(:,((ch_pair-1)*6+1:ch_pair*6));
        [OL{ch_pair}, OH{ch_pair}] = differentiate_traffic(pair_data, FileName{ch_pair}); %#ok<SAGROW>
    end
end

%%
HVSR_H =[];
HVSR_L =[];
if(Nsens==1)
    HVSR_H = calculateHVSR(data, OH, window);
    HVSR_L = calculateHVSR(data, OL, window);
else
    for ch_pair = 1:1:Nsens/2;
        pair_data = data(:,((ch_pair-1)*6+1:ch_pair*6));
        HVSR_H = [HVSR_H calculateHVSR(data, OL{ch_pair}, window)]; %#ok<AGROW>
        HVSR_L = [HVSR_L calculateHVSR(data, OH{ch_pair}, window)]; %#ok<AGROW>
    end
end

%%
HmeanHVSR = zeros(window_size/2, SperF);
HstdHVSR = zeros(window_size/2, SperF);
LmeanHVSR = zeros(window_size/2, SperF);
LstdHVSR = zeros(window_size/2, SperF);
freq = Fs*(1:window_size/2)'/window_size;
figure();colors = 'rg';
for f=1:1:SperF
    subsetH = HVSR_H(:,:,f:SperF:end);
    subsetL = HVSR_L(:,:,f:SperF:end);
    HmeanHVSR(:,f) = mean(reshape(subsetH, window_size/2,2*numel(subsetH)/window_size), 2);
    HstdHVSR(:,f) = std(reshape(subsetH, window_size/2,2*numel(subsetH)/window_size), 1, 2);
    LmeanHVSR(:,f) = mean(reshape(subsetL, window_size/2,2*numel(subsetL)/window_size), 2);
    LstdHVSR(:,f) = std(reshape(subsetL, window_size/2,2*numel(subsetL)/window_size), 1, 2);

    subaxis(2,1,1)
    semilogx(freq, LmeanHVSR(:,f), [colors(f) '-']); hold on
    semilogx(freq, LmeanHVSR(:,f)*[1 1]+LstdHVSR(:,f)*[1 -1], [colors(f) '--'])
%     axis([0.1 30 0 1]); axis autoy; 
    grid on; title('Low')
    axis tight
    subaxis(2,1,2)
    semilogx(freq, HmeanHVSR(:,f), [colors(f) '-']); hold on
    semilogx(freq, HmeanHVSR(:,f)*[1 1]+HstdHVSR(:,f)*[1 -1], [colors(f) '--'])
%     axis([0.1 30 0 1]); axis autoy; 
    grid on; title('High')
    axis tight
end

return
% figure(1);clf
% subaxis(3,2,1,1,2,1, 'PT', 0, 'MT', 0);
% plot(t,data);hold on;

% running = true;
% while(running)
%     windata = data(ws:ws+window_size-1,:).*window;
%     fftdata = abs(fft(windata, window_size, 1)/window_size);
%     fftdata = filtfilt(spec_window,1,fftdata(1:window_size/2,:));
%     fftdata(2:end-1,:) = 2*fftdata(2:end-1,:);
%     f = Fs/2*(1:window_size/2)'/window_size;
%      
%     
%     HVSRdata = [sqrt(abs(fftdata(:,2)).^2 + abs(fftdata(:,3)).^2) ./ abs(fftdata(:,1)), ...
%     sqrt(abs(fftdata(:,5)).^2 + abs(fftdata(:,6)).^2) ./ abs(fftdata(:,4))];
% 
%     if(exist('h_bars','var'))
%         delete(h_bars)
%     end
%     subaxis(3,2,1,1,2,1, 'PT', 0, 'MT', 0);
%     h_bars = plot(Ts.*[ws ws], minmax, 'k', ...
%         Ts.*repmat(ws+window_size,1,2), minmax, 'k');
%     subaxis(3,2,1,2,2,1, 'PT', 0, 'MT', 0);
%     plot(t(ws:ws+window_size-1), windata);
%     axis tight
%     subaxis(3,2,1,3,1,1, 'PT', 0, 'MT', 0);
%     semilogx(f, fftdata);
%     axis([0 2*filter_cutoff 0 1]);
%     axis autoy
%     subaxis(3,2,2,3,1,1, 'PT', 0, 'MT', 0);
%     semilogx(f, HVSRdata);
%     axis([0 2*filter_cutoff 0 1]);
%     axis autoy
%     [x, y, button] = ginput(1);
%     if(button == 1 || button == 3)
%         if(button == 1)
%             ws = floor(x)*Fs;
%         else
%             window_size = 2^nextpow2(floor(x)*Fs - ws - 1);
%             window_size = floor(x)*Fs-ws;
%         end
%         if(ws+window_size>length(data))
%             window_size = length(data)-ws;
%         end
%         window = repmat(hann(window_size), 1, Nchan);
%     end
%     if(button == 2)
%         running = false;        
%     end
% end