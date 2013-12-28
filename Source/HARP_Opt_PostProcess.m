function HARP_Opt_PostProcess(BLADE,CAV,ENV,OPT,SIM,TURB,WTP)

state = 'final';
switch OPT.ALG
    case {'GradientSearch','PatternSearch'} % Single Objective Methods        
        % create the blank XLS file
        copyfile([SIM.sourceDir filesep 'spreadsheetOutput_template.xls'], SIM.xlsfile);

        % get the final data structures, corresponding to the "best" set of design variables
        [best_f, BLADE, WTP, WTPoup] = optAero(OPT.xBest,SIM,OPT,TURB,BLADE,ENV,WTP,CAV,state);
        
        copyfile([SIM.sourceDir filesep 'spreadsheetOutput_template.xls'], SIM.xlsfile);
        
        % and write some info to XLSfile:
        % this while loop is a shameful hack, but it is a quick fix for the
        % Windows bug related to: some kind of race condition issue???
        % http://stackoverflow.com/questions/12308878/file-overwrite-in-java-user-mapped-section-open-error
        % okay here comes a workaround (hack attack)
        notworking = true;
        while notworking
            % keep trying
            try
                writeOupFileXLS(SIM,OPT,TURB,BLADE,ENV,WTP,WTPoup);                   
                notworking = false; % it worked! break out of the loop
            catch
                notworking = true;
            end
        end
   
        % final saving of data and cleanup
        save(SIM.matfile);
        fprintf(1, 'All data in HARP_Opt workspace saved to MAT-file: \n %s \n\n', SIM.matfile);
        
    case {'ParticleSwarm','GeneticAlgorithm','MOGeneticAlgorithm'} % Multiple Objective Methods        
        %sort the Pareto set in order of ascending aero objective
        [sortedFvals sortIndex] = sortrows(OPT.finalScores); % sorts in ascending order
        OPT.sortedfinalPop      = zeros(size(OPT.finalPop));
        for n = 1:length(sortIndex)
            OPT.sortedfinalPop(n,:) = OPT.finalPop((sortIndex(n)),:);
        end
        
        % do a little clean-up to remove old WT_Perf files
        cd(SIM.outputDir);
        delete *.wtp;
        delete *.oup;
        delete *.bed;
        cd(SIM.rootDir);
        
        for n = 1:size(OPT.finalPop, 1)
            % update the casename to reflect the Pareto solution
            SIM.caseName = [SIM.tag '_Pareto_' num2str(n)];
            SIM.xlsfile  = [SIM.outputDir filesep SIM.caseName '.xls'];
            SIM.matfile  = [SIM.outputDir filesep SIM.caseName '.mat'];
            
            % create the blank XLS file
            copyfile([SIM.sourceDir filesep 'spreadsheetOutput_template.xls'], SIM.xlsfile);
            
            % get the final data structures, corresponding to the "best" set of design variables
            [best_f, BLADE, WTP, WTPoup] = optAero(OPT.sortedfinalPop(n,:),SIM,OPT,TURB,BLADE,ENV,WTP,CAV,state);

            % and write some info to XLSfile:
            % this while loop is a shameful hack, but it is a quick fix for the
            % Windows bug related to: some kind of race condition issue???
            % http://stackoverflow.com/questions/12308878/file-overwrite-in-java-user-mapped-section-open-error
            % okay here comes a workaround (hack attack)
            notworking = true;
            while notworking
                % keep trying
                try
                    writeOupFileXLS(SIM,OPT,TURB,BLADE,ENV,WTP,WTPoup);                   
                    notworking = false; % it worked! break out of the loop
                catch
                    notworking = true;
                end
            end
            
            % final saving of data and cleanup
            save(SIM.matfile);
            fprintf(1, 'All data in HARP_Opt workspace saved to MAT-file: \n %s \n\n', SIM.matfile);
        end
end

