function [meanHVSR stdHVSR] = calculateHVSR(spectra)
    Nch = size(spectra,2);
    meanHVSR = zeros(length(spectra), Nch/3);
    stdHVSR = zeros(length(spectra), Nch/3);
    for idx = 1:3:Nch
        jdx = floor(idx/3);
        meanHVSR(:,jdx) = 
    end
    f = Fs/2*(1:window_size/2)'/window_size;
    figure();hold on
    plot(f, outputFFT, '--');
    meanSpec = mean(outputFFT,2);
    stdSpec = std(outputFFT,1,2);
    plot(f, meanSpec,'k-')
    plot(f, meanSpec - stdSpec, 'k--')
    plot(f, meanSpec + stdSpec, 'k--')
end