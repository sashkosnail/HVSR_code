night = matfile('TYNO_2006_2am_noise.mat');
day = matfile('TYNO_2006_5pm_noise_forcedPeaks.mat');

nHVSR = night.HVSR;
dHVSR = day.HVSR;

nParams = nHVSR.ModelParams;
dParams = dHVSR.ModelParams;

[dresp, dWbpf]= CalculateBPFResponse(dParams, 'freq-sum', 0, dHVSR.f);
[nresp, nWbpf]= CalculateBPFResponse(nParams, 'freq-sum', 0, nHVSR.f);
error = abs(dresp - nresp)./nresp;

figure(123); clf
ax = axes('DefaultLineLineWidth', 2, 'XScale', 'log', 'XGrid', 'on', ...
	'YGrid', 'on', 'NextPlot', 'add');

semilogx(dHVSR.f, dresp, 'r');
semilogx(dHVSR.f, nresp, 'b');
semilogx(dHVSR.f, error, 'k--');
			
semilogx(dHVSR.f, dWbpf, 'r','LineWidth', 1);
semilogx(dHVSR.f, nWbpf, 'b','LineWidth', 1);

axis tight
legend('Day','Night');

