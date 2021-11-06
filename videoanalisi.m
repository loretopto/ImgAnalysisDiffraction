%% Read and process a video into MATLAB
% tic
% Setup: create Video Reader and Writer
videoFileReader = VideoReader('diffrazione.mp4','CurrentTime',14);
myVideo = VideoWriter('myFile.avi');

% %Number of frames
% num_frames = videoFileReader.Duration * videoFileReader.FrameRate;

% Setup: create deployable video player
depVideoPlayer = vision.DeployableVideoPlayer;
diffractionDetector = vision.CascadeObjectDetector();

%contatore e stato primo pixel
count = 0;
last_pixelstate1 = 0;

% lastvalue = 1;
% ii = 0;
% jj = 1;

% toc
% time1 = toc;

open(myVideo); 
%ripeto ciclo finché ci sono frame
while hasFrame(videoFileReader)
%     tic
%   read video frame ed analizzo ogni 3 frame 
%     while ii < 1 
        img_frame = readFrame(videoFileReader);
%         ii = ii+1;
%     end
%     ii = 0;
    
%     toc
%     time2 = toc;
%     tic
    
    %crop image
    img_cropped = imcrop(img_frame,[130 300 900 900]);
    
    %turn to gray
    img_gray = rgb2gray(img_cropped);

    %threshold
    typethresh = adaptthresh(img_gray,'ForegroundPolarity','bright','Statistic','gaussian');
    img_threshold = imbinarize(img_gray,typethresh);

    %dilate image
    typeofdilation1 = strel('disk',1,0);        
    img_dilated1 = imdilate(img_threshold,typeofdilation1);

    %erode image
    typeoferode = strel('disk',30,0);
    img_eroded = imerode(img_dilated1,typeoferode);

    %dilate image
    typeofdilation2 = strel('disk',30,0);
    img_dilated2 = imdilate(img_eroded,typeofdilation2);

    %dilate image
    typeofdilation3 = strel('disk',4,0);
    img_dilated3 = imdilate(img_dilated2,typeofdilation3);

    %dilate image
    typeofdilation4 = strel('disk',2,0);
    img_dilated4 = imdilate(img_dilated3,typeofdilation4);

    %dilate image
    typeofdilation5 = strel('disk',1,0);
    img_dilated5 = imdilate(img_dilated4,typeofdilation5);
    
%     toc
%     time3 = toc;
%     tic
    
    %mi segno la posizione dei due pixel che analizzerò
    pixel2 = [445,400];
    pixel1 = [460,400];

%     %Codice modificato rispetto al video, non 100% funzionante ma almeno va
%     pixelstate1 = img_dilated5(pixel1(1),pixel1(2));
%     if ( (pixelstate1 ~= last_pixelstate1) &&  pixelstate1==0 ) || lastvalue == 1
%        lastvalue = 1;
%        if  img_dilated5(pixel2(1),pixel2(2)) ~= pixelstate1
%            count = count + 1;
%            lastvalue = 0;
%        end
%     end
%     last_pixelstate1 = pixelstate1;


    %Codice del video
    pixelstate1 = img_dilated5(pixel1(2),pixel1(1));
    pixelstate2 = img_dilated5(pixel2(2),pixel2(1));
    if (pixelstate1 ~= last_pixelstate1)
       if  pixelstate2 ~= pixelstate1
           count = count + 1;
       else
           count = count - 1;
       end
    end
    last_pixelstate1 = pixelstate1;
%     
%     toc
%     time4 = toc;
%     tic
    
    
    %cambio il tipo di variabile dell'ultima immagine così da poterlo editare
    img_frame = im2uint8(img_dilated5);
    
    %Inserisco testo
    position = [10 10]; 
    box_color = {'red'};
    text_str = ['Counted: ' num2str(count,'%d')];
    img_count = insertText(img_frame,position,text_str,'FontSize',30,'BoxColor',...
    box_color,'BoxOpacity',0.4,'TextColor','white');
    
    %Inserisco punti dei pixel
    img_pixel1 = insertShape(img_count,'circle',[445 400 5],'LineWidth',8);
    img_pixel2 = insertShape(img_pixel1,'circle',[460 400 5],'LineWidth',8);

    %metto testo e pixel nel video modificato
    writeVideo(myVideo, img_pixel2);
    pause(1/videoFileReader.FrameRate);
    
%     depVideoPlayer(img_pixel2);
%     imshow(img_pixel2)

%     toc
%     time5 = toc;

    %tolgo le variabili inutili tranne quelle che mi sevono
%     jj = jj+1;
    clearvars -except pixelstate2 img_dilated5 jj videoFileReader myVideo depVideoPlayer diffractionDetector count pixel1 pixel2 pixelstate1 ...
        last_pixelstate1 ii lastvalue img_pixel2 time1 time2 time3 time4 time5
end
close(myVideo)
%     
%  implay(myVideo)