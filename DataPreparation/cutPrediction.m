function[splits] = cutPrediction(dataFolder, iFile, ofPrefix, sampleNum)
    prediction = readtable(fullfile(dataFolder, iFile));

    splits = cell(sampleNum, 1);
    groups = findgroups(prediction.datetime);
    tbl_splits = splitapply( @(varargin) varargin, prediction, groups);

    for i = 1:size(tbl_splits, 1)
        outFile = [ofPrefix '_' datestr(tbl_splits{i, 1}(1), 'mmddyy_HHMMSS') '.csv']; %TODO: optimize.
        splits{i} = outFile;

        tmp = table(tbl_splits{i, 2}, 'VariableNames', ...
        prediction.Properties.VariableNames(2));

        writetable(tmp, fullfile(dataFolder, outFile), 'WriteVariableNames', true);
    end
end