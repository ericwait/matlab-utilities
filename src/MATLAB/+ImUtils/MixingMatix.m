function MixingMatix(im)
%figure

n_chans = size(im,4);
for i=1:n_chans-1
    for j=i+1:n_chans
        %subplot(n_chans, n_chans, (j * n_chans) + i -1)
        figure
        im_1 = im(:,:,:,i,:);
        im_2 = im(:,:,:,j,:);
        thresh_1 = multithresh(im_1(:), 2);
        thresh_2 = multithresh(im_2(:), 2);
        im_bw = im_1(:)>thresh_1(1) & im_2(:)>thresh_2(1);

        im_1 = im_1(im_bw);
        im_2 = im_2(im_bw);
        Utils.TwoComponentHistogram(im_1, im_2,...
            independent_label=sprintf('chan:%d',i), dependent_label=sprintf('chan:%d',j));
    end
end
