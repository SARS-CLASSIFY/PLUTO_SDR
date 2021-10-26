clear

%% �������ü���ʼ��
txPluto = sdrtx('Pluto',...                                      %���÷��Ͷ�
        'RadioID','usb:0',...
        'CenterFrequency',92.4e6,...
        'Gain',-0,...
        'ChannelMapping',1,...
        'BasebandSampleRate',614400,...
        'ShowAdvancedProperties',true);
%info(txPluto)

afr=dsp.AudioFileReader('Scarborough Fair.flac',...     %������Ƶ����
        'OutputDataType','double',...
        'SamplesPerFrame',44100);

mod=comm.FMBroadcastModulator(...                   %����FM����
        'AudioSampleRate',afr.SampleRate, ...
        'SampleRate',txPluto.BasebandSampleRate, ...
        'Stereo',true);
               
scope = dsp.TimeScope('SampleRate', txPluto.BasebandSampleRate,...%��ʼ��ʾ����
        'YLimits', 10^-2*[-1 1]);

%% ʱ���Ƶ�����
audio_data = step(afr);             %ԭʼ�����ź�,ȡһ֡������
%size(audio_data)
figure(1);
subplot(221);
%scope(audio_data);
plot(audio_data(:, 1));                 %ȡ������
%plot(audio_data);                    %˫��������
title('s(t)��ԭʼ�����ź�ʱ����');
xlabel('t/s');
legend('s(t)');

y1=fft(audio_data(:, 1),44100);       %���ź���44100��FFT�任
f=afr.SampleRate*(1:1024)/44100;
subplot(222)
bar(f,abs(y1(1:1024)),1,'g')          %��ԭʼ�����źŵ�FFTƵ��ͼ
xlim([0, 20000]);
ylim([0, 1]);
title('s(t)_f��ԭʼ�����ź�Ƶ����');
xlabel('f/Hz');
legend('S(f)');

mod_audio_data = mod(afr());    %���������ź�
mod_audio_data = real(mod_audio_data);
%size(mod_audio_data);
subplot(223);
t = 1: 44100;
%scope(mod_audio_data);
plot(t', mod_audio_data(1:44100));
title('y(t)�����������ź�ʱ����');
xlabel('t/s');
legend('y(t)');


y2=fft(mod(audio_data),614400);    %���ź���61400��FFT�任
f=afr.SampleRate*(1:307200)/614400;
subplot(224);
%semilogy(abs(y2(1:307200)),1,'g');
bar(f,abs(y2(1:307200)),1,'g')          %�����������źŵ�FFTƵ��ͼ
ylim([0, 1000]);
title('y(t)_f�����������ź�Ƶ����');
xlabel('f/Hz');
legend('Y(f)');

%% ʵʱƵ�׷���
% [data, Fs]=audioread('����֮��.mp3','native');
% data=audioread('Scarborough Fair.flac','native');
% plot(data(:, 2));
% 
% audio = dsp.AudioFileReader('Scarborough Fair.flac','SamplesPerFrame',44100);
% fmbMod = comm.FMBroadcastModulator('AudioSampleRate',audio.SampleRate, ...
%     'SampleRate',240e3);
% groupLen = 104;
% sps = 10;
% groupsPerFrame = 19;
% rbdsFrameLen = groupLen*sps*groupsPerFrame;
% afrRate = 40*1187.5;
% rbdsRate = 1187.5*sps;
% outRate = 4*57000;
% 
% afr = dsp.AudioFileReader('rbds_capture_47500.wav','SamplesPerFrame',rbdsFrameLen*afrRate/rbdsRate);
% rbds = comm.RBDSWaveformGenerator('GroupsPerFrame',groupsPerFrame,'SamplesPerSymbol',sps);
% 
% fmMod = comm.FMBroadcastModulator('AudioSampleRate',afr.SampleRate,'SampleRate',outRate,...
%     'Stereo',true,'RBDS',true,'RBDSSamplesPerSymbol',sps);
% 
% [y,fs]=audioread('Scarborough Fair.flac');
% y=resample(y,3*fs,fs);
% 
% function aa= recorder(cf,handles)
% %RECORDER Summary of this function goes here
% % Detailed explanation goes here
% % h=figure(soundrec);
% 
% h=cf;
% thehandles=handles;
% setappdata(h,'isrecording',1);
% 
% Ai=analoginput('winsound'); % ����һ��ģ���ź��������
% % ���ͨ��
% addchannel(Ai,1);
% Ai.SampleRate=48000; % ����Ƶ��
% Ai.SamplesPerTrigger=Inf; % ������
% 
% start(Ai); % ��������
% warning off % ���������ݲ���ʱ��ȡ������
% while isrunning(Ai) % �������Ƿ���������
%     if getappdata(h,'isrecording')
%         data=peekdata(Ai,Ai.SampleRate);% ��ȡ�����е����Ai.SampleRate����������
%         plot(thehandles.axes1,data) % �������Ai.SampleRate���������ݵ�ͼ�Σ���˱��ֳ�������ʵʱ����
%         set(handles.axes1,'ylim',[-1 1],'xlim',[0 Ai.SampleRate]);
%         y1=fft(data,2048); %���ź���2048��FFT�任
%         f=Ai.SampleRate*(0:1023)/2048;
%         bar(handles.axes2,f,abs(y1(1:1024)),0.8,'g') %��ԭʼ�����źŵ�FFTƵ��ͼ
%         set(handles.axes2,'ylim',[0 10],'xlim',[0 20000]);%����handles.axes2�ĺ������귶Χ
%         drawnow; % ˢ��ͼ��
%     else
%         stop(Ai);
%         num=get(Ai,'SamplesAvailable');
%         aa=getdata(Ai,num);
%         axes(thehandles.axes1);
%         plot(thehandles.axes1,aa) % �������в������ݵ�ͼ��
% 
%         y1=fft(data,2048); %���ź���2048��FFT�任
%         f=Ai.SampleRate*(0:1023)/2048;
%         bar(handles.axes2,f,abs(y1(1:1024)),0.8,'g') %��ԭʼ�����źŵ�FFTƵ��ͼ
%         %set(handles.axes2,'ylim',[0 10],'xlim',[0 20000]);%����handles.axes2�ĺ������귶Χ
%         drawnow; % ˢ��ͼ��
%         setappdata(h,'sounds',aa);
%     end
% end

%% �ź�д���뷢��
adw = audioDeviceWriter('SampleRate', afr.SampleRate);% Number of samples per second sent to device
%info(adw)

if ~isempty(findPlutoRadio)
        while ~isDone(afr)
            data = afr();
            adw(data);                         %��������
            underflow=txPluto(mod(data));
        end
        disp('Finish sending. Enjoy please.');
else
        warning('PlutoRadioNotFound')
end
