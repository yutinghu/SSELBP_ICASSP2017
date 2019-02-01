function mapping = get_mapping_info(lbpRadius,lbpPoints)
global lbpMethod;
global blockSize;
global numLBPbins;
% global lbpRadius;
% global lbpPoints;
blockSize = lbpRadius*2+1;

if lbpPoints == 24 && strcmp(lbpMethod,'LBPriu2')
    load mappingLBPpoints24RIU2;
elseif lbpPoints == 16 && strcmp(lbpMethod,'LBPriu2')
    load mappingLBPpoints16RIU2;
elseif lbpPoints == 16 && strcmp(lbpMethod,'MELBPVary')
    load mappingLBPpoints16RIU2;
elseif lbpPoints == 24 && strcmp(lbpMethod,'AELBPVary')
    load mappingLBPpoints24RIU2;
else
    mapping = getmapping(lbpPoints,lbpMethod);
end

numLBPbins = mapping.num;

end % the end of the function










