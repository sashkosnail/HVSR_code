function [result, Wbpf] = CalculateBPFResponse(params, type, draw)
global HVSR
persistent line SkipFrames
	f = HVSR.f;
	N = length(f);
	
	gain = 1;
	switch type
		case 'freq-prod'
			offset = 1;
		otherwise
			offset = 0;
	end
	
	params = reshape(params, numel(params)/3, 3);
	
	Wbpf = zeros(N, size(params,1));
	for fi = 1:1:size(params,1)
		nrm_f = (f./params(fi,3)).^2;
		filter_resp = (nrm_f./((1-nrm_f).^2 + nrm_f)).^params(fi,2);
		Wbpf(:,fi) = offset+gain*params(fi,1)*filter_resp;
	end
	
	switch type
		case 'freq-prod'
			result = prod(Wbpf, 2);
		case 'time-sum'
			Vert = repmat(HVSR.LowSources(1).Vert, 1, size(Wbpf,2));
			result = sum(ifft(Wbpf.*Vert),2);
			result = abs(fft(result)./Vert(:,1));
		case 'freq-sum'
			result = sum(Wbpf, 2);
		otherwise
			return
	end	
	
	if(draw~=0)
		if(SkipFrames)
			SkipFrames = SkipFrames - 1;
		else
			if(~isempty(line))
				delete(line)
			end
			line = plot(HVSR.f, result, 'm', 'Parent', draw);
			drawnow();
			SkipFrames = 10;
		end
	end
end

