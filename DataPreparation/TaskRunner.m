function TaskRunner()
    % Create a figure window
    fig = figure('Position', [200, 200, 250, 100], 'MenuBar', 'none', ...
        'ToolBar', 'none', 'NumberTitle', 'off', 'Name', 'Macro Trigger');

    % Add a button
    btn = uicontrol('Style', 'pushbutton', 'String', 'Run Macro', ...
        'Position', [50, 30, 150, 40], 'Callback', @btnCallback);

    % Callback function for the button
    function btnCallback(~, ~)
        % Call your script or macro here
        disp('Macro is running...');
        % Call your script or macro here
        % For example:
        % runMyScript();
    end
end

% Your script or macro function
function runMyScript()
    % Add your script or macro code here
end
