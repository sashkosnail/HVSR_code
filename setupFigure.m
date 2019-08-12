function setupFigure(ax, h, names, colors)
	axes(ax);
% 	fig.Position = [1 1 750 400];
	if(~isempty(colors))
		set(h,{'Color'}, colors);
	end
	set(h,'LineWidth',1.2);
	if(~isempty(names))
		set(h, {'DisplayName'}, names)
	end
	l=legend('show');
	l.Location='northwest';
	xlabel('Frequency[Hz]');
	ylabel('Amplitude');
	grid on
	drawnow()
end