function [HVSR_R, HVSR_X, HVSR_Y] = calculateHVSR(signal, frame_starts, window)
    global frame_size Fs
    freq = Fs*(1:frame_size/2)'/frame_size;

    window_size = length(window);
    Nch = floor(size(signal,2)/3);
    Nframes = length(frame_starts);
    HVSR_R = zeros(window_size/2, Nframes, Nch);
    HVSR_Y = HVSR_R;
    HVSR_X = HVSR_R;
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
            X = fftdata(:,1);
            Y = fftdata(:,2);
            V = fftdata(:,3);
            R = sqrt(X.^2 + Y.^2);
            HVSR_R(:,frame_starts==idx,ch) = R ./ V;
            HVSR_X(:,frame_starts==idx,ch) = X ./ V;
            HVSR_Y(:,frame_starts==idx,ch) = Y ./ V;
            
%             figure(999);clf; ylims = [10^-6 10^-2];
%             loglog(freq,V,'LineWidth',2);hold on;
%             loglog(freq,R,'LineWidth',2);
%             loglog(freq,R./V*2*10^-5,'LineWidth',2)
%             loglog(0.85*[1 1], ylims, '--k');
%             loglog(1.59*[1 1], ylims, '--k');
%             loglog(8.2*[1 1], ylims, '--k');
%             grid on; xlim([0.1, 55]);ylim(ylims);
%             legend('V','R','HVSR');
%             a=5; drawnow;
        end
    end
end