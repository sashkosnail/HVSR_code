%HVSR MAT

clear data out_files datfile Ts Fs
% close all
if(~exist('PathName','var'))
    PathName = '';
end
[FileName, PathName, ~] = uigetfile([PathName, '*.mat'],'Pick File');
if(FileName == 0)
    return;
end
matfile = strcat(PathName, FileName);

load(matfile)
t = D(:,1);
Ts = t(2)-t(1);
Fs = 1/Ts;
data = D(:,2:end);
Nch = min(size(data));

spec_window_width = 15;
spec_window = bartlett(spec_window_width);

filter_cutoff = 5;
[fnum, fden] = butter(12, filter_cutoff*2/Fs, 'low');
data = filtfilt(fnum, fden, data);

window_size = 1024;
window = hann(window_size+1);
window = repmat(window(1:end-1), 1, Nch);
ws = 1;
minmax = [max(max(data)) min(min(data))];

th_win_duration = 10;
th_win_size = ceil(th_win_duration/Ts/2)*2;
th_win = bartlett(th_win_size+1);th_win = th_win(1:end-1)/th_win_size;

data = [data(th_win_size:-1:1,:); data; data(end:-1:end-th_win_size+1,:)];
% t=linspace(0,length(data)*Ts,length(data));

th_data2 = filtfilt(th_win, 1, abs(data));
th_data2 = th_data2(th_win_size:end-th_win_size-1,:);

th_data = filter(th_win, 1, abs(data)); 
th_data = filter(th_win, 1, th_data(end:-1:1,:));
th_data=th_data(end:-1:1,:);
th_data = th_data(th_win_size:end-th_win_size-1,:);

data = data(th_win_size:end-th_win_size-1,:);
% th_data = th_data(th_win_size:end-th_win_size+1,:);
% t_th = t(th_win_size:end-th_win_size+1);
% t=linspace(-t(length(t)/2), t(end)+t(length(t)/2+1),length(test_data));
% t=[-t(length(t)/2:-1:1); t; t(end)+t(length(t)/2+1:end)];
t_th=t;

figure(2); clf
subaxis(3,1,1)
plot(t,data)
axis tight
subaxis(3,1,2)
plot(t_th, th_data);
axis([0 t(end) 0 1]); axis autoy
subaxis(3,1,3)
plot(t_th, rms(th_data,2));
axis([0 t(end) 0 1]); axis autoy

figure(3); clf
subaxis(3,1,1)
plot(t,data)
axis tight
subaxis(3,1,2)
plot(t_th, th_data2);
axis([0 t(end) 0 1]); axis autoy
subaxis(3,1,3)
plot(t_th, rms(th_data2,2));
axis([0 t(end) 0 1]); axis autoy

return
figure(1);clf
subaxis(3,2,1,1,2,1, 'PT', 0, 'MT', 0);
plot(t,data);hold on;

running = true;
while(running)
    windata = data(ws:ws+window_size-1,:).*window;
    fftdata = abs(fft(windata, window_size, 1)/window_size);
    fftdata = filtfilt(spec_window,1,fftdata(1:window_size/2,:));
    fftdata(2:end-1,:) = 2*fftdata(2:end-1,:);
    f = Fs/2*(1:window_size/2)'/window_size;
     
    
    HVSRdata = [sqrt(abs(fftdata(:,2)).^2 + abs(fftdata(:,3)).^2) ./ abs(fftdata(:,1)), ...
    sqrt(abs(fftdata(:,5)).^2 + abs(fftdata(:,6)).^2) ./ abs(fftdata(:,4))];

    if(exist('h_bars','var'))
        delete(h_bars)
    end
    subaxis(3,2,1,1,2,1, 'PT', 0, 'MT', 0);
    h_bars = plot(Ts.*[ws ws], minmax, 'k', ...
        Ts.*repmat(ws+window_size,1,2), minmax, 'k');
    subaxis(3,2,1,2,2,1, 'PT', 0, 'MT', 0);
    plot(t(ws:ws+window_size-1), windata);
    axis tight
    subaxis(3,2,1,3,1,1, 'PT', 0, 'MT', 0);
    loglog(f, fftdata);
    axis([0 2*filter_cutoff 0 1]);
    axis autoy
    subaxis(3,2,2,3,1,1, 'PT', 0, 'MT', 0);
    loglog(f, HVSRdata);
    axis([0 2*filter_cutoff 0 1]);
    axis autoy
    [x, y, button] = ginput(1);
    if(button == 1 || button == 3)
        if(button == 1)
            ws = floor(x)*Fs;
        else
            window_size = 2^nextpow2(floor(x)*Fs - ws - 1);
            window_size = floor(x)*Fs-ws;
        end
        if(ws+window_size>length(data))
            window_size = length(data)-ws;
        end
        window = repmat(hann(window_size), 1, Nchan);
    end
    if(button == 2)
        running = false;        
    end
end