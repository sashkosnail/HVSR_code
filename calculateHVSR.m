function HVSR = calculateHVSR(signal, frame_starts, window)
    window_size = length(window);
    Nch = size(signal,2)/3;
    Nframes = length(frame_starts);
    HVSR = zeros(window_size/2, Nframes, Nch);
    
    Fs = 125;
    freq = Fs*(1:window_size/2)'/window_size;
    spec_window_width = 7;
    spec_window = bartlett(spec_window_width);

    for idx = frame_starts
        windata = signal(idx:idx+window_size-1,:).*window;
        fftdata = abs(fft(windata, window_size, 1)/window_size);
        fftdata = fftdata(1:window_size/2,:)+fftdata(end:-1:1+window_size/2,:);
        fftdata = apply_window(spec_window,fftdata);
        for jdx = 1:Nch
            H = sqrt(fftdata(:,2+(jdx-1)*3).^2 + fftdata(:,jdx*3).^2);
            V = fftdata(:,1+(jdx-1)*3);
            HVSR(:,frame_starts==idx,jdx) = H ./ V;
        end
    end
end