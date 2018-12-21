d = dir('*.SAC');
data = [];
for i = 1:1:length(d)
	test_data = rdSac(d(i).name);
	if(strfind(d(i).name, 'HHE'))
		data(:,1) = test_data.d;
	elseif(strfind(d(i).name, 'HHN'))
		data(:,2) = test_data.d;
	else
		data(:,3) = test_data.d;
	end
end
D = [test_data.t(55000:108000) data(55000:108000,:)];
save('testEQ.mat', 'D');