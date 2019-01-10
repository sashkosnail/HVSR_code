
Q = sqrt(1./(2.^(1./(2*HVSR.ModelParams(:,3)))-1));
D = 1./(2*Q);
id = (1:1:length(HVSR.ModelParams))';
tbl = array2table(round([HVSR.ModelParams Q D], 3), ...
	'VariableNames', {'Fc', 'Gain', 'n', 'Q', 'D'}, ...
	'RowNames', arrayfun(@(x) ['BPF #' num2str(x)], id, 'UniformOutput', 0));
writetable(tbl, 'test', 'FileType', 'text', 'WriteRowNames', 1);