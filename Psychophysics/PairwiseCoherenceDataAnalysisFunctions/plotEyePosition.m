function Q = plotEyePosition(Q)

    % Pairwise Eye Position
    figure;
    color = colormap(copper(11));
    for ii = 1:Q.numTrials
        if ~isnan(Q.coherences(ii))
            x = 0:length(Q.eyePosition(ii,:))-1;
            y = Q.eyePosition(ii,:)-960;
            plot(x,y,'Color',color(10*abs(Q.coherences(ii))+1,:));
        end
        hold on
    end
    hold off
    title('Pairwise Eye Position');
    xlabel('t (ms)');
    ylabel('x position (px)');

%     % Triple Eye Position
%     figure; 
%     
%     % Converging,+
%     subplot(2,2,1);
%     for ii = 1:Q.numTrials
%         if strcmp(Q.types(ii),'converging') && Q.parities(ii)==1
%             x = 0:length(Q.eyePosition(ii,:))-1;
%             y = Q.eyePosition(ii,:)-960;
%             plot(x,y);
%         end
%         hold on
%     end
%     hold off
%     title('Converging,+')
%     xlabel('t (ms)');
%     ylabel('x position (px)');
% 
%     % Converging,-
%     subplot(2,2,2);
%     for ii = 1:Q.numTrials
%         if strcmp(Q.types(ii),'converging') && Q.parities(ii)==-1
%             x = 0:length(Q.eyePosition(ii,:))-1;
%             y = Q.eyePosition(ii,:)-960;
%             plot(x,y);
%         end
%         hold on
%     end
%     hold off
%     title('Converging,-')
%     xlabel('t (ms)');
%     ylabel('x position (px)');
% 
%     % Diverging,+
%     subplot(2,2,3);
%     for ii = 1:Q.numTrials
%         if strcmp(Q.types(ii),'diverging') && Q.parities(ii)==1
%             x = 0:length(Q.eyePosition(ii,:))-1;
%             y = Q.eyePosition(ii,:)-960;
%             plot(x,y);
%         end
%         hold on
%     end
%     hold off
%     title('Diverging,+')
%     xlabel('t (ms)');
%     ylabel('x position (px)');
% 
%     % Diverging,-
%     subplot(2,2,4);
%     for ii = 1:Q.numTrials
%         if strcmp(Q.types(ii),'diverging') && Q.parities(ii)==-1
%             x = 0:length(Q.eyePosition(ii,:))-1;
%             y = Q.eyePosition(ii,:)-960;
%             plot(x,y);
%         end
%         hold on
%     end
%     hold off
%     title('Diverging,-')
%     xlabel('t (ms)');
%     ylabel('x position (px)');
% 
%     sgtitle('Triple Eye Position');

end