classdef CoinDetectionApp < handle

    properties (Access = private)
        Fig
        List
        BtnLoad
        BtnProcOne
        BtnProcAll
        BtnExport
        TabBtns
        Ax
        InfoLbl
        StatusLbl
        BigNumLbl
        ThreshLbl
        FileLbl
        Files
        ImgData
        CoinCount
        ThreshVal
        ActiveTab
    end

    methods
        function app = CoinDetectionApp()
            app.ActiveTab = 1;
            app.Files     = {};
            app.ImgData   = {};
            app.CoinCount = [];
            app.ThreshVal = [];
            app.buildUI();
        end
    end

    methods (Access = private)

        function buildUI(app)
            scr = get(0,'ScreenSize');
            fw  = min(1280, scr(3)-60);
            fh  = min(780,  scr(4)-80);

            app.Fig = uifigure('Name','Coin Detection & Counting System', ...
                'Position',[40 40 fw fh], ...
                'Color',[0.12 0.13 0.15], ...
                'Resize','off');

            SW = 230;

            sb = uipanel(app.Fig, ...
                'Position',[0 0 SW fh], ...
                'BackgroundColor',[0.16 0.17 0.20], ...
                'BorderType','none');

            uilabel(sb,'Text','COIN DETECT', ...
                'Position',[10 fh-50 SW-20 34], ...
                'FontSize',16,'FontWeight','bold', ...
                'FontColor',[0.20 0.60 1.00], ...
                'HorizontalAlignment','center', ...
                'BackgroundColor',[0.16 0.17 0.20]);

            uilabel(sb,'Text','Image Processing Suite', ...
                'Position',[10 fh-68 SW-20 18], ...
                'FontSize',8,'FontColor',[0.52 0.57 0.65], ...
                'HorizontalAlignment','center', ...
                'BackgroundColor',[0.16 0.17 0.20]);

            uipanel(sb,'Position',[10 fh-72 SW-20 2], ...
                'BackgroundColor',[0.26 0.29 0.35],'BorderType','none');

            app.BtnLoad = uibutton(sb,'Text','Load Images', ...
                'Position',[14 fh-110 SW-28 32], ...
                'FontSize',10,'FontWeight','bold', ...
                'FontColor',[0.12 0.13 0.15], ...
                'BackgroundColor',[0.20 0.60 1.00], ...
                'ButtonPushedFcn',@(~,~) app.cbLoad());

            uilabel(sb,'Text','LOADED IMAGES', ...
                'Position',[14 fh-130 SW-28 16], ...
                'FontSize',7,'FontWeight','bold', ...
                'FontColor',[0.52 0.57 0.65], ...
                'HorizontalAlignment','left', ...
                'BackgroundColor',[0.16 0.17 0.20]);

            app.List = uilistbox(sb, ...
                'Items',{}, ...
                'Position',[14 fh-312 SW-28 180], ...
                'FontSize',9, ...
                'FontColor',[0.94 0.95 0.97], ...
                'BackgroundColor',[0.20 0.22 0.26], ...
                'ValueChangedFcn',@(~,~) app.cbSelectImg());

            uilabel(sb,'Text','PROCESSING', ...
                'Position',[14 fh-330 SW-28 16], ...
                'FontSize',7,'FontWeight','bold', ...
                'FontColor',[0.52 0.57 0.65], ...
                'HorizontalAlignment','left', ...
                'BackgroundColor',[0.16 0.17 0.20]);

            app.BtnProcOne = uibutton(sb,'Text','Process Selected', ...
                'Position',[14 fh-368 SW-28 30], ...
                'FontSize',9,'FontWeight','bold', ...
                'FontColor',[0.12 0.13 0.15], ...
                'BackgroundColor',[0.18 0.78 0.45], ...
                'ButtonPushedFcn',@(~,~) app.cbProcOne());

            app.BtnProcAll = uibutton(sb,'Text','Process All Images', ...
                'Position',[14 fh-406 SW-28 30], ...
                'FontSize',9,'FontWeight','bold', ...
                'FontColor',[0.12 0.13 0.15], ...
                'BackgroundColor',[1.00 0.76 0.10], ...
                'ButtonPushedFcn',@(~,~) app.cbProcAll());

            uipanel(sb,'Position',[10 fh-415 SW-20 2], ...
                'BackgroundColor',[0.26 0.29 0.35],'BorderType','none');

            uilabel(sb,'Text','RESULTS', ...
                'Position',[14 fh-433 SW-28 16], ...
                'FontSize',7,'FontWeight','bold', ...
                'FontColor',[0.52 0.57 0.65], ...
                'HorizontalAlignment','left', ...
                'BackgroundColor',[0.16 0.17 0.20]);

            rc = uipanel(sb,'Position',[12 fh-572 SW-24 132], ...
                'BackgroundColor',[0.20 0.22 0.26], ...
                'BorderType','line','HighlightColor',[0.26 0.29 0.35]);

            app.BigNumLbl = uilabel(rc,'Text','--', ...
                'Position',[5 86 SW-44 38], ...
                'FontSize',34,'FontWeight','bold', ...
                'FontColor',[0.20 0.60 1.00], ...
                'HorizontalAlignment','center', ...
                'BackgroundColor',[0.20 0.22 0.26]);

            uilabel(rc,'Text','Coins Detected', ...
                'Position',[5 66 SW-44 18], ...
                'FontSize',8,'FontColor',[0.52 0.57 0.65], ...
                'HorizontalAlignment','center', ...
                'BackgroundColor',[0.20 0.22 0.26]);

            app.ThreshLbl = uilabel(rc,'Text','Threshold: --', ...
                'Position',[5 44 SW-44 18], ...
                'FontSize',8,'FontColor',[0.94 0.95 0.97], ...
                'HorizontalAlignment','center', ...
                'BackgroundColor',[0.20 0.22 0.26]);

            app.FileLbl = uilabel(rc,'Text','File: --', ...
                'Position',[5 24 SW-44 18], ...
                'FontSize',7.5,'FontColor',[0.52 0.57 0.65], ...
                'HorizontalAlignment','center', ...
                'BackgroundColor',[0.20 0.22 0.26]);

            app.BtnExport = uibutton(sb,'Text','Export Results (CSV)', ...
                'Position',[14 70 SW-28 28], ...
                'FontSize',8.5,'FontWeight','bold', ...
                'FontColor',[0.94 0.95 0.97], ...
                'BackgroundColor',[0.26 0.29 0.35], ...
                'ButtonPushedFcn',@(~,~) app.cbExport());

            app.StatusLbl = uilabel(sb, ...
                'Text','Ready  --  load images to begin.', ...
                'Position',[6 8 SW-12 54], ...
                'FontSize',7.5,'FontColor',[0.18 0.78 0.45], ...
                'HorizontalAlignment','center','WordWrap','on', ...
                'BackgroundColor',[0.16 0.17 0.20]);

            RX = SW + 6;
            RW = fw - RX - 4;
            rp = uipanel(app.Fig,'Position',[RX 0 RW fh], ...
                'BackgroundColor',[0.12 0.13 0.15],'BorderType','none');

            tabLabels  = {'Original','Grayscale','Preprocessed','Threshold','Edges','Watershed'};
            tabColours = {[0.45 0.45 0.47],[0.52 0.57 0.65], ...
                          [0.20 0.60 1.00],[0.18 0.78 0.45], ...
                          [1.00 0.76 0.10],[0.90 0.28 0.22]};
            btnH = 28;
            btnW = floor((RW-14)/6);
            app.TabBtns = gobjects(1,6);
            for k = 1:6
                app.TabBtns(k) = uibutton(rp,'Text',tabLabels{k}, ...
                    'Position',[6+(k-1)*btnW  fh-btnH-4  btnW-4  btnH], ...
                    'FontSize',8,'FontWeight','bold', ...
                    'FontColor',[0.12 0.13 0.15], ...
                    'BackgroundColor',tabColours{k}, ...
                    'ButtonPushedFcn',@(~,~) app.cbTab(k));
            end

            app.InfoLbl = uilabel(rp, ...
                'Text','Select an image and press Process', ...
                'Position',[6 fh-btnH-30 RW-12 20], ...
                'FontSize',8,'FontColor',[0.52 0.57 0.65], ...
                'HorizontalAlignment','left', ...
                'BackgroundColor',[0.12 0.13 0.15]);

            axH = fh - btnH - 36;
            app.Ax = uiaxes(rp,'Position',[6 4 RW-12 axH], ...
                'Color',[0.12 0.13 0.15], ...
                'XColor',[0.26 0.29 0.35], ...
                'YColor',[0.26 0.29 0.35], ...
                'BackgroundColor',[0.12 0.13 0.15]);
            axis(app.Ax,'off');
            text(app.Ax,0.5,0.5,'Load and process an image to view results', ...
                'Units','normalized','HorizontalAlignment','center', ...
                'VerticalAlignment','middle','Color',[0.52 0.57 0.65],'FontSize',11);
        end

        function cbLoad(app)
            [fnames,fpath] = uigetfile( ...
                {'*.jpg;*.jpeg;*.png;*.bmp;*.tif;*.tiff','Image Files'}, ...
                'Select Coin Images','MultiSelect','on');
            if isequal(fnames,0), return; end
            if ischar(fnames), fnames = {fnames}; end
            n             = numel(fnames);
            app.Files     = cellfun(@(f) fullfile(fpath,f), fnames, 'UniformOutput',false);
            app.ImgData   = cell(n,1);
            app.CoinCount = zeros(n,1);
            app.ThreshVal = zeros(n,1);
            app.List.Items = fnames;
            app.List.Value = fnames{1};
            app.setStatus(sprintf('%d image(s) loaded. Press Process.',n),[0.18 0.78 0.45]);
        end

        function cbProcOne(app)
            if isempty(app.Files)
                app.setStatus('No images loaded!',[0.90 0.28 0.22]); return;
            end
            idx = find(strcmp(app.List.Items, app.List.Value),1);
            app.setStatus(sprintf('Processing %d of %d ...',idx,numel(app.Files)),[1.00 0.76 0.10]);
            drawnow;
            app.runPipeline(idx);
            app.showResult(idx);
            app.setStatus(sprintf('Done -- Coins = %d',app.CoinCount(idx)),[0.18 0.78 0.45]);
        end

        function cbProcAll(app)
            if isempty(app.Files)
                app.setStatus('No images loaded!',[0.90 0.28 0.22]); return;
            end
            for i = 1:numel(app.Files)
                app.setStatus(sprintf('Processing %d / %d ...',i,numel(app.Files)),[1.00 0.76 0.10]);
                drawnow;
                app.runPipeline(i);
            end
            idx = find(strcmp(app.List.Items, app.List.Value),1);
            app.showResult(idx);
            app.setStatus(sprintf('All %d images processed.',numel(app.Files)),[0.18 0.78 0.45]);
        end

        function cbSelectImg(app)
            if isempty(app.Files), return; end
            idx = find(strcmp(app.List.Items, app.List.Value),1);
            if ~isempty(idx) && ~isempty(app.ImgData{idx})
                app.showResult(idx);
            end
        end

        function cbTab(app,t)
            app.ActiveTab = t;
            if isempty(app.Files), return; end
            idx = find(strcmp(app.List.Items, app.List.Value),1);
            if ~isempty(idx) && ~isempty(app.ImgData{idx})
                app.showResult(idx);
            end
        end

        function cbExport(app)
            if isempty(app.Files)
                app.setStatus('Nothing to export.',[0.90 0.28 0.22]); return;
            end
            [fn,fp] = uiputfile('*.csv','Save Results As','coin_results.csv');
            if isequal(fn,0), return; end
            fid = fopen(fullfile(fp,fn),'w');
            fprintf(fid,'Image,Coins Detected,Otsu Threshold\n');
            for i = 1:numel(app.Files)
                [~,nm,ext] = fileparts(app.Files{i});
                fprintf(fid,'%s%s,%d,%d\n',nm,ext,app.CoinCount(i),app.ThreshVal(i));
            end
            fclose(fid);
            app.setStatus(['Exported: ' fn],[0.18 0.78 0.45]);
        end

        function runPipeline(app, idx)
            img = imread(app.Files{idx});
            img = imresize(img,[400 600]);

            gray = rgb2gray(img);
            kernel = ones(3,3)/9;
            filtered = conv2(double(gray),kernel,'same');
            filtered = uint8(filtered);

            minVal = double(min(filtered(:)));
            maxVal = double(max(filtered(:)));
            enhanced = uint8(255 * ((double(filtered)-minVal) / (maxVal-minVal)));

            histCounts = zeros(1,256);
            for p = 0:255
                histCounts(p+1) = sum(sum(enhanced == p));
            end
            totalPixels = numel(enhanced);
            prob = histCounts / totalPixels;
            bestThreshold = 0;
            bestVariance = 0;
            for t = 1:254
                w0 = sum(prob(1:t));
                w1 = sum(prob(t+1:end));
                if w0 == 0 || w1 == 0
                    continue;
                end
                mu0 = sum((0:t-1) .* prob(1:t)) / w0;
                mu1 = sum((t:255) .* prob(t+1:end)) / w1;
                betweenVar = w0 * w1 * (mu0 - mu1)^2;
                if betweenVar > bestVariance
                    bestVariance = betweenVar;
                    bestThreshold = t;
                end
            end

            binary1 = double(enhanced > bestThreshold);
            binary2 = double(enhanced < bestThreshold);
            count1 = sum(binary1(:));
            count2 = sum(binary2(:));
            if count1 < count2
                binaryImage = binary1;
            else
                binaryImage = binary2;
            end

            binaryImage = bwareaopen(binaryImage,500);
            binaryImage = imfill(binaryImage,'holes');
            binaryImage = imclearborder(binaryImage);

            smoothed = uint8(conv2(double(enhanced),ones(5,5)/25,'same'));
            sobelX = [-1 0 1; -2 0 2; -1 0 1];
            sobelY = [-1 -2 -1; 0 0 0; 1 2 1];
            Gx = conv2(double(smoothed),sobelX,'same');
            Gy = conv2(double(smoothed),sobelY,'same');
            edgeMagnitude = sqrt(Gx.^2 + Gy.^2);
            edges = edgeMagnitude > 180;

            D = bwdist(~binaryImage);
            D = -D;
            D = imhmin(D,2);
            L = watershed(D);
            L(~binaryImage) = 0;
            watershedRGB = label2rgb(L,@jet,'k','shuffle');

            [rows,cols] = size(binaryImage);
            visited = zeros(rows,cols);
            numCoins = 0;
            minArea = 5000;
            for i = 1:rows
                for j = 1:cols
                    if binaryImage(i,j)==1 && visited(i,j)==0
                        queue = [i j];
                        visited(i,j) = 1;
                        area = 0;
                        while ~isempty(queue)
                            x = queue(1,1);
                            y = queue(1,2);
                            queue(1,:) = [];
                            area = area + 1;
                            directions = [-1 0;1 0;0 -1;0 1;-1 -1;-1 1;1 -1;1 1];
                            for d = 1:8
                                nx = x + directions(d,1);
                                ny = y + directions(d,2);
                                if nx>=1 && nx<=rows && ny>=1 && ny<=cols
                                    if binaryImage(nx,ny)==1 && visited(nx,ny)==0
                                        visited(nx,ny) = 1;
                                        queue = [queue; nx ny];
                                    end
                                end
                            end
                        end
                        if area > minArea
                            numCoins = numCoins + 1;
                        end
                    end
                end
            end

            app.ImgData{idx}   = {img, gray, enhanced, binaryImage, edges, watershedRGB};
            app.CoinCount(idx) = numCoins;
            app.ThreshVal(idx) = bestThreshold;
        end

        function showResult(app, idx)
            if isempty(app.ImgData{idx}), return; end
            tNames = {'Original','Grayscale','Preprocessed','Threshold','Edges','Watershed'};
            titles = {'Original Image', 'Grayscale Image', ...
                'Preprocessed Image', ...
                ['Threshold Result T = ' num2str(app.ThreshVal(idx))], ...
                'Sobel Edge Detection', ...
                ['Coins = ' num2str(app.CoinCount(idx))]};
            t = app.ActiveTab;
            cla(app.Ax);
            imshow(app.ImgData{idx}{t},'Parent',app.Ax);
            title(app.Ax,titles{t}, ...
                'Color',[0.94 0.95 0.97],'FontSize',10,'FontWeight','bold');
            axis(app.Ax,'off');
            [~,nm,ext] = fileparts(app.Files{idx});
            app.InfoLbl.Text = sprintf( ...
                'File: %s%s   |   Coins: %d   |   Threshold: %d   |   View: %s', ...
                nm,ext,app.CoinCount(idx),app.ThreshVal(idx),tNames{t});
            app.BigNumLbl.Text = num2str(app.CoinCount(idx));
            app.ThreshLbl.Text = ['Threshold: ' num2str(app.ThreshVal(idx))];
            app.FileLbl.Text   = ['File: ' nm ext];
        end

        function setStatus(app, msg, col)
            app.StatusLbl.Text      = msg;
            app.StatusLbl.FontColor = col;
            drawnow;
        end

    end
end