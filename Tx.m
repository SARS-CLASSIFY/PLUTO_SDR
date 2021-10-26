clear

%% 参数配置及初始化
txPluto = sdrtx('Pluto',...                                      %配置发送端
        'RadioID','usb:0',...
        'CenterFrequency',92.4e6,...
        'Gain',-0,...
        'ChannelMapping',1,...
        'BasebandSampleRate',614400,...
        'ShowAdvancedProperties',true);
%info(txPluto)

afr=dsp.AudioFileReader('Scarborough Fair.flac',...     %配置音频读入
        'OutputDataType','double',...
        'SamplesPerFrame',44100);

mod=comm.FMBroadcastModulator(...                   %配置FM调制
        'AudioSampleRate',afr.SampleRate, ...
        'SampleRate',txPluto.BasebandSampleRate, ...
        'Stereo',true);
               
scope = dsp.TimeScope('SampleRate', txPluto.BasebandSampleRate,...%初始化示波器
        'YLimits', 10^-2*[-1 1]);

%% 时域和频域分析
audio_data = step(afr);             %原始语音信号,取一帧立体声
%size(audio_data)
figure(1);
subplot(221);
%scope(audio_data);
plot(audio_data(:, 1));                 %取左声道
%plot(audio_data);                    %双声道波形
title('s(t)：原始语音信号时域波形');
xlabel('t/s');
legend('s(t)');

y1=fft(audio_data(:, 1),44100);       %对信号做44100点FFT变换
f=afr.SampleRate*(1:1024)/44100;
subplot(222)
bar(f,abs(y1(1:1024)),1,'g')          %做原始语音信号的FFT频谱图
xlim([0, 20000]);
ylim([0, 1]);
title('s(t)_f：原始语音信号频域波形');
xlabel('f/Hz');
legend('S(f)');

mod_audio_data = mod(afr());    %调制语音信号
mod_audio_data = real(mod_audio_data);
%size(mod_audio_data);
subplot(223);
t = 1: 44100;
%scope(mod_audio_data);
plot(t', mod_audio_data(1:44100));
title('y(t)：调制语音信号时域波形');
xlabel('t/s');
legend('y(t)');


y2=fft(mod(audio_data),614400);    %对信号做61400点FFT变换
f=afr.SampleRate*(1:307200)/614400;
subplot(224);
%semilogy(abs(y2(1:307200)),1,'g');
bar(f,abs(y2(1:307200)),1,'g')          %做调制语音信号的FFT频谱图
ylim([0, 1000]);
title('y(t)_f：调制语音信号频域波形');
xlabel('f/Hz');
legend('Y(f)');

%% 实时频谱分析
% [data, Fs]=audioread('光年之外.mp3','native');
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
% Ai=analoginput('winsound'); % 创建一个模拟信号输入对象
% % 添加通道
% addchannel(Ai,1);
% Ai.SampleRate=48000; % 采样频率
% Ai.SamplesPerTrigger=Inf; % 采样数
% 
% start(Ai); % 开启采样
% warning off % 当采样数据不够时，取消警告
% while isrunning(Ai) % 检查对象是否仍在运行
%     if getappdata(h,'isrecording')
%         data=peekdata(Ai,Ai.SampleRate);% 获取对象中的最后Ai.SampleRate个采样数据
%         plot(thehandles.axes1,data) % 绘制最后Ai.SampleRate个采样数据的图形，因此表现出来就是实时的了
%         set(handles.axes1,'ylim',[-1 1],'xlim',[0 Ai.SampleRate]);
%         y1=fft(data,2048); %对信号做2048点FFT变换
%         f=Ai.SampleRate*(0:1023)/2048;
%         bar(handles.axes2,f,abs(y1(1:1024)),0.8,'g') %做原始语音信号的FFT频谱图
%         set(handles.axes2,'ylim',[0 10],'xlim',[0 20000]);%设置handles.axes2的横纵坐标范围
%         drawnow; % 刷新图像
%     else
%         stop(Ai);
%         num=get(Ai,'SamplesAvailable');
%         aa=getdata(Ai,num);
%         axes(thehandles.axes1);
%         plot(thehandles.axes1,aa) % 绘制所有采样数据的图形
% 
%         y1=fft(data,2048); %对信号做2048点FFT变换
%         f=Ai.SampleRate*(0:1023)/2048;
%         bar(handles.axes2,f,abs(y1(1:1024)),0.8,'g') %做原始语音信号的FFT频谱图
%         %set(handles.axes2,'ylim',[0 10],'xlim',[0 20000]);%设置handles.axes2的横纵坐标范围
%         drawnow; % 刷新图像
%         setappdata(h,'sounds',aa);
%     end
% end

%% 信号写入与发送
adw = audioDeviceWriter('SampleRate', afr.SampleRate);% Number of samples per second sent to device
%info(adw)

if ~isempty(findPlutoRadio)
        while ~isDone(afr)
            data = afr();
            adw(data);                         %本机播放
            underflow=txPluto(mod(data));
        end
        disp('Finish sending. Enjoy please.');
else
        warning('PlutoRadioNotFound')
end
