function bestK = GapGetBestK(MAX_K, MIN_K, k_b, figureHandle)
    B = size(k_b,3)-1;

    bestK = 0;
    W_k = zeros(1,B+1);
    bMul = sqrt(1.0+1.0/(B));

    expectedWeight = zeros(MAX_K,1);
    obsWeight = zeros(MAX_K,1);
    gaps = zeros(MAX_K,1);
    sigs = zeros(MAX_K,1);

    d = size(k_b,2);
    divisor = (d+2)*(d+3)/(d+1); % scales to the triangular eliptical distribution

    tic
    for k=MIN_K:MAX_K
        for j=1:B+1
            D_r = zeros(1,k);
            curKB = k_b(:,:,j);
            gmModel = fitgmdist(curKB,k,'Replicates',5,'Options',statset('Display','off','MaxIter',100,'TolFun',1e-6));
            W_k(j) = gmModel.NegativeLogLikelihood;
        end

        W_kb = sum(W_k(2:end)) / (B);
        expectedWeight(k) = W_kb;
        obsWeight(k) = W_k(1);

        gaps(k) = W_kb - W_k(1);

        sigma = sum((W_k(2:end)-W_kb).^2);
        sigma = sigma / B;
        sigma = sqrt(sigma);
        sigs(k) = sigma;

        if (k>1 && gaps(k-1)>=gaps(k)-sigma*bMul)
            break
        end

        bestK = k;
    end

    finishTime = toc;

    if (bestK>=MAX_K)
        bestK = MIN_K;
    end

    if (exist('figureHandle','var') && ~isempty(figureHandle))
        axes(figureHandle.CurrentAxes);
        h = subplot(2,5,[3 8]);
        plot(h,expectedWeight,'-g');
        hold(h,'on');
        plot(h,obsWeight,'-r');
        plot(h,bestK,expectedWeight(bestK),'*k');
        plot(h,bestK,obsWeight(bestK),'*k');
        text(bestK,expectedWeight(bestK),num2str(bestK));
        text(bestK,obsWeight(bestK),num2str(bestK));
        legend(h,'W_{kb}','W_k',num2str(expectedWeight(bestK)),num2str(obsWeight(bestK)))
        title(h,'Weights W_{kb} and W_k')
        xlim(h,[0,MAX_K+1])

        h = subplot(2,5,[4 9]);
        plot(h,gaps);
        hold(h,'on');
        plot(h,bestK,gaps(bestK),'*k');
        legend(h,'Gap Stat',num2str(gaps(bestK)));
        xlabel(h,['took:' Utils.PrintTime(finishTime)]);
        xlim(h,[0,MAX_K+1])

        h = subplot(2,5,[5 10]);
        plot(h,sigs);
        hold(h,'on');
        plot(h,bestK,sigs(bestK),'*k');
        legend(h,'Sigma',num2str(sigs(bestK)));
        title(h,'Sigmas');
        xlim(h,[0,MAX_K+1])

        set(figureHandle,'Position',[0 0 1920 1080]);
        drawnow
    end
end
