function event_counts()
% Count shared-reward trial types across subjects and runs.
% Assumes this file lives in:  istart-sharedreward/code
% and BIDS lives in:          ../ds004920

    %% Locate script and BIDS root (relative paths only)
    thisFile = mfilename('fullpath');
    if isempty(thisFile)
        scriptDir = pwd;
    else
        scriptDir = fileparts(thisFile);
    end

    repoRoot  = fileparts(scriptDir);          % istart-sharedreward
    githubRoot = fileparts(repoRoot);          % .../github
    bidsRoot  = fullfile(githubRoot, 'ds004920');

    if ~isfolder(bidsRoot)
        error('BIDS directory not found at: %s', bidsRoot);
    end

    fprintf('Script directory: %s\n', scriptDir);
    fprintf('Assumed BIDS root: %s\n', bidsRoot);

    %% Define the six main event types (excluding neutral)
    eventTypes = { ...
        'event_friend_reward', ...
        'event_friend_punish', ...
        'event_stranger_reward', ...
        'event_stranger_punish', ...
        'event_computer_reward', ...
        'event_computer_punish'};

    prettyLabels = { ...
        'Friend reward', ...
        'Friend loss', ...
        'Stranger reward', ...
        'Stranger loss', ...
        'Computer reward', ...
        'Computer loss'};

    nEvents = numel(eventTypes);

    %% Discover subjects automatically
    subDirs = dir(fullfile(bidsRoot, 'sub-*'));
    subDirs = subDirs([subDirs.isdir]);
    if isempty(subDirs)
        error('No sub-* directories found in %s', bidsRoot);
    end

    nSubs = numel(subDirs);
    fprintf('Found %d subject folders.\n', nSubs);

    % Matrix: subjects × event types
    countMat   = nan(nSubs, nEvents);
    validSub   = false(nSubs, 1);
    subIDsCell = cell(nSubs, 1);

    %% Loop over subjects and runs
    for iSub = 1:nSubs
        subID   = subDirs(iSub).name;     % e.g., 'sub-1001'
        subIDsCell{iSub} = subID;

        funcDir = fullfile(bidsRoot, subID, 'func');
        if ~isfolder(funcDir)
            fprintf('[WARN] Missing func directory for %s\n', subID);
            continue;
        end

        countsSub = zeros(1, nEvents);
        runsFound = 0;

        % Two runs per subject: run-1 and run-2
        for runIdx = 1:2
            eventsFile = fullfile(funcDir, ...
                sprintf('%s_task-sharedreward_run-%d_events.tsv', subID, runIdx));

            if ~isfile(eventsFile)
                fprintf('[WARN] Missing events file: %s\n', eventsFile);
                continue;
            end

            T = readtable(eventsFile, 'FileType', 'text', 'Delimiter', '\t');

            if ~ismember('trial_type', T.Properties.VariableNames)
                error('No trial_type column in %s', eventsFile);
            end

            trialType = string(T.trial_type);

            % Count each event type for this run
            for e = 1:nEvents
                countsSub(e) = countsSub(e) + sum(trialType == eventTypes{e});
            end

            runsFound = runsFound + 1;
        end

        if runsFound == 0
            fprintf('[WARN] No runs found for %s; skipping.\n', subID);
            continue;
        end

        if sum(countsSub) == 0
            fprintf('[WARN] No matching events for %s; check trial_type labels.\n', subID);
            continue;
        end

        % Mark as valid and store counts
        validSub(iSub)   = true;
        countMat(iSub, :) = countsSub;
    end

    %% Restrict to valid subjects
    if ~any(validSub)
        error('No valid subjects with nonzero event counts were found.');
    end

    countMatValid = countMat(validSub, :);
    subIDsValid   = subIDsCell(validSub);
    nValid        = sum(validSub);

    fprintf('Included %d subjects with valid events.\n', nValid);

    %% Compute summary stats (mean, SD, min, max)
    means = mean(countMatValid, 1, 'omitnan');
    sds   = std(countMatValid, 0, 1, 'omitnan');
    mins  = min(countMatValid, [], 1);
    maxs  = max(countMatValid, [], 1);

    % Print summary
    fprintf('\n=== Trial Count Summary (mean ± SD, range) ===\n');
    for e = 1:nEvents
        fprintf('%-20s: %5.2f ± %5.2f (range %d–%d)\n', ...
            prettyLabels{e}, means(e), sds(e), mins(e), maxs(e));
    end

    %% Save numeric summary as CSV
    outTable = table( ...
        eventTypes(:), prettyLabels(:), ...
        means(:), sds(:), mins(:), maxs(:), ...
        'VariableNames', {'event_code', 'label', 'mean', 'sd', 'min', 'max'});

    outCSV = fullfile(scriptDir, 'sharedreward_trial_counts_summary.csv');
    writetable(outTable, outCSV);
    fprintf('\nSaved summary table to: %s\n', outCSV);

    %% Simple bar plot of the six conditions
    figure;
    bar(means);
    set(gca, 'XTick', 1:nEvents, ...
             'XTickLabel', prettyLabels, ...
             'XTickLabelRotation', 45);
    ylabel('Mean number of trials');
    title('Shared-reward trial counts per condition');
    box on;

    % Optionally add SD as error bars:
    hold on;
    errorbar(1:nEvents, means, sds, '.');
    hold off;

    % If you want the per-subject matrix back when calling as a function:
    if nargout > 0
        varargout{1} = struct( ...
            'subIDs', subIDsValid, ...
            'counts', countMatValid, ...
            'eventTypes', {eventTypes}, ...
            'prettyLabels', {prettyLabels});
    end
end
