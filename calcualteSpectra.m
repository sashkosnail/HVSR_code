function outputFFT = calcualteSpectra(signal, frame_starts, window)
    window_size = length(window);
    Nch = size(signal,2);
    Nframes = length(frame_starts);
    outputFFT = zeros(window_size/2*Nch, Nframes);

    spec_window_width = 15;
    spec_window = bartlett(spec_window_width);

    for idx = frame_starts
        windata = signal(idx:idx+window_size-1,:).*window;
        fftdata = abs(fft(windata, window_size, 1)/window_size);
        fftdata = apply_window(spec_window,fftdata(1:window_size/2,:));
        fftdata(2:end-1,:) = 2*fftdata(2:end-1,:);
        outputFFT(:,frame_starts==idx) = reshape(fftdata, numel(fftdata),1);
    end
    outputFFT = reshape(outputFFT, window_size/2, Nch*Nframes);
end