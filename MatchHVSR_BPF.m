function opt_params = MatchHVSR_BPF
	global HVSR axx
	data = HVSR.LowSources.mean;
	f = HVSR.f;
	N = length(f);

	[pk, loc] = findpeaks(data, f,'MinPeakProminence', 0.5);
	fpeaks = [loc pk];

	Num_Filters = length(fpeaks);
	params = zeros(Num_Filters, 3);
	lower_bound = zeros(Num_Filters, 3);
	upper_bound = zeros(Num_Filters, 3);
	Wbpf = zeros(N, Num_Filters);

	for fi = 1:1:length(fpeaks)
		params(fi,1) = fpeaks(fi,1);
		params(fi,2) = 64;
		params(fi,3) = fpeaks(fi,2);
		lower_bound(fi,:) = [fpeaks(fi,1) 2 0];
		upper_bound(fi,:) = [fpeaks(fi,1) 256 20];
		tmp = (f./params(fi,1)).^2;
		Wbpf(:,fi) = params(fi,3)*(tmp./((1-tmp).^2 + tmp)).^params(fi,2);
	end
	
	params = reshape(params,1,numel(params));
	lower_bound = reshape(lower_bound,1,numel(lower_bound));
	upper_bound = reshape(upper_bound,1,numel(upper_bound));
	if(mod(length(params),3))
		params = [params 0];
		lower_bound = [lower_bound 0];
		upper_bound = [upper_bound 20];
	end
	
	options = optimoptions('fmincon');
	options.Algorithm = 'sqp';
	options.TolX = 1e-10;
	options.MaxIter = 1000;
	options.MaxFunEvals = Inf;
	options.Display = 'iter';
	
	problem.objective = @ObjFunction;
	problem.x0 = params;
	problem.solver = 'fmincon';
	problem.options = options;
	problem.lb = lower_bound;
	problem.ub = upper_bound;

	figure(333);clf
	axx = axes()
	loglog(f, data , 'b');
	hold on
	plot(loc, pk, 'ks');
% 	plot(f, prod(Wbpf,2), 'r--');
% 	plot(f, Wbpf, 'g--');
	
	opt_params = fmincon(problem);
	
	if(mod(length(opt_params),3))
		offset = opt_params(end);
		params = opt_params(1:end-1);
	else
		offset = 1;
		params = opt_params;
	end
	params = reshape(params, length(params)/3, 3);
	
	
	for fi = 1:1:length(fpeaks)
		tmp = (f./params(fi,1)).^2;
		Wbpf(:,fi) = params(fi,3)*(tmp./((1-tmp).^2 + tmp)).^params(fi,2);
	end
	
	result = prod(Wbpf,2)+offset;
	
	plot(f, result, 'r');
	plot(f, Wbpf, 'g--');
	plot(f, abs(result-HVSR.LowSources.mean),'k:');
	axis([0.1 50 0.1 100]);
	grid on
end

function res = ObjFunction(params) %#ok<DEFNU>
global HVSR axx
		obj = HVSR.LowSources(1).mean;
		response = CalculateBPFResponse(params, 'freq-sum', axx);
		res = sum(sqrt((response - obj).^2));
end