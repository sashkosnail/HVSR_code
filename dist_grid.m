s = [43.09498,-79.87018	 	
		44.243720, -81.442250	 	
		43.923560, -78.396990	 	
		43.608670, -80.062360	 	
		43.209630, -79.170530	 	
		43.964310, -79.071430]; 	
s_names = {'TYNO','BRCO','WLVO','ACTO','STCO','PKRO'};
[s_names, id] = sort(s_names);
s = s(id,:);

e = [43.672, -78.232			
		44.677, -80.482				
		42.864, -78.252				
		43.436, -78.589]; 			
e_names = {'eq2004','eq2005','eq2009','eq2017'};
e_names1 = cellfun(@(x) [x '_distance'], e_names, 'UniformOutput', 0);
e_names2 = cellfun(@(x) [x '_backazmth'], e_names, 'UniformOutput', 0);

tbl_data = zeros(length(s),2*length(e));
for n=1:1:length(e)
	[tbl_data(:,(n-1)*2+1), tbl_data(:,2*n)] = ...
		distance(s(:,1),s(:,2),e(n,1),e(n,2), ...
		referenceSphere('earth','kilometer'));
end
tbl = array2table(round(tbl_data,0), 'RowNames', s_names, ...
	'VariableNames',reshape([e_names1; e_names2], [], 1));