global PathName
if((PathName == 0) | (~exist('PathName', 'var'))) %#ok<OR2>
	PathName = ''; end
[FileName, PathName, ~] = uigetfile([PathName, '\*.SAC'],'Pick File','MultiSelect','on');
if(~iscell(FileName))
	FileName = {FileName}; end
if(FileName{1} == 0)
	return; 
end
split = cell2mat(strfind(FileName(:),'..'));
sources = unique(cellfun(@(x) x(1:split-1), FileName, ...
	'UniformOutput', 0)');
directions = {'HHE', 'HHN', 'HHZ'};
for i = 1:1:length(sources)
	data = [];
	for n = 1:1:length(directions)
		filename = [PathName sources{i} '..' directions{n} '.D.SAC'];
		test_data = rdSac(filename);
		data(:,n) = test_data.d; %#ok<SAGROW>
	end
	D = [(0:1:length(data)-1)'*test_data.HEADER.DELTA data];
	save([PathName sources{i} '.mat'], 'D');
end
