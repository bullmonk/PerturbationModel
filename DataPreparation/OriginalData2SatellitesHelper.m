function[result_data] = OriginalData2SatellitesHelper(original_data, operation, filtered_index, satellite_id)
    ip = inputParser;
    addRequired(ip, 'original_data');
    addRequired(ip, 'operation');
    addOptional(ip, 'filtered_index', [])
    addOptional(ip, 'satellite_id', 0)

    switch operation
        case OriginalData2SatellitesHelperOperation.GetSatellite
            satellite = getSatellite(original_data, satellite_id);
            result_data = rmfield(satellite, "rbsp_num");
        case OriginalData2SatellitesHelperOperation.Cleanup
            idx = original_data.density > -1e30;
            result_data = filterData(original_data, idx);
        case OriginalData2SatellitesHelperOperation.Filter
            result_data = filterData(original_data, filtered_index);
    end
end

function[satellite] = getSatellite(original_data, id)
    if ~isfield(original_data, "rbsp_num")
        disp("satellite separation has been done, or no [rbsp_num] field found.")
        return;
    end
    idx = find(original_data.rbsp_num == id);
    satellite = filterData(original_data, idx);
end

function[result_data] = filterData(original_data, idx)
    original_data.bacg_down = original_data.bacg_down(idx);
    original_data.bacg_up = original_data.bacg_up(idx);
    original_data.density = original_data.density(idx);
    original_data.datetime = original_data.datetime(idx);
    original_data.lshell = original_data.lshell(idx);
    original_data.mlt = original_data.mlt(idx);
    original_data.mlat = original_data.mlat(idx);
    original_data.rrr = original_data.rrr(idx);
    if isfield(original_data, "rbsp_num")
        original_data.rbsp_num = original_data.rbsp_num(idx);
    end
    result_data = original_data;
end