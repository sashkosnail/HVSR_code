clear data out_files dat_file ch_file Ts Fs
if(~exist('PathName','var'))
    PathName = '';
end
[FileName, PathName, ~] = uigetfile([PathName, '*.dat'],'Pick File');
if(FileName == 0)
    return;
end
datfile = strcat(PathName, FileName);
seg2ascii = 'D:\Documents\PhD\Montmagny\data\seg2asci.exe ';
filter_cutoff = 15;

system([seg2ascii, datfile, ' 16K'],'-echo');

data = [];
out_files = dir(['D:\Documents\PhD\Montmagny\data\','*.0*']);
Nch = length(out_files);
for ch_file = out_files'
    if(~exist('Ts','var'))
        Ts = dlmread(ch_file.name, '' , 'B30..B30');
        Fs = 1/Ts;
    end
    ch_data = dlmread(ch_file.name, '', 38, 0);
    data = [data, ch_data]; %#ok<AGROW>
    delete(ch_file.name);
end
N = 2^nextpow2(length(data));
[fnum, fden] = butter(10, filter_cutoff*2/Fs, 'low');
fdata = filtfilt(fnum, fden, data);
t = 0:Ts:(length(data)-1)*Ts;
figure(); clf
subplot(3,1,1);
plot(t,fdata);
title(FileName(1:end-4))
fft_data2 = abs(fft(data.*repmat(hamming(N), 1, Nch), N, 1)/N);
fft_data = fft_data2(1:N/2,:);
fft_data(2:end-1,:) = 2*fft_data(2:end-1,:);
% fft_data = fftshift(fft(data, N, 1));
% fft_data = fft_data(N/2+1:end,:);
f = Fs*(1:N/2)'/N;
subplot(3,1,2);
plot(f,abs(fft_data))
subplot(3,1,3);
HVSR = [sqrt(abs(fft_data(:,2)).^2 + abs(fft_data(:,3)).^2) ./ abs(fft_data(:,1)), ...
    sqrt(abs(fft_data(:,5)).^2 + abs(fft_data(:,6)).^2) ./ abs(fft_data(:,4))];
D = [t' data];
mat_file = [PathName FileName(1:end-4) '.mat'];
csv_file = [PathName FileName(1:end-4) '.csv'];
save(mat_file, 'D');
dlmwrite(csv_file, D);
plot(f,HVSR);


