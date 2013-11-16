function options = parseOptimizationOptions(optFile)

fid = fopen(optFile, 'r');
if fid == -1; 
    error(['ERROR: Could not locate and open file ' [SIM.rootDir filesep SIM.optOptions]]); 
end

% skip past the header section of the file (can have variable length)
reading = true;
while reading
    temp    = fgetl(fid);
    reading = ~strncmpi(temp, '<startMatlabInput>', 18);
end

% read and execute the text following Matlab syntax
temp1   = [];
temp2   = [];
reading = true;
while reading
    temp1 = fgetl(fid);
    if temp1 == -1; % reached end of file
        reading = false;
    end    
    temp2 = cat(2,temp2,temp1);
end

evalc(temp2);

fclose(fid);

