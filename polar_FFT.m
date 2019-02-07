%% Setup
myclear
ws=2048;
subset = 79500 + (1:ws);
Fs = 100;
f=(1:ws/2)'*Fs/ws;
R=ones(361,1)*(log10([0.1 1 2 5 10 25 45])+1.5);
theta = ((0:360)*2*pi./360)'*ones(1,min(size(R)));

event = [44.677, -80.482];
station = [43.923560, -78.396990];
% baz = azs(station, event);
raw = dlmread('D:\Projects\PhD\AutoDRM\FinalDataSet\2005\WLVO2005.csv');
t=raw(subset,1);

rotC = 2*pi*ones(size(f))/360;
data = raw(subset, 2:end);
azs = 0:2:360;
baz = azimuth(event, station);
Z = zeros(ws/2, length(azs), 3);
HVSR_TV = zeros(ws/2, length(azs));
HVSR_RV = zeros(ws/2, length(azs));
HVSR_RT = zeros(ws/2, length(azs));
X = zeros(ws/2, length(azs));
Y = zeros(ws/2, length(azs));
FFTcirc = zeros(ws/2, 3, length(azs));
%% Calc
figure(11);clf
for id=1:1:length(azs)
	az=azs(id);
	rotM = [cosd(az) -sind(az) 0; sind(az) cosd(az) 0; 0 0 1];
	Rdata = data*rotM';
	
	fftRdata = abs(fft(Rdata, ws, 1))/ws;
	fftRdata = fftRdata(1:ws/2,:)+fftRdata(end:-1:1+ws/2,:);
	fftRdata = smoothFFT(fftRdata, 256, f, 0);
	
% 	fftRdata = fftRdata(end:-1:1,:);
	
	FFTcirc(:,:,id) = fftRdata;
	HVSR_TV(:,id)  = (fftRdata(:,1)./fftRdata(:,3));
	HVSR_TV(isnan(HVSR_TV)) = 1;
	HVSR_RV(:,id)  = (fftRdata(:,2)./fftRdata(:,3));
	HVSR_RV(isnan(HVSR_RV)) = 1;
	HVSR_RT(:,id)  = (fftRdata(:,2)./fftRdata(:,1));
	HVSR_RT(isnan(HVSR_RT)) = 1;
% 	[X(:,id), Y(:,id)] = pol2cart(az*rotC, log10(f(end:-1:1))+1.5);%);
	tmp = [zeros(size(f)) log10(f)-log10(f(1))]*rotM(1:2,1:2);
	X(:,id) = tmp(:,1);
	Y(:,id) = tmp(:,2);
	Z(:,id,:) = FFTcirc(:,:,id);
	plot(X(:,id),Y(:,id)); hold on
	text(X(end,id),Y(end,id),num2str(az));
end
%% Interp
xq=(log10(50)-log10(f(1)))*(-1:0.005:1);
[x,y] = meshgrid(xq);
z(:,:,1)=griddata(X,Y,Z(:,:,1),x,y,'cubic');
z(:,:,2)=griddata(X,Y,Z(:,:,2),x,y,'cubic');
z(:,:,3)=griddata(X,Y,Z(:,:,3),x,y,'cubic');
z(isnan(z)) = 0;
ratios(:,:,1) = griddata(X,Y,HVSR_TV,x,y,'cubic');
ratios(:,:,2) = griddata(X,Y,HVSR_RV,x,y,'cubic');
ratios(:,:,3) = griddata(X,Y,HVSR_RT,x,y,'cubic');
ratios(isnan(ratios)) = 0;
%% Plot
figure(12);clf
titles1 = {'EW','NS','V'};
titles2 = {'T/V','R/V','R/T'};
for id = 1:1:size(Z,3)
	subplot('Position',[0.05+(id-1)*.3 0.55 0.3 0.4]);
	hold on
	image(z(:,:,id),'CDataMapping','scaled','XData',xq,'YData',xq)
	hold on
	tmp = [0 0;0 3];
	baz=0;
	rotM = [cosd(baz) -sind(baz); sind(baz) cosd(baz)];
	tmp = tmp*rotM;
	plot(tmp(:,1),tmp(:,2),'-c');
	title(titles1{id});
	axis image
	colormap hot
	colorbar
	subplot('Position',[0.05+(id-1)*.3 0.1 0.3 0.4]);
	hold on
	image(ratios(:,:,id),'CDataMapping','scaled','XData',xq,'YData',xq)
	plot(tmp(:,1),tmp(:,2),'-c');
	title(titles2{id});
	axis image
	colormap hot
	colorbar
% 	surface(X,Y,Z(:,:,id),'linestyle','none');
% 	polar(theta, R,'k');
% 	text(R(1,:), zeros(min(size(R)),1), ...
% 		arrayfun(@(n) num2str(n), 10.^(R(1,:)-1.5),'UniformOutput',0), ...
% 		'VerticalAlignment', 'bottom');
% 	h.Children = h.Children(end:-1:1);
end
%% HVSRs
% figure(13);clf
% subplot(1,2,1)
% hold on
% image(hvsr,'CDataMapping','scaled');
% % text(R(1,:), zeros(min(size(R)),1), ...
% % 	arrayfun(@(n) num2str(n), 10.^(R(1,:)-1.5),'UniformOutput',0), ...
% % 	'VerticalAlignment', 'bottom');
% colormap hot
% colorbar
% subplot(1,2,2)
% loglog(f, 10.^HVSR(:,1));