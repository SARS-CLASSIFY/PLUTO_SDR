clear
%% ��˷�¼����ʼ��
timeLength=0.1;            % ����ʱ������λ��
samples=timeLength*44100;  % Ĭ�ϲ�����44100�������������
H = dsp.AudioRecorder(...
    'NumChannels'   , 1 ,...               % 1 ��ͨ��
    'DeviceDataType', '16-bit integer',... % 16λ����
    'OutputNumOverrunSamples',true,...     % ���������־
    'SamplesPerFrame', samples);           % ��������
[audioIn,~] = step(H);                     % ��һ�β���



%% �����ʼ��
txPluto = sdrtx('Pluto','RadioID','usb:0',...
        'CenterFrequency',92.4e6,...
        'Gain',-0,...
        'ChannelMapping',1,...
        'BasebandSampleRate',228000);
txPluto.ShowAdvancedProperties = true;

afr=dsp.AudioFileReader('Amazing Trees.flac','SamplesPerFrame',44100/2);
adw = audioDeviceWriter('SampleRate', afr.SampleRate);
mod=comm.FMBroadcastModulator('AudioSampleRate',afr.SampleRate, ...
    'SampleRate',txPluto.BasebandSampleRate,'Stereo',false);
%data=audioread('Scarborough Fair.flac');

%% ���ճ�ʼ��
sigSrc=comm.SDRRxPluto(...
        'CenterFrequency',92.4e6,...%The channel you want to listen to (Hz)
        'GainSource','Manual',...
        'Gain',50,...                       %can control volume
        'ChannelMapping',1,...
        'BasebandSampleRate',228000,...
        'OutputDataType','single',...
        'SamplesPerFrame',45600*5/2);%5.2:�������������;5�ƺ���;4.2:�����м��;4.8:���չ�һ��ʱ����һ��

% ��ʼ�����
fmBroadcastDemod = comm.FMBroadcastDemodulator(...
        'SampleRate', 228000, ...
        'FrequencyDeviation', 75e3, ...
        'FilterTimeConstant', 7.5e-5, ...
        'AudioSampleRate', 45600, ...
        'Stereo', true);

% ������Ƶ������
player = audioDeviceWriter('SampleRate',45600);

%while ~isDone(afr)
while (1)
    
%%    ��˷����Ƶֱ���������
       [audioIn,Overrun] = step(H);        % ����
       if Overrun > 0
          warning('  ������� %d λ\n',Overrun);
       end

    
        data = audioIn;
    
        %data = afr();
        %adw(data); ��������
        %data=(data(:,1)+data(:,2))/2;
        data=mod(data);
        underflow=txPluto(data);
%%  �������
        
%         rcv = sigSrc();
%         audioSig = fmBroadcastDemod(rcv);
%         player(audioSig);
end
