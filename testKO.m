% konno ohmachi
	fc = [0.5, 1, 2, 5];
	Fs = 100;
	N = 50;
	f = 0.3:0.001:10;
	Wko=[];
for fcid = 1:1:length(fc)
    b = 60;
    n = 4;
    tmp = log10((f./fc(fcid)).^b);
    Wko(:, fcid) = (sin(tmp)./tmp).^n;
end

	fig = figure(888);clf
	fig.Name = 'KO';
	subplot(2,1,1)
	semilogx(f([2 end]), [1 1]'*-0.707, 'LineStyle', '-', ...
		'LineWidth', 2, 'LineStyle', ':', 'Color', 'm');
	hold on
	h = semilogx(1./f, Wko);
	axis([0.1 3 0 1]);
	subplot(2,1,2)
	semilogx(f([2 end]), [1 1]'*-0.707, 'LineStyle', '-', ...
		'LineWidth', 2, 'LineStyle', ':', 'Color', 'm');
	hold on
	h = semilogx(f, Wko);
	axis([0.3 10 0 1]);