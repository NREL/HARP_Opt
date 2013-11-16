function AF = readAFfile(afc_file)

fid1 = fopen(afc_file,'r');
if fid1 == -1
    error(['ERROR: Could not locate and open file ' afc_file]);
end

% move the cursor to the Reynolds number line, so the FOR loop works correctly
numREtables1 = cell2mat(textscan(fid1,'%f','HeaderLines',3)); 
fgetl(fid1);

% read in all airfoil tables
AF.Re       = zeros(numREtables1,1);
AF.stallAoA = zeros(numREtables1,1);
AF.coefs    = cell(numREtables1,1);
for n = 1:numREtables1
       
    % read the Reynolds number and stall angle
    AF.Re(n) = cell2mat(textscan(fid1,'%f')); 
    fgetl(fid1);
    fgetl(fid1);
    AF.stallAoA(n) = cell2mat(textscan(fid1,'%f')); 
    fgetl(fid1);
    
    % move the cursor to the first line of coefficients
    for m = 1:6
        fgetl(fid1);
    end
    
    % read the table of coefficients
    AF.coefs{n} = cell2mat(textscan(fid1,'%f %f %f %f %f','CollectOutput',1));

    if any(isnan(AF.coefs{n}(:,5)));
        % Delete 5th column if the user did not input this coefficient
        AF.coefs{n}(:,5) = [];
    end
    if any(isnan(AF.coefs{n}(:,4))); 
        % Delete 4th column if the user did not input this coefficient
        AF.coefs{n}(:,4) = []; 
    end

    % move past the "EOT" line
    fgetl(fid1);
    
end

AF.numRe  = numel(AF.Re);
for n = 1:AF.numRe
    AF.AoA{n} = AF.coefs{n}(:,1);
    AF.L{n} = AF.coefs{n}(:,2);
    AF.D{n} = AF.coefs{n}(:,3);
    AF.L_D{n} = AF.L{n}(:)./AF.D{n}(:);
    [AF.maxL_D(n) AF.maxL_D_ind(n)] = max(AF.L_D{n});
    AF.maxL_D_AoA(n)      = AF.AoA{n}(AF.maxL_D_ind(n),1);
    AF.maxCl_AoA(n)       = AF.coefs{n}(AF.maxL_D_ind(n),2);
end

end % function readAFfile