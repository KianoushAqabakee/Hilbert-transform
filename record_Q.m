function [v,fs]=record_Q(fs)

%fs = 8192;
bits = 16;
recObj = audiorecorder(fs, bits, 1);

disp('Start speaking.')
recordblocking(recObj, 4);
disp('End of Recording.');
v = getaudiodata(recObj);
end
