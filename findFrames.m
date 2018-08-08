function [frameIDs] = findFrames(signal, frame_size, overlap)
    id = 1;
    frameIDs = [];
    while(id<length(signal)-frame_size)
        if(signal(id) == 0)
            id = id+find(signal(id:end),1,'first')-1;
        else
            if(prod(signal(id:id+frame_size-1)))
                frameIDs = [frameIDs id]; %#ok<AGROW>
                id = id + ceil(frame_size*overlap);
            else
                id = id + find(signal(id:end)==0,1,'first')-1;
            end
        end
    end
end