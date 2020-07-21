% This function checks if the responses are in the range of a stim
% win determines the range in that the response can be located away

function listOfResponders = getIndivResponders(positionAv, positionIndiv, start, stop)

win = ceil((stop-start)/4);
win = max(win)+1;

%create range vector:
ranges = positionAv-win;
ranges = repmat(ranges,2*win+1,1);
adding = (0:2*win)';

%index Matrix
ranges = ranges+adding;

logical = sum(ismember(ranges,positionIndiv));

listOfResponders = logical>=1;

end