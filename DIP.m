%%%%%%%%%%Code preapared for project work%%%%%%%%%%
%%%%%%%%%%Author:  %%%%%%%%%%
clc;
close all;
clear all;


%%%%%%%%%%Reference Image%%%%%%%%%%
script2()

function [] = script2()
    PedestrianClicked = false;
    ElderlyDisabledClicked = false;
    redColor = '#B81D13';
    yellowColor = '#EFB700';
    greenColor = '#008450';
    purpleColor = '#A020F0';
    greyColor = '#EEEEEE';
    whiteColor = '#ffffff';
    blackColor = '#000000';

    f = figure('Name','Image Processing', 'Position', [100 100 500 500]);

    matchText = uicontrol(gcf, 'Style','text', 'String', '', 'Position', [100 375 300 100], 'FontSize', 16);
    statusText = uicontrol(gcf, 'Style','text', 'String', '', 'Position', [100 350 300 100], 'FontSize', 15);
    
    TrafficLightBtn = uicontrol(gcf,'Style', 'push','BackgroundColor', greenColor, 'String', 'Traffic','Position', [0 400 100 100], 'FontSize', 16);
    PedestrianLightBtn = uicontrol(gcf,'Style', 'push','BackgroundColor', greyColor, 'String', 'Pedestrian','Position', [400 400 100 100], 'FontSize', 16);
    
    
    PedestrianBtn = uicontrol(gcf,'Style', 'push', 'String', 'Pedestrian Crossing','Position', [0 0 250 50],'CallBack', @PedestrianCallback, 'FontSize', 16);
    ElderlyDisabledBtn = uicontrol(gcf,'Style', 'push', 'String', 'Elderly/Person with disabilities','Position', [250 0 250 50],'CallBack', @ElderlyDisabledCallback, 'FontSize', 16);
    
    
    v = VideoReader('traffic.mpg');
    liveTrafficAxes = axes;
    liveTrafficAxes.Units = 'pixels';
    liveTrafficAxes.Position = [100 70 300 300];

    NVI1 = processImage(imread("base.png"), false);

    while hasFrame(v)
        vidFrame = readFrame(v);
        if PedestrianClicked || ElderlyDisabledClicked
            set(statusText, 'String', 'Processing...');
            w = waitbar(0,'Capturing traffic Image...');
            pause(.5)

            waitbar(.33,w,'Processing Image');
            NVI2 = processImage(vidFrame, true);
            waitbar(.65,w,'Finished Processing Image');
            %%%%%%%%%%Image Matching%%%%%%%%%%
            pause(.5)
            waitbar(.65,w,'Match it with Reference Image');
            match = 0;
            BW1 = im2bw(NVI1);
            BW2 = im2bw(NVI2);
            for p = 1 : 511
                for q = 1 : 511
                    if (BW1(p, q) == BW2(p,q))
                        match = match +1;
                    end
                end
            end
            
            match;
            waitbar(1,w,'Finishing');
            pause(1)
            close(w)

            
            %%%%%%%%%%Output Display%%%%%%%%%%
            disp(match)
            if(match>233000)
                set(matchText, 'String', 'No Traffic...');
                % stop traffic in 2 secs and run Pedestrian walk for 20
                % secs
                stopTraffic(2, 20);
                %disp('Green signal will be displayed for 10 second');
                %disp('Red signal will be displayed for 50 seconds');
            elseif(match>232000 && match <233000)
                set(matchText, 'String', 'Moderate Traffic... ');
                % stop traffic in 10 secs and run Pedestrian walk for 20
                % secs
                stopTraffic(10, 20);
                %disp('Green signal will be displayed for 20 second');
                %disp('Red signal will be displayed for 40 seconds');
            else
                set(matchText, 'String', 'More Traffic...');
                % stop traffic in 20 secs and run Pedestrian walk for 20
                % secs
                stopTraffic(20, 20);
                %disp('Green signal will be displayed for 30 second');
                %disp('Red signal will be displayed for 30 seconds');
            end
            break
        else
            image(vidFrame, 'Parent', liveTrafficAxes);
            liveTrafficAxes.Visible = 'off';
            pause(1/v.FrameRate);
        end

        if ~hasFrame(v)
            v = VideoReader('traffic.mpg');
        end
    end
    
    
    

    function setBtnColor(btn, color)
        set(btn, 'BackgroundColor', color);
        if color == greyColor
            set(btn, 'ForegroundColor', blackColor);
        else
            set(btn, 'ForegroundColor', whiteColor);
        end
    end
    
    function PedestrianCallback(source, event)
        disp('PedestrianCallback')
        PedestrianClicked = true;
        setBtnColor(PedestrianBtn, purpleColor);
        set(PedestrianBtn, 'Enable', 'off');
    end
    
    function ElderlyDisabledCallback(source, event)
        disp('ElderlyDisabledCallback');
        ElderlyDisabledClicked = true;
        setBtnColor(ElderlyDisabledBtn, purpleColor);
        set(ElderlyDisabledBtn, 'Enable', 'off');
    end
    

    function stopTraffic(inSecs, forSecs)
        while inSecs
            set(statusText, 'String', strcat("Traffic stops in ", num2str(inSecs), " secs"));
            pause(1);
            inSecs = inSecs - 1;
        end
        set(statusText, 'String', strcat("Traffic light is yellow"));
        setBtnColor(TrafficLightBtn, yellowColor);
        pause(3)
        set(statusText, 'String', strcat("Traffic stopped now and Pedestrian walk starts for ", num2str(forSecs), " secs"));
        setBtnColor(TrafficLightBtn, redColor);
        pause(3)
        
    
        setBtnColor(PedestrianLightBtn, greenColor);
        while forSecs
            set(statusText, 'String', strcat("Pedestrian walk stops in ", num2str(forSecs), " secs"));
            pause(1);
            forSecs = forSecs - 1;
        end
        setBtnColor(TrafficLightBtn, greenColor);
        setBtnColor(PedestrianLightBtn, redColor);
        set(matchText, 'String', '');
        set(statusText, 'String', 'Traffic is live again.');

        setBtnColor(PedestrianBtn, greyColor);
        set(PedestrianBtn, 'Enable', 'on');
        PedestrianClicked = false;

        setBtnColor(ElderlyDisabledBtn, greyColor);
        set(ElderlyDisabledBtn, 'Enable', 'on');
        ElderlyDisabledClicked = false;

    end
    
    
    function NVI = processImage(RGB, isCapturedImage)
        
        %RGB to Gray Conversion
        I = rgb2gray(RGB);
        ID=im2double(I);
        
        %Image Resizing
        IR = imresize(ID, [512 512]);
        
        %Image Enhancement Power Law Transformation
        c = 2;
        g =0.9;
        for p = 1 : 512
            for q = 1 : 512
                if isCapturedImage
                    IG(p, q) = abs(c * IR(p, q).^ 0.9);  
                else
                    IG(p, q) = c * IR(p, q).^ 0.9;
                end
            end
        end
    %     figure; imshow(IG); title('Enhanced Image');
        
        %Edge Detection
        % The algorithm parameters:
        % 1. Parameters of edge detecting filters:
        %    X-axis direction filter:
             Nx1=10;Sigmax1=1;Nx2=10;Sigmax2=1;Theta1=pi/2;
        %    Y-axis direction filter:
             Ny1=10;Sigmay1=1;Ny2=10;Sigmay2=1;Theta2=0;
        % 2. The thresholding parameter alfa:
             alfa=0.1;
        % Get the initial Reference Image
        % X-axis direction edge detection
        filterx=d2dgauss(Nx1,Sigmax1,Nx2,Sigmax2,Theta1);
        Ix= conv2(IG,filterx,'same');
        
        % Y-axis direction edge detection
        filtery=d2dgauss(Ny1,Sigmay1,Ny2,Sigmay2,Theta2);
        Iy=conv2(IG,filtery,'same'); 
        
        % Norm of the gradient (Combining the X and Y directional derivatives)
        NVI=sqrt(Ix.*Ix+Iy.*Iy);
        
        % Thresholding
        I_max=max(max(NVI));
        I_min=min(min(NVI));
        level=alfa*(I_max-I_min)+I_min;
        Ibw=max(NVI,level.*ones(size(NVI)));
        
        % Thinning (Using interpolation to find the pixels where the norms of 
        % gradient are local maximum.)
        
        [n,m]=size(Ibw);
        for i=2:n-1,
        for j=2:m-1,
	        if Ibw(i,j) > level,
	        X=[-1,0,+1;-1,0,+1;-1,0,+1];
	        Y=[-1,-1,-1;0,0,0;+1,+1,+1];
	        Z=[Ibw(i-1,j-1),Ibw(i-1,j),Ibw(i-1,j+1);
	           Ibw(i,j-1),Ibw(i,j),Ibw(i,j+1);
	           Ibw(i+1,j-1),Ibw(i+1,j),Ibw(i+1,j+1)];
	        XI=[Ix(i,j)/NVI(i,j), -Ix(i,j)/NVI(i,j)];
	        YI=[Iy(i,j)/NVI(i,j), -Iy(i,j)/NVI(i,j)];
	        ZI=interp2(X,Y,Z,XI,YI);
		        if Ibw(i,j) >= ZI(1) & Ibw(i,j) >= ZI(2)
		        I_temp(i,j)=I_max;
		        else
		        I_temp(i,j)=I_min;
		        end
	        else
	        I_temp(i,j)=I_min;
	        end
        end
        end
        if isCapturedImage
            figure;
            subplot(5,2,[1,4]);
            imagesc(RGB);
            title('Original Image:');
            
            subplot(5,2,5);
            imagesc(IG);
            title('Enhanced Image:');

            subplot(5,2,6);
            imagesc(Ix);
            title('Ix');

            subplot(5,2,7);
            imagesc(Iy);
            title('Iy');

            subplot(5,2,8);
            imagesc(NVI);
            title('Norm of Gradient');

            subplot(5,2,9);
            imagesc(Ibw);
            title('After Thresholding');

            subplot(5,2,10);
            imagesc(I_temp);
            title('After Thinning');
        end
        colormap(gray);
    end
end

