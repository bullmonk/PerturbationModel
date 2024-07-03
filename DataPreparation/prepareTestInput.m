function[] = prepareTestInput(lshell, mlt, varargin)
    % input definition.
    ip = inputParser;
    addRequired(ip, 'lshell');
    addRequired(ip, 'mlt');
    addParameter(ip, 'iFile', 'satellite_100.csv');
    addParameter(ip, 'oFile', 'featuresForModelPlot.csv');
    addParameter(ip, 'valueRow', -1);
    parse(ip, lshell, mlt, varargin{:});

    % create result.
    tbl = readtable(ip.Results.iFile);
    coord = combvec(lshell, mlt);
    len = length(coord); % total number of rows in our test input.
    M = median(tbl, 1);
    if ip.Results.valueRow > 0
        M = tbl(ip.Results.valueRow, :);
    end
    test_input = repmat(M, len, 1);
    test_input.lshell = coord(1,:)';
    test_input.cos = cos(coord(2,:) / 24 * 2 * pi)';
    test_input.sin = sin(coord(2,:) / 24 * 2 * pi)';
    test_input.mlat(:) = 0;
    test_input.ae_index = (0.1:0.1:0.1*len)';
    % save output.
    writetable(test_input, ip.Results.oFile, 'WriteVariableNames', true);

end