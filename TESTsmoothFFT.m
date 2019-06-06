%% Data
a=load('sample_spectrum');
a=a.out;
f = a.f;
fftdata = a.s;
output = zeros(length(fftdata), 7);
Fs = 100;
N = length(f);%2^nextpow2(Fs*100);

k = (0:N-1)';
f = Fs*k/N/2;
tmpf = [0.5 2.5 15];
Wout = [];
tmpb = ones(size(tmpf));
L = 0.38*0.5/(Fs/N/2);
L = L - mod(L,2)+1;

%% Process
for fci = 2:1:length(f)
	fc = f(fci); 
    % konno ohmachi
    b = 20;
    n = 4;
    tmp = log10((f./fc).^b);
    Wko = (sin(tmp)./tmp).^n;
	%Parzen Window
	Wpz = parzenwin(L);
	[~,fidx] = min(abs(f-fc));
	if(fidx<(L-1)/2)
		Wpz = Wpz((L-1)/2-fidx:end);
	else
		Wpz = [zeros(fidx-(L-1)/2,1); Wpz]; %#ok<AGROW>
	end
	if(length(Wpz) > N)
		Wpz = Wpz(1:N);
	else
		Wpz = [Wpz;zeros(N-length(Wpz),1)]; %#ok<AGROW>
	end
    % Dolph-Chebyshev
    a = 5; %-a*20dB sidelobes
    b = cosh(1/N*acosh(10^a));
    % k=(-N/2:1:N/2-1)'; 
    Wguz = (cos(N*acos(b*cos(pi*(f-fc)/Fs)))./10.^a).^2;
    % Triang
    n = 4;
    Wt = (f./fc.*(f<fc)+(1-(f-fc)./f).*(f>fc)).^n;
    %BPF
    n = [128 64 16];
    tmp = (f./fc).^2;
    Wbpf = bsxfun(@power, tmp./((1-tmp).^2 + tmp), n);
	
	%out
	W = [Wbpf Wguz Wko Wt Wpz];
	W(isnan(W)) = 0;
	if(any((fc>=tmpf)&f(fci-1)<=tmpf))
		Wout = [Wout W]; %#ok<AGROW>
	end
	W = bsxfun(@rdivide, W, sum(W));
	output(fci,:) = sum(W.*repmat(fftdata, 1, min(size(W)))); %#ok<SAGROW>
end
%% Figures
names = {'BPF n=128', 'BPF n=64', 'BPF n=16', 'Dolph-Chebyshev a=5', ...
	'Konno-Ohmachi b=20', 'Triangle n=4', 'Parzen BW=0.5Hz', 'Original'}';
colors = {[0 0 0]; [0.6 0.4 0.8]-0.2; [1 0 0]; [0 0 1]; [0 1 0]};
Wtmp = Wout;
Wtmp(:,[1 2 8 9 15 16])=[];
Wtmp = 20*log10(abs(Wtmp));

fig = figure(1);clf;
fig.Position
ax=subaxis(3,1,1,'ml',0.05,'mb',0.1);
fig.Name = 'Smoothing Functions';
	semilogx(f([2 end]), [1 1]'*-3, 'LineStyle', '-', ...
		'LineWidth', 2, 'LineStyle', ':', 'Color', 'm');
	hold on
	h = semilogx(f, Wtmp);
	axis([0.1 Fs/2 -80 1]);
	setupFigure(ax, h, [], repmat(colors,3,1));
	h(1).Parent.XTick = sort([0.1 tmpf Fs/2 10 1]);
	l=legend({'-3dB' names{3:end-1}});
	l.Location='NorthWest';
	ylabel('Amplitue[dB]');
	
% fig = figure(2);clf;
ax1=subaxis(3,1,3,'ml',0.05,'mb',0.05);
fig.Name = 'BPF Smoothed Spectra';
	h = loglog(f,fftdata,'c-');
	h.DisplayName = names{end};
	hold on;
	h = loglog(f,output(:,1:3));
	hold on
	axis([0.1 50 0.001 1])
	h(1).Parent.XTickLabel = [0.1 1 10];
	setupFigure(ax1, h, names(1:3), colors([4 3 1]));
	
% fig = figure(3);clf;
ax2=subaxis(3,1,2,'ml',0.05,'mb',0.0125);
fig.Name = 'Smoothed Spectra';
	h1 = loglog(f,fftdata,'c-');
	h1.DisplayName = names{end};
	hold on
	h = loglog(f,output(:,3:end));
 	h1.Parent.Children = [h([1 3:end-1 end 2]); h1];
	ax2.XAxis.Visible='off';
	axis([0.1 50 0.001 1])
	h(1).Parent.XTickLabel = [0.1 1 10];
	setupFigure(ax2, h, names(3:end-1), colors);
	
linkaxes([ax1 ax2])