function [result, Wbpf] = CalculateBPFResponse(params, type, draw, f)
global HVSR
persistent line SkipFrames
if(~exist('f','var')||isempty(f))
	f = HVSR.f;
end
	N = length(f);
	
	gain = 1;
	switch type
		case 'freq-prod'
			offset = 1;
		otherwise
			offset = 0;
	end
	Wbpf = zeros(N, size(params,1));
	for fi = 1:1:size(params,1)
		nrm_f = (f./params(fi,1)).^2;
		filter_resp = (nrm_f./((1-nrm_f).^2 + nrm_f)).^params(fi,3);
		Wbpf(:,fi) = offset+gain*params(fi,2)*filter_resp;
	end
	Wbpf(Wbpf==0) = min(min(Wbpf(Wbpf>0)));
	switch type
		case 'freq-prod'
			result = prod(Wbpf, 2);
		case 'time-sum'
			Vert = repmat(HVSR.LowSources(1).Vert, 1, size(Wbpf,2));
			result = sum(ifft(Wbpf.*Vert),2);
			result = abs(fft(result)./Vert(:,1));
		case 'freq-sum'
			result = sum(Wbpf, 2)+1;
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
			line = plot(f, result, 'm', 'Parent', draw);
			drawnow();
			SkipFrames = 10;
		end
	end
end

