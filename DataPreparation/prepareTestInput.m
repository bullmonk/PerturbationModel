function[] = prepareTestInput(lshell, mlt, varargin)
    % input definition.
    ip = inputParser;

    addRequired(ip, 'lshell');
    addRequired(ip, 'mlt');
    addParameter(ip, 'iFile', 'data/satellite_1000.csv');
    addParameter(ip, 'oFile', 'data/modelInput_1.csv');
    addParameter(ip, 'sampleNum', 100);
    addParameter(ip, 's', '24-Apr-2018 02:23:31');
    addParameter(ip, 'e', '24-Apr-2018 02:23:31');

    parse(ip, lshell, mlt, varargin{:});

    % set variables.
    training_data = ip.Results.iFile;
    model_input_file = ip.Results.oFile;
    s = datetime(ip.Results.s);
    e = datetime(ip.Results.e);
    sampleNum = ip.Results.sampleNum;

    % for a row of traing data table, we want to expand it to global data.
    tbl = readtable(training_data);
    coord = combvec(lshell, mlt);
    len = length(coord); % total number of rows in our test input.

    % sort time series in trainign data.
    dt = sort(tbl.datetime);
    % pick those within the range.
    times = dt(dt >= s & dt <= e);

    % even sample some times and create input one by one.
    if sampleNum > length(times)
        sampleNum = length(times);
    end
    idx = 1;
    step = length(times) / sampleNum;
    outTbl = cell2table(cell(0, length(tbl.Properties.RowNames)), "RowNames", tbl.Properties.RowNames);

    for count = 1 : sampleNum
        idx = floor(idx);
        chosen = tbl(tbl.datetime == times(idx), :);
        idx = idx + step;
        test_input = repmat(chosen, len, 1);
        test_input.lshell = coord(1,:)';
        test_input.mlt = coord(2,:)';
        test_input.cos = cos(coord(2,:) / 24 * 2 * pi)';
        test_input.sin = sin(coord(2,:) / 24 * 2 * pi)';
        outTbl = vertcat(outTbl, test_input); %TODO: optimize for speed.
    end
    writetable(outTbl, model_input_file, 'WriteVariableNames', true);
end