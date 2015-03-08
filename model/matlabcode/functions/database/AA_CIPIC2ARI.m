function [hM,meta,stimPar]=AA_CIPIC2ARI(CIPICfile,stimPar)
% AA_CIPIC2ARI - Convert CIPIC HRTF data to ARI HRTF format
% 
% [hM,meta,stimPar]=AA_CIPIC2ARI(CIPICfile,stimPar)
%
% Input:
%  CIPICfile: string with absolute link to .mat file including CIPIC HRTF data
%  stimPar: to preserve stimPar data (except see stimPar Output parameters!)
% Output:
%  hM: ARI HRTF data
%  meta: hM structured meta data
%  stimPar: contains:
%   stimPar.Resolution: Resolution for wav file (eg. 16, 24,...)
%   stimPar.SamplingRate: Sampling rate for wav file (eg. 44100, 48000,...)
%   stimPar.SubjectID: subject's ID
% 
% (see 'ARI HRTF format doc' for further details)
% 
% by Michael Mihocic 12.05.2011
%  Austrian Academy of Sciences, Acoustics Research Institute
%  basing on CIPIC2AMTatARI.m by Robert Baumgartner
% Last change: 05.10.2011 by Michael Mihocic, upgrade to structured meta
%  data hM version 2.0.0

load(CIPICfile);

lat=[-80 -65 -55 -45:5:45 55 65 80];    % given lateral angles
pol= -45 + 5.625*(0:49);                % given polar angles
len=length(lat)*length(pol);

% building meta.pos(:,[3 6 7])
meta.pos=zeros(len,7);
meta.pos(:,7)=repmat(pol',length(lat),1);
ida=round(0.5:1/length(pol):length(lat)+0.5-1/length(pol));
meta.pos(:,6)=lat(ida);
meta.pos(:,3)=NaN(len,1);

% building hM and meta.pos(:,[1 2 4 5])
hM=zeros(size(hrir_l,3),len,2);
ii=1;
for aa=1:length(lat)
    for ee=1:length(pol)
        hM(:,ii,1)=hrir_l(aa,ee,:);
        hM(:,ii,2)=hrir_r(aa,ee,:);
        [meta.pos(ii,1),meta.pos(ii,2)]=hor2geo(meta.pos(ii,6),meta.pos(ii,7));
        azi=mod(meta.pos(ii,1)+89.9,360)-89.9;
        if azi>90
            meta.pos(ii,4)=azi-180;
            meta.pos(ii,5)=180-meta.pos(ii,2);
        else
            meta.pos(ii,4)=azi;
            meta.pos(ii,5)=meta.pos(ii,2);
        end
        ii=ii+1;
    end
end
hM=single(hM);

% others
if exist('name','var')
    stimPar.SubjectID = name;
else
    stimPar.SubjectID = '';
end
meta.lat = NaN(len,1);
meta.amp = NaN(len,1);
meta.itemidx = NaN(len,1);
meta.toa = NaN(len,1);
stimPar.SamplingRate = 44100;
stimPar.GenMode = 1;  % acoustic
stimPar.Resolution = 16;