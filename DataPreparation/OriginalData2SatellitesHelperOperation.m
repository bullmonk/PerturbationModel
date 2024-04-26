classdef OriginalData2SatellitesHelperOperation
    enumeration
        GetSatellite,
        Cleanup, % remove duplicated time, and remove -Inf densities
        Filter
    end
end