function HVSR = calculateHVSR(signal, frame_starts, window)
    window_size = length(window);
    Nch = floor(size(signal,2)/3);
    Nframes = length(frame_starts);
    HVSR = zeros(window_size/2, Nframes, Nch);
%     window = repmat(window, 1, Nch);
    
%     Fs = 125;
%     freq = Fs*(1:window_size/2)'/window_size;
    spec_window_width = 7;
    spec_window = bartlett(spec_window_width);

    for ch=1:1:Nch
        for idx = frame_starts
            windata = signal(idx:idx+window_size-1,(3*ch-2):(3*ch)).*window;
            fftdata = abs(fft(windata, window_size, 1)/window_size);
            fftdata = fftdata(1:window_size/2,:)+fftdata(end:-1:1+window_size/2,:);
            fftdata = apply_window(spec_window,fftdata);
            H = sqrt(fftdata(:,2).^2 + fftdata(:,3).^2);
            V = fftdata(:,1);
            HVSR(:,frame_starts==idx,ch) = H ./ V;
        end
    end
end