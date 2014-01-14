%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright 2014 Danny Sale and Michael Lawson
% 
% Licensed under the Apache License, Version 2.0 (the "License");
% you may not use this file except in compliance with the License.
% You may obtain a copy of the License at
% 
%     http://www.apache.org/licenses/LICENSE-2.0
% 
% Unless required by applicable law or agreed to in writing, software
% distributed under the License is distributed on an "AS IS" BASIS,
% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing permissions and
% limitations under the License.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [af3 af1 af2] = interpAFcoefs(afc_file1,...
                                       afc_file2,...
                                       thickVal1,...
                                       thickVal2,...
                                       FOIL_FAM, ...
                                       outputDir,...
                                       INTERP_COEFS, ...
                                       SIM)

delT = 0.1;
thickVals = ((thickVal1-delT):-delT:(thickVal2+delT))';
if isempty(thickVals)
    % Stop this function early, there is no need to interpolate 
    % because the thickness values are close enough already
    return; 
end

shortName1 = strcat(FOIL_FAM,'_',num2str(10.*thickVal1,'%04.0f'),'.dat');
shortName2 = strcat(FOIL_FAM,'_',num2str(10.*thickVal2,'%04.0f'),'.dat');
fileStr    = fullfile(outputDir,'Airfoil_Data',FOIL_FAM);

fprintf(1,['Interpolating: ' shortName1 ' to ' shortName2 '...\n'])

fid1 = fopen(afc_file1,'r');
fid2 = fopen(afc_file2,'r');
if fid1 == -1
    error(['ERROR: Could not locate and open file ' afc_file1]);
end
if fid2 == -1
    error(['ERROR: Could not locate and open file ' afc_file2]);
end

numREtables1 = cell2mat(textscan(fid1,'%f','HeaderLines',3)); 
numREtables2 = cell2mat(textscan(fid2,'%f','HeaderLines',3));

if numREtables1 ~= numREtables2
    error(['Error: Airfoil files ' afc_file1 ' and ' afc_file2 ' must have the same number of tables for Reynolds number.'])
end

% move the cursor to the Reynolds number line, so the FOR loop works correctly
frewind(fid1);
frewind(fid2);
for n = 1:4; 
    fgetl(fid1); 
    fgetl(fid2); 
end 

% read in all airfoil tables
af1.name     = shortName1;
af2.name     = shortName2;
af1.perThick = thickVal1;
af2.perThick = thickVal2;
af1.Re       = zeros(numREtables1,1);
af2.Re       = zeros(numREtables1,1);
af1.stallAoA = zeros(numREtables1,1);
af2.stallAoA = zeros(numREtables1,1);
af1.coefs    = cell(numREtables1,1);
af2.coefs    = cell(numREtables1,1);
for n = 1:numREtables1
       
    % read the Reynolds number and stall angle
    af1.Re(n) = cell2mat(textscan(fid1,'%f')); 
    af2.Re(n) = cell2mat(textscan(fid2,'%f')); 
    if af1.Re(n) ~= af2.Re(n)
        fprintf(1,'Warning: Airfoil files %s and %s have Reynolds Numbers of %f and %f, respectively.\n',shortName1,shortName2,af1.Re(n),af2.Re(n));
        fprintf(1,'         These Reynolds numbers do not match as they should, continuing anyways... \n\n');
    end
    for m = 1:2
        fgetl(fid1); 
        fgetl(fid2);
    end
    af2.stallAoA(n) = cell2mat(textscan(fid2,'%f')); 
    af1.stallAoA(n) = cell2mat(textscan(fid1,'%f')); 
    fgetl(fid1);
    fgetl(fid2);  
    
    % move the cursor to the first line of coefficients
    for m = 1:6
        fgetl(fid1);
        fgetl(fid2);
    end
    
    % read the table of coefficients
    af1.coefs{n} = cell2mat(textscan(fid1,'%f %f %f %f %f','CollectOutput',1));
    af2.coefs{n} = cell2mat(textscan(fid2,'%f %f %f %f %f','CollectOutput',1));

    if any(isnan(af1.coefs{n}(:,5)));
        % Delete 5th column if the user did not input this coefficient
        af1.coefs{n}(:,5) = [];
        af2.coefs{n}(:,5) = [];
    end
    if any(isnan(af1.coefs{n}(:,4))); 
        % Delete 4th column if the user did not input this coefficient
        af1.coefs{n}(:,4) = []; 
        af2.coefs{n}(:,4) = []; 
    end

    % move past the "EOT" line
    fgetl(fid1);
    fgetl(fid2);  
    
end

numCols = size(af1.coefs{1},2);

% initialize the progress bar
% H = waitbar(0,'','Name','Interpolating airfoil coefficients...');
% hchild = get(H,'children');
% htitle = get(hchild,'title');
% set(htitle,'Interpreter','None','FontSize',8);

af3.name      = cell(1, numel(thickVals));
af3.perThick  = zeros(1, numel(thickVals));
af3.Re        = af1.Re;
af3.stallAoA  = zeros(numREtables1, numel(thickVals));
af3.coefs     = cell(numREtables1, numel(thickVals));

for j = 1:numel(thickVals)
    
    fid3 = fopen([fileStr '_' num2str(10.*thickVals(j),'%04.0f') '.dat'],'w');    
    fprintf(fid3,'AeroDyn airfoil file.  Compatible with AeroDyn v13.0.\r\n');
    fprintf(fid3,'This file was generated automatically by HARP_Opt version %s.\r\n', SIM.version);
    fprintf(fid3,'This data represents a %g percent thick airfoil, interpolated between the data in files %s and %s.\r\n',thickVals(j),af1.name,af2.name);
    fprintf(fid3,'%6.0f         Number of airfoil tables in this file\r\n',numREtables1);
    
    % weight value to be used in weighted averaging
    w = (thickVals(j) - thickVal1)/(thickVal2 - thickVal1);

    for n = 1:numREtables1
        
        stallAoA3 = (1-w).*af1.stallAoA(n) + w.*af2.stallAoA(n);
        
        % print the current header to file
        fprintf(fid3,'%6.3f         Table ID parameter (Reynolds number in millions)\r\n',af1.Re(n));
        fprintf(fid3,'  0           Control setting\r\n');
        fprintf(fid3,'%6.3f         Stall angle (deg)\r\n',stallAoA3);
        fprintf(fid3,'  0           Zero lift angle of attack (deg)\r\n');
        fprintf(fid3,'  0           Cn slope for zero lift (dimensionless)\r\n');
        fprintf(fid3,'  0           Cn at stall value for positive angle of attack\r\n');
        fprintf(fid3,'  0           Cn at stall value for negative angle of attack\r\n');
        fprintf(fid3,'  0           Angle of attack for minimum CD (deg)\r\n');
        fprintf(fid3,'  0           Minimum CD value\r\n');

        aoa1 = af1.coefs{n}(:,1);   % Angles of Attack
        aoa2 = af2.coefs{n}(:,1);   
        CL1  = af1.coefs{n}(:,2);   % Lift coefficients
        CL2  = af2.coefs{n}(:,2);   
        CD1  = af1.coefs{n}(:,3);   % Drag coefficients 
        CD2  = af2.coefs{n}(:,3);   
        if numCols >= 4
            C41  = af1.coefs{n}(:,4);   % 4th column coefficients 
            C42  = af2.coefs{n}(:,4);   
        end
        if numCols == 5
            C51  = af1.coefs{n}(:,5);   % 5th column coefficients 
            C52  = af2.coefs{n}(:,5);   
        end
        
        % 2 methods for interpolating lift and drag coefficients
        switch INTERP_COEFS
            case 'normal'
                aoa3 = aoa2;
                CL1  = interp1q(aoa1,CL1,aoa2);
                CD1  = interp1q(aoa1,CD1,aoa2);
                CL3  = (1-w).*CL1 + w.*CL2;
                CD3  = (1-w).*CD1 + w.*CD2;
                % print the current table of coefficient to file
                % C5 is 5th coefficient in table, C4 is 4th coefficient, if they exist
                if numCols >= 4
                    C41 = interp1q(aoa1,C41,aoa2);
                    C42 = interp1q(aoa2,C42,aoa2);
                    C43 = (1-w).*C41 + w.*C42;
                end
                if numCols == 5
                    C51 = interp1q(aoa1,C51,aoa2);
                    C52 = interp1q(aoa2,C52,aoa2);
                    C53 = (1-w).*C51 + w.*C52;
                end 
                
            case 'shape'
                % divide into N points in order to guarantee a spacing = 
                % stepsize or smaller, use the limiting case from region 1 
                % or 2 of airfoil 1 or 2
                stepsize = 0.01; % largest possible stepsize for AoA
                N = max(floor([af1.stallAoA(n);...
                               45-af1.stallAoA(n);...
                               af2.stallAoA(n);...
                               45-af2.stallAoA(n)]/stepsize + 1));

                % region 1: AoA = 0 to stallAoA
                aoa1_r1 = linspace(0,af1.stallAoA(n),N)';
                aoa2_r1 = linspace(0,af2.stallAoA(n),N)';
                CL1_r1  = interp1q(aoa1,CL1,aoa1_r1);
                CL2_r1  = interp1q(aoa2,CL2,aoa2_r1);
                CD1_r1  = interp1q(aoa1,CD1,aoa1_r1);
                CD2_r1  = interp1q(aoa2,CD2,aoa2_r1);
                if numCols >= 4
                    C41_r1 = interp1q(aoa1,C41,aoa1_r1);
                    C42_r1 = interp1q(aoa2,C42,aoa2_r1);
                end
                if numCols == 5
                    C51_r1 = interp1q(aoa1,C51,aoa1_r1);
                    C52_r1 = interp1q(aoa2,C52,aoa2_r1);
                end
                aoa3_r1 = linspace(0,stallAoA3,N)';
                CL3_r1  = (1-w).*CL1_r1 + w.*CL2_r1;
                CD3_r1  = (1-w).*CD1_r1 + w.*CD2_r1;
                if numCols >= 4
                    C43_r1 = (1-w).*C41_r1 + w.*C42_r1;
                end
                if numCols == 5
                    C53_r1 = (1-w).*C51_r1 + w.*C52_r1;
                end
                
                % region 2: AoA = stallAoA to 45
                aoa1_r2 = linspace(af1.stallAoA(n),45,N)';
                aoa2_r2 = linspace(af2.stallAoA(n),45,N)';
                CL1_r2  = interp1q(aoa1,CL1,aoa1_r2);
                CL2_r2  = interp1q(aoa2,CL2,aoa2_r2);
                CD1_r2  = interp1q(aoa1,CD1,aoa1_r2);
                CD2_r2  = interp1q(aoa2,CD2,aoa2_r2);
                if numCols >= 4
                    C41_r2 = interp1q(aoa1,C41,aoa1_r2);
                    C42_r2 = interp1q(aoa2,C42,aoa2_r2);
                end
                if numCols == 5
                    C51_r2 = interp1q(aoa1,C51,aoa1_r2);
                    C52_r2 = interp1q(aoa2,C52,aoa2_r2);
                end
                aoa3_r2 = linspace(stallAoA3,45,N)';
                CL3_r2  = (1-w).*CL1_r2 + w.*CL2_r2;
                CD3_r2  = (1-w).*CD1_r2 + w.*CD2_r2;
                if numCols >= 4
                    C43_r2 = (1-w).*C41_r2 + w.*C42_r2;
                end
                if numCols == 5
                    C53_r2 = (1-w).*C51_r2 + w.*C52_r2;
                end
                
                % region 3: -180 to 0
                aoa2_r3 = aoa2(aoa2 < 0);
                CL1_r3  = interp1q(aoa1,CL1,aoa2_r3);
                CL2_r3  = interp1q(aoa2,CL2,aoa2_r3);
                CL3_r3  = (1-w).*CL1_r3 + w.*CL2_r3;
                CD1_r3  = interp1q(aoa1,CD1,aoa2_r3);
                CD2_r3  = interp1q(aoa2,CD2,aoa2_r3);
                CD3_r3  = (1-w).*CD1_r3 + w.*CD2_r3;
                if numCols >= 4
                    C41_r3 = interp1q(aoa1,C41,aoa2_r3);
                    C42_r3 = interp1q(aoa2,C42,aoa2_r3);
                    C43_r3 = (1-w).*C41_r3 + w.*C42_r3;
                end
                if numCols == 5
                    C51_r3 = interp1q(aoa1,C51,aoa2_r3);
                    C52_r3 = interp1q(aoa2,C52,aoa2_r3);
                    C53_r3 = (1-w).*C51_r3 + w.*C52_r3;
                end
                
                % region 4: 45 to 180
                aoa2_r4 = aoa2(aoa2 > 45);
                CL1_r4  = interp1q(aoa1,CL1,aoa2_r4);
                CL2_r4  = interp1q(aoa2,CL2,aoa2_r4);
                CL3_r4  = (1-w).*CL1_r4 + w.*CL2_r4;
                CD1_r4  = interp1q(aoa1,CD1,aoa2_r4);
                CD2_r4  = interp1q(aoa2,CD2,aoa2_r4);
                CD3_r4  = (1-w).*CD1_r4 + w.*CD2_r4;
                if numCols >= 4
                    C41_r4 = interp1q(aoa1,C41,aoa2_r4);
                    C42_r4 = interp1q(aoa2,C42,aoa2_r4);
                    C43_r4 = (1-w).*C41_r4 + w.*C42_r4;
                end
                if numCols == 5
                    C51_r4 = interp1q(aoa1,C51,aoa2_r4);
                    C52_r4 = interp1q(aoa2,C52,aoa2_r4);
                    C53_r4 = (1-w).*C51_r4 + w.*C52_r4;
                end
                
                % combine the regions
                aoa3_tmp = [aoa2_r3; aoa3_r1; aoa3_r2(2:end); aoa2_r4];
                CL3_tmp  = [CL3_r3; CL3_r1; CL3_r2(2:end); CL3_r4];
                CD3_tmp  = [CD3_r3; CD3_r1; CD3_r2(2:end); CD3_r4];
                if numCols >= 4
                    C43_tmp = [C43_r3; C43_r1; C43_r2(2:end); C43_r4];
                end
                if numCols == 5
                    C53_tmp = [C53_r3; C53_r1; C53_r2(2:end); C53_r4];
                end
                
                % interpolate back to a reasonable stepsize
                del1 = cosspace(0,stallAoA3,20,'end');
                del2 = cosspace(stallAoA3,45,20,'start');
                aoa3 = [aoa2_r3; del1; del2(2:end); aoa2_r4];
                CL3  = interp1q(aoa3_tmp,CL3_tmp,aoa3);
                CD3  = interp1q(aoa3_tmp,CD3_tmp,aoa3);
                if numCols >= 4
                    C43 = interp1q(aoa3_tmp,C43_tmp,aoa3);
                end
                if numCols == 5
                    C53 = interp1q(aoa3_tmp,C53_tmp,aoa3);
                end
                
        end
    
        % print the current table of coefficient to file
        % C5 is 5th coefficient in table, C4 is 4th coefficient, if they exist
        if numCols == 5
            coefs3 = [aoa3 CL3 CD3 C43 C53];
            fprintf(fid3,'%5.3f    %6.4f    %6.4f    %6.4f    %6.4f\r\n',coefs3');
        elseif numCols == 4
            coefs3 = [aoa3 CL3 CD3 C43];
            fprintf(fid3,'%5.3f    %6.4f    %6.4f    %6.4f\r\n',coefs3');
        else
            coefs3 = [aoa3 CL3 CD3];
            fprintf(fid3,'%5.3f    %6.4f    %6.4f\r\n',coefs3');
        end
        
        fprintf(fid3,'EOT %g\r\n',n);
        
        af3.name(j)       = {[FOIL_FAM '_' num2str(10.*thickVals(j),'%04.0f') '.dat']};
        af3.perThick(j)   = thickVals(j);
        af3.stallAoA(n,j) = stallAoA3;
        af3.coefs{n,j}    = coefs3;     
        
    end
    fclose(fid3);
    
    % Report current progress in the waitbar's message field
    %waitbar(j/(numel(thickVals)-1),H,['Interpolating: ' shortName1 ' to ' shortName2])
    
    
end


%delete(H) % DELETE the waitbar; don't try to CLOSE it.
