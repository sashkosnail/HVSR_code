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
sources = {};
for l = 1:1:length(split)
	sources{l} = FileName{l}(1:split(l)+3); %#ok<SAGROW>
end
sources = unique(sources);
directions = {'E', 'N', 'Z'};
for i = 1:1:length(sources)
	data = [];
	for n = 1:1:length(directions)
		try
			filename = [PathName sources{i} directions{n} '.D.SAC'];
% 			disp(filename)
			test_data = rdSac(filename);
			data(:,n) = test_data.d; %#ok<SAGROW>
		catch
			filename = [PathName sources{i} 'Z.D.SAC'];
			disp(['**** ' filename, ' ****'])
			test_data = rdSac(filename);
			data(:,3) = test_data.d;
			break;
		end			
	end
	D = [(0:1:length(data)-1)'*test_data.HEADER.DELTA data];
	savefile = [PathName sources{i} '.mat'];
	disp([num2str(i) savefile])
	save([PathName sources{i} '.mat'], 'D');
end
