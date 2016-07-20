function [frameIDs] = findFrames(signal, frame_size, overlap)
    id = 1;
    frameIDs = [];
%     figure(99); clf; plot(signal);hold on
%     axis([0 length(signal)-1 -0.05 1.1]);
    while(id<length(signal)-frame_size)
        if(prod(signal(id:id+frame_size-1)))
            frameIDs = [frameIDs id]; %#ok<AGROW>
%             plot([id, id+frame_size],...
%                 [0.1 0.1]+0.1*(mod(length(frameIDs)-1,3)+1));
            id = id + frame_size*overlap;
        else
            id = id + 1;
        end
    end
end