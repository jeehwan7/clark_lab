function Q = createTrialMeanEyeVelocity(Q, start, finish, nanThreshold)

    % Pairwise Coherence

    % pairwise coherence Trial Number
    pcTrialNumber = NaN(length(Q.types(strcmp(Q.types,'pairwise'))),1);
    % pairwise coherence Coherence
    pcCoherence = NaN(length(Q.types(strcmp(Q.types,'pairwise'))),1);   
    % pairwise coherence Mean Velocity
    pcMean = NaN(length(Q.types(strcmp(Q.types,'pairwise'))),1);
    % pairwise coherence Response
    pcResponse = NaN(length(Q.types(strcmp(Q.types,'pairwise'))),1);
    % pairwise coherence NaN Frequency
    pcNaNFrequency = NaN(length(Q.types(strcmp(Q.types,'pairwise'))),1);

    % Triple

    % triple Trial Number
    tTrialNumber = NaN(Q.numTrials-length(Q.types(strcmp(Q.types,'pairwise'))),1);
    % triple Type
    tType = strings(Q.numTrials-length(Q.types(strcmp(Q.types,'pairwise'))),1);
    % triple Mean Velocity
    tMean = NaN(Q.numTrials-length(Q.types(strcmp(Q.types,'pairwise'))),1);
    % triple Response
    tResponse = NaN(Q.numTrials-length(Q.types(strcmp(Q.types,'pairwise'))),1);
    % triple NaN Frequency
    tNaNFrequency = NaN(Q.numTrials-length(Q.types(strcmp(Q.types,'pairwise'))),1);

    jj = 1;
    kk = 1;
    for ii = 1:Q.numTrials
        % if sum(isnan(Q.eyeVelocityWithoutSaccades(ii,start:finish)))/length(start:finish)<nanThreshold
            if strcmp(Q.types(ii),'pairwise')
                pcTrialNumber(jj) = ii;
                pcCoherence(jj) = Q.symmetrizedCoherences(ii);
                pcMean(jj) = mean(Q.eyeVelocityWithoutSaccades(ii,start:finish),'omitnan'); % NOT SYMMETRIZED BECAUSE PAIRWISE
                pcResponse(jj) = Q.responses(ii); % NOT SYMMETRIZED BECAUSE PAIRWISE
                pcNaNFrequency(jj) = sum(isnan(Q.eyeVelocityWithoutSaccades(ii,start:finish)))/length(start:finish);
                jj = jj+1;
            else
                tTrialNumber(kk) = ii;
                tMean(kk) = mean(Q.symmetrizedEyeVelocityWithoutSaccades(ii,start:finish),'omitnan'); % SYMMETRIZED BECAUSE TRIPLE
                tResponse(kk) = Q.symmetrizedResponses(ii); % SYMMETRIZED BECAUSE TRIPLE
                tNaNFrequency(kk) = sum(isnan(Q.eyeVelocityWithoutSaccades(ii,start:finish)))/length(start:finish);
                if strcmp(Q.types(ii),'converging')
                    if Q.parities(ii) == 1
                        tType(kk) = 'con,+';
                    elseif Q.parities(ii) == -1
                        tType(kk) = 'con,-';
                    end
                elseif strcmp(Q.types(ii),'diverging')
                    if Q.parities(ii) == 1
                        tType(kk) = 'div,+';
                    elseif Q.parities(ii) == -1
                        tType(kk) = 'div,-';
                    end
                end
                kk = kk+1;
            end
        % end
    end

    % Pairwise Coherence Table
    size = [length(Q.types(strcmp(Q.types,'pairwise'))),5];
    varTypes = {'double','double','double','double','double'};
    varNames = {'Trial Number','Coherence','Mean Eye Velocity','Response','NaN Frequency'};
    pcTable = table('Size',size,'VariableTypes',varTypes,'VariableNames',varNames);

    pcTable(:,1) = num2cell(pcTrialNumber);
    pcTable(:,2) = num2cell(pcCoherence);
    pcTable(:,3) = num2cell(pcMean);
    pcTable(:,4) = num2cell(pcResponse);
    pcTable(:,5) = num2cell(pcNaNFrequency);

    % Triple Table
    size = [Q.numTrials-length(Q.types(strcmp(Q.types,'pairwise'))),5];
    varTypes = {'double','string','double','double','double'};
    varNames = {'Trial Number','Type','Mean Eye Velocity','Response','NaN Frequency'};
    tTable = table('Size',size,'VariableTypes',varTypes,'VariableNames',varNames);

    tTable(:,1) = num2cell(tTrialNumber);
    tTable(:,2) = cellstr(tType);
    tTable(:,3) = num2cell(tMean);
    tTable(:,4) = num2cell(tResponse);
    tTable(:,5) = num2cell(tNaNFrequency);

    Q.trialMeanEyeVelocityPairwiseCoherence = pcTable;
    Q.trialMeanEyeVelocityTriple = tTable;

    Q.trialMeanEyeVelocityPairwiseCoherenceNaNLimit = pcTable(pcTable.("NaN Frequency")<nanThreshold,:);
    Q.trialMeanEyeVelocityTripleNaNLimit = tTable(tTable.("NaN Frequency")<nanThreshold,:);

end
