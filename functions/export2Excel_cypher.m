function export2Excel_cypher(results,savePath,filename)
cd (savePath)


id = 'MATLAB:xlswrite:AddSheet';
warning('off',id);


writetable(array2table(results.rawData),filename,'WriteVariableNames',false,...
    'Sheet','raw_data');
writetable(array2table(results.normalized_data),filename,'WriteVariableNames',false,...
    'Sheet','normalized_data');
writetable(cell2table(results.averagedCurves ),filename,'WriteVariableNames',false,...
    'Sheet','Mean_Curves');
writetable(cell2table(results.resultsMeanCurve),filename,'WriteVariableNames',false,...
    'Sheet','deltaF_calculations_meanCurve');
writetable(cell2table(results.resultsIndiv_dF),filename,'WriteVariableNames',false,...
    'Sheet','deltaF_individualROIs');
writetable(cell2table(results.resultsIndiv_positionStim),filename,'WriteVariableNames',false,...
    'Sheet','positionOfStim_individualROIs');
writetable(cell2table(results.statisticsIndiv),filename,'WriteVariableNames',false,...
    'Sheet','statistics_individualROIs');

end
