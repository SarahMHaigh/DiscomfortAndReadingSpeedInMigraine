clearvars;
clc
Screen('Preference', 'SkipSyncTests', 0);

ID = input('Enter subject ID:','s'); %input must be string
HideCursor;	% Hide the mouse cursor

[windowPr,rect] = Screen('OpenWindow',0,0,[]);
width=rect(RectRight)-rect(RectLeft);
height=rect(RectBottom)-rect(RectTop);

white = WhiteIndex(windowPr);
black = BlackIndex(windowPr);
gray = 97; 
[xCenter, yCenter] = RectCenter(rect);

% fixation cross coords
H=width/2; 
H1=width/2-(width/2/70);
H2=width/2+(width/2/70);
V=height/2;
V1=height/2-(width/2/70);
V2=height/2+(width/2/70);
penWidth=2;
textsize=40;
Font='Arial'; Screen('TextSize',windowPr,textsize); Screen('TextFont',windowPr,Font); Screen('TextColor',windowPr,black);

block = 1; 
   
% load images
path = [pwd '\'];

% start the log file for reporting
logFID = fopen([path ID '_log.txt'],'at+');      % open a file as log file for everything (APPEND DATA)

disc = {'P1' 'P2' 'P3' 'P4' 'T1' 'T2' 'T3' 'T4'...
    'Y1' 'Y2' 'Y3' 'Y4'};

CDcol = repmat(disc,1,4);

randselect = CDcol(randperm(length(CDcol)));

Screen('FillRect',windowPr, gray);
DrawFormattedText(windowPr, 'Please focus on central cross', 'center', (rect(4)/8)*2);
DrawFormattedText(windowPr, 'When prompted, rate how uncomfortable the stripes are to look at', 'center', (rect(4)/8)*3);
DrawFormattedText(windowPr, 'Use the number pad on the right of the keyboard', 'center', (rect(4)/8)*4);
DrawFormattedText(windowPr, 'Press any key to continue', 'center', (rect(4)/8)*5);
Screen('Flip', windowPr);
WaitSecs(.1);
KbWait;

Screen('DrawLine', windowPr ,[0 0 0], H1, V, H2, V, penWidth);
Screen('DrawLine', windowPr ,[0 0 0], H, V1, H, V2, penWidth);
Screen('Flip', windowPr);
WaitSecs(.5);

count = 0;
dis = 0;
choice = [];

start = GetSecs;
clearvars keyIsDown secs keyCode deltaSecs naming
   
for k = 1:block
    
    randselect = randselect(randperm(length(randselect)));
    
    startT = GetSecs;

for j = 1:length(randselect)
       
    grating = imresize(imread([path randselect{j} '.jpg']),1.5);
        
        rad = Screen('MakeTexture', windowPr, grating);
        Screen('DrawTextures', windowPr, rad);
        Screen('DrawLine', windowPr ,[0 0 0], H1, V, H2, V, penWidth);
        Screen('DrawLine', windowPr ,[0 0 0], H, V1, H, V2, penWidth);
        DrawFormattedText(windowPr, 'How uncomfortable do you find this pattern?', 'center', (rect(4)/8)*7);
        DrawFormattedText(windowPr, '1=comfortable; 9=uncomfortable', 'center', rect(4)/8*7.5);
        Screen('Flip', windowPr);
        KbWait;
        
        sz = size(choice);
        choice(1,sz(2)+1) = randselect{j}(1);
        choice(2,sz(2)+1) = randselect{j}(2);
        
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        naming = sort(KbName(keyCode))
        if strmatch(naming,'ces')
            Screen('CLoseAll');
            xlswrite([path ID 'ColourDiffERP.xlsx'], choice);
        end

        if isnan(str2double(naming(1)))
            choice(3,sz(2)+1) = str2double(naming(2));
            res = str2double(naming(2));
        elseif isnan(str2double(naming(2)))
            choice(3,sz(2)+1) = str2double(naming(1));
            res = str2double(naming(1));
        else choice(3,sz(2)+1) = NaN; res = NaN;
        end
                
        Screen('FillRect',windowPr, gray);
        Screen('DrawLine', windowPr ,[0 0 0], H1, V, H2, V, penWidth);
        Screen('DrawLine', windowPr ,[0 0 0], H, V1, H, V2, penWidth);
        Screen('Flip', windowPr);
        WaitSecs(2+(rand/2));
        
        clearvars keyIsDown secs keyCode deltaSecs naming
        
        % print to logfile:
        fprintf(logFID,['%s\t%d\t\n']', randselect{j}, res);
        
end

count = 0;
dis = 0;

end

finish = GetSecs-start;

DrawFormattedText(windowPr, 'You have finished', 'center', (rect(4)/8)*3);
DrawFormattedText(windowPr, 'Please find the experimenter', 'center', (rect(4)/8)*4);
Screen('Flip', windowPr);
WaitSecs(2);

xlswrite([path ID 'ColourDiffERP.xlsx'], choice);

Screen('CloseAll');
