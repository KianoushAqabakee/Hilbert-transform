%%
%         Kianoush Aqabakee   student id : 9512103311
%%
close all;
clear all;
clc;
%% inputs
freq=[8192,26192,17192]; % 8192 5192 13192
for i=1:3
    answer=questdlg('do you have an audio or want to make a new one?','?',...
        'I have one','record new one','I have one');
    if strcmp(answer,'I have one')
        title = '?????';
        dims = [1 35];
        definput = {['input',num2str(i),'.wav']};
        name= inputdlg('enter your audio name : audio.wav for example..'...
            ,title,dims,definput);
        v=audioread(name{1});
        fs=inputdlg('fs=?','',dims,{num2str(freq(i))});
        fs=str2num(fs{1});
    else
        [v,fs]=record_Q(freq(i));
        answer=questdlg('do you want to save your audio','?','Yes','No','Yes');
        if strcmp(answer,'Yes')
            audiowrite(['input',num2str(i),'.wav'],v,fs);
        end
    end
    switch i
        case 1
            signals.main.one=v;
            signals.freq.one=fs;
        case 2
            signals.main.two=v;
            signals.freq.two=fs;
        case 3
            signals.main.three=v;
            signals.freq.three=fs;
    end
end

%%

ss=zeros([max([length(signals.main.one)...
    ,length(signals.main.two),length(signals.main.three)]),1]);
%ss=ss+signals.main.one+signals.main.two+signals.main.three;
ss(1:length(signals.main.one))=...
    ss(1:length(signals.main.one))+signals.main.one;
signals.main.one=ss;

ss=zeros([max([length(signals.main.one)...
    ,length(signals.main.two),length(signals.main.three)]),1]);
ss(1:length(signals.main.two))=...
    ss(1:length(signals.main.two))+signals.main.two;
signals.main.two=ss;

ss=zeros([max([length(signals.main.one)...
    ,length(signals.main.two),length(signals.main.three)]),1]);
%ss(1:length(signals.main.two))=ss(1:length(signals.main.two))+signals.main.two;
ss(1:length(signals.main.three))=...
    ss(1:length(signals.main.three))+signals.main.three;
signals.main.three=ss;


pieces = floor(numel(ss)/64);
i = pieces;
% constructing necessary filters

%OmegaC = pi/2;
OmegaC1=pi/2;
OmegaC2=3*pi/2;
OmegaC3=pi;

n1 = 0:63;

n2 = 0:40;
Alpha = 20;
hAlpha = (1-cos(pi*(n2-Alpha)))./((n2-Alpha)*pi);
h = hAlpha;
h(21) = 0;

m = -32:32;
A = 0.5;
hlp1 = A*sin(pi*m/4)./(pi*m/4);
hlp1=hlp1*0;
hlp1(33) = A;

%VoiceFiltered = conv(Voice, hlp1, 'same');

%p = -128:128;
p = -128:128;

hbp1 = (sin(pi*p/2) - sin(pi*p/4))./(pi*p); hbp1(129) = 0.1;
hbp2 = (sin(3*pi*p/4) - sin(pi*p/2))./(pi*p); hbp2(129) = 0.1;
hbp3 = (sin(pi*p) - sin(3*pi*p/4))./(pi*p); hbp3(129) = 0.1;

%{
hbp1 = (sin((2*pi*signals.freq.one+pi/4*100)*p) - sin((2*pi*signals.freq.one-pi/4*100)*p))./(pi*p); hbp1(129) = 0.1;
hbp2 = (sin((2*pi*signals.freq.two+pi/4*100)*p) - sin((2*pi*signals.freq.two-pi/4*100)*p))./(pi*p); hbp2(129) = 0.1;
hbp3 = (sin((2*pi*signals.freq.three+pi/4*100)*p) - sin((2*pi*signals.freq.three-pi/4*100)*p))./(pi*p); hbp3(129) = 0.1;
%freq(1)
%}

m = -32:32;
A = 1;
hlp = A*sin(pi*m/4)./(pi*m/4);
hlp(33) = A;

while i ~= 0
    % Modulation
    Voice = signals.main.one;
    x = transpose(Voice((pieces...
        - i)*64 + 1: (pieces - i)*64 + 64 ));
    x = conv(x,hlp1,'same');
    x1 = x.*cos(OmegaC1*n1);
    xh = conv(x,h,'same');
    x2 = xh.*sin(OmegaC1*n1);
    y1 = x1 + x2;
    
    Voice = signals.main.two;
    x = transpose(Voice((pieces...
        - i)*64 + 1: (pieces - i)*64 + 64 ));
    x = conv(x,hlp1,'same');
    x1 = x.*cos(OmegaC2*n1);
    xh = conv(x,h,'same');
    x2 = xh.*sin(OmegaC2*n1);
    y2 = x1 + x2;
    
    Voice = signals.main.three;
    x = transpose(Voice((pieces...
        - i)*64 + 1: (pieces - i)*64 + 64 ));
    x = conv(x,hlp1,'same');
    x1 = x.*cos(OmegaC3*n1);
    xh = conv(x,h,'same');
    x2 = xh.*sin(OmegaC3*n1);
    y3 = x1 + x2;
    
    y=y1+y2+y3;
    
    % Demodulation
    Recovy1 = conv(hbp1,y,'same');
    DEMx = Recovy1.*cos(OmegaC1*p);
    Final = conv(hlp,DEMx,'same'); Final(1:64);
    if i == pieces
        RecivedVoice1 = Final;
    else
        RecivedVoice1 = cat(2,RecivedVoice1,Final);
    end
    
    Recovy2 = conv(hbp2,y,'same');
    DEMx = Recovy2.*cos(OmegaC2*p);
    Final = conv(hlp,DEMx,'same'); Final(1:64);
    if i == pieces
        RecivedVoice2 = Final;
    else
        RecivedVoice2 = cat(2,RecivedVoice2,Final);
    end
    
    Recovy3 = conv(hbp3,y,'same');
    DEMx = Recovy3.*cos(OmegaC3*p);
    Final = conv(hlp,DEMx,'same'); Final(1:64);
    if i == pieces
        RecivedVoice3 = Final;
    else
        RecivedVoice3 = cat(2,RecivedVoice3,Final);
    end
    
    i=i-1;
end

audiowrite(['output1.wav'],RecivedVoice1,signals.freq.one);
audiowrite(['output2.wav'],RecivedVoice2,signals.freq.two);
audiowrite(['output3.wav'],RecivedVoice3,signals.freq.three);
%sound(RecivedVoice1,signals.freq.one)
%sound(RecivedVoice2,signals.freq.two)
%sound(RecivedVoice3,signals.freq.three)

figure
plot(abs(fftshift(fft(signals.main.one))))
hold on
plot(abs(fftshift(fft(RecivedVoice1))))
legend('main signal','recovered signal')

figure
plot(abs(fftshift(fft(signals.main.two))))
hold on
plot(abs(fftshift(fft(RecivedVoice2))))
legend('main signal','recovered signal')

figure
plot(abs(fftshift(fft(signals.main.three))))
hold on
plot(abs(fftshift(fft(RecivedVoice3))))
legend('main signal','recovered signal')