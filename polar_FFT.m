% data=dlmread('win_data_80.csv');
% f = data(2:end,1);
% clear
ws=2048;
subset = 79500 + (1:ws);
Fs = 100;
f=(0:ws/2-1)'*Fs/ws;
R=ones(361,1)*(log10([0.1 1 2 5 10 25 45])+1.5);
theta = ((0:360)*2*pi./360)'*ones(1,min(size(R)));

raw = dlmread('WLVO2005.csv');
t=raw(subset,1);

tmp = 2*pi*ones(size(f))/360;
data = raw(subset, 2:end);
% data = smoothFFT(data, 256, f, 0);
azimuth = 0:2:360;
Z = zeros(ws/2, length(azimuth), 3);
HVSR = zeros(ws/2, length(azimuth));
X = zeros(ws/2, length(azimuth));
Y = zeros(ws/2, length(azimuth));
FFTcirc = zeros(ws/2, 3, length(azimuth));
figure(11);clf
for id=1:1:length(azimuth)
	az=azimuth(id);
	rotM = [cosd(az) -sind(az) 0; sind(az) cosd(az) 0; 0 0 1];
	Rdata = data*rotM';
	
	fftRdata = abs(fft(Rdata, ws, 1))/ws;
	fftRdata = fftRdata(1:ws/2,:)+fftRdata(end:-1:1+ws/2,:);
	fftRdata = smoothFFT(fftRdata, 256, f, 0);
	FFTcirc(:,:,id) = fftRdata;
	HVSR(:,id) = log(fftRdata(:,1)./fftRdata(:,3));
	[X(:,id), Y(:,id)] = pol2cart(az*tmp, log10(f)+1.5);
	Z(:,id,:) = FFTcirc(:,:,id);
	plot(X(:,id),Y(:,id)); hold on
end
	figure(12);clf
titles = {'EW','NS','V'};
for id = 1:1:size(Z,3)
	h=subplot('Position',[0.05+(id-1)/size(Z,3) 0.1 0.26 0.8]);
	hold on
	surface(X,Y,Z(:,:,id),'linestyle','none');
	polar(theta, R,'k');
	text(R(1,:), zeros(min(size(R)),1), ...
		arrayfun(@(n) num2str(n), 10.^(R(1,:)-1.5),'UniformOutput',0), ...
		'VerticalAlignment', 'bottom');
% 	h.Children = h.Children(end:-1:1);
	title(titles{id});
% 	h.YAxis.Scale = 'log';
% 	h.XAxis.Scale = 'log';
	axis image
% 	colormap autumn
	colorbar
end
figure(13);clf
subplot(1,2,1)
hold on
surface(X, Y, HVSR, 'linestyle','none');
polar(theta, R,'k');
text(R(1,:), zeros(min(size(R)),1), ...
	arrayfun(@(n) num2str(n), 10.^(R(1,:)-1.5),'UniformOutput',0), ...
	'VerticalAlignment', 'bottom');
axis image
colormap parula
colorbar
subplot(1,2,2)
loglog(f, 10.^HVSR(:,1));