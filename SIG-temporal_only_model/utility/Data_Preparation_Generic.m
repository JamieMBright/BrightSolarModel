%%%%%%%%%%%%%%%%%%%%
% DATA PREPARATION %
%%%%%%%%%%%%%%%%%%%%

% This code prepares all the years data into one file to be used in the weather generator.
%
% This code only needs to be run once
%
% The file name that is written at the end of this needs changing for each
% different location
%
% The INPUT data is taken raw from the Access files (linked to the .txt files from BADC.
%    - The top row needs deleting
%    - Insert column to the right of the date
%    - Convert date from 'custom' format to 'general' format in excel
%    - number the first hour manually in 2nd column (01/01/2001 00:00 = 1 etc).
%    - The rest of the column has the following expression:
%            - =rounddup(R1C2 + ((R2C1 - R1C1)/0.0416666666642413),1)
%            - where R = Row and C = Column
%    - File should be saved as 'BADC hourly data 2012.csv' (with appropriate year).
%
%
% The output format is as follows:
%columns
% 1) hour
% 2) cloud total (okta)
% 3) Low cloud type
% 4) Medium Cloud Type
% 5) high cloud type
% 6) cloud base height
% 7) pressure (msl)
% 8)  1 - cloud ammount
% 9)  1 - cloud type
% 10) 1 - cloud height (decameters)
% 11) 2    ""
% 12) 2    ""
% 13) 2    ""
% 14) 3    ""
% 15) 3    ""
% 16) 3    ""
% 17) Air temp
% 18) Year
% 19) Hour
% 20) Day Number
% 21) Wind Direction
% 22) Wind speed (10m)

clear all;
tic
%% read in the data 
%needs adjusting... 41 columns.

%input data in following format:


%This longer winded method is to allow empty values to be assigned as -9999.
%csvread or dlmread reads empty cells as 0, which indicates clear sky. -1
%can be ignored later. 
disp(['Reading in Data Files',1])
fidA=fopen('BADC hourly data 2012.csv','rt');
Ascan=textscan(fidA,'%*s%*f%f%*f%*s%*s%*f%*f%*f%*f%*f%f%f%*f%*f%*f%f%f%f%f%*f%f%*f%f%f%f%f%f%f%f%f%f%f%*f%*f%*f%*f%f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*f%*s%*f%*f%*f%*f%*f','Delimiter',',','EmptyValue',-9999);
fclose(fidA);
A=[Ascan{1,1},Ascan{1,4},Ascan{1,5},Ascan{1,6},Ascan{1,7},Ascan{1,8},Ascan{1,9},Ascan{1,10},Ascan{1,11},Ascan{1,12},Ascan{1,13},Ascan{1,14},Ascan{1,15},Ascan{1,16},Ascan{1,17},Ascan{1,18},Ascan{1,19},zeros(length(Ascan{1,1}),1),zeros(length(Ascan{1,1}),1),zeros(length(Ascan{1,1}),1),Ascan{1,2},Ascan{1,3}];

fidB=fopen('BADC hourly data 2011.csv','rt');
Bscan=textscan(fidB,'%*s%*f%f%*f%*s%*s%*f%*f%*f%*f%*f%f%f%*f%*f%*f%f%f%f%f%*f%f%*f%f%f%f%f%f%f%f%f%f%f%*f%*f%*f%*f%f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*f%*s%*f%*f%*f%*f%*f','Delimiter',',','EmptyValue',-9999);
fclose(fidB);
B=[Bscan{1,1},Bscan{1,4},Bscan{1,5},Bscan{1,6},Bscan{1,7},Bscan{1,8},Bscan{1,9},Bscan{1,10},Bscan{1,11},Bscan{1,12},Bscan{1,13},Bscan{1,14},Bscan{1,15},Bscan{1,16},Bscan{1,17},Bscan{1,18},Bscan{1,19},zeros(length(Bscan{1,1}),1),zeros(length(Bscan{1,1}),1),zeros(length(Bscan{1,1}),1),Bscan{1,2},Bscan{1,3}];

fidC=fopen('BADC hourly data 2010.csv','rt');
Cscan=textscan(fidC,'%*s%*f%f%*f%*s%*s%*f%*f%*f%*f%*f%f%f%*f%*f%*f%f%f%f%f%*f%f%*f%f%f%f%f%f%f%f%f%f%f%*f%*f%*f%*f%f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*f%*s%*f%*f%*f%*f%*f','Delimiter',',','EmptyValue',-9999);
fclose(fidC);
C=[Cscan{1,1},Cscan{1,4},Cscan{1,5},Cscan{1,6},Cscan{1,7},Cscan{1,8},Cscan{1,9},Cscan{1,10},Cscan{1,11},Cscan{1,12},Cscan{1,13},Cscan{1,14},Cscan{1,15},Cscan{1,16},Cscan{1,17},Cscan{1,18},Cscan{1,19},zeros(length(Cscan{1,1}),1),zeros(length(Cscan{1,1}),1),zeros(length(Cscan{1,1}),1),Cscan{1,2},Cscan{1,3}];

fidD=fopen('BADC hourly data 2009.csv','rt');
Dscan=textscan(fidD,'%*s%*f%f%*f%*s%*s%*f%*f%*f%*f%*f%f%f%*f%*f%*f%f%f%f%f%*f%f%*f%f%f%f%f%f%f%f%f%f%f%*f%*f%*f%*f%f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*f%*s%*f%*f%*f%*f%*f','Delimiter',',','EmptyValue',-9999);
fclose(fidD);
D=[Dscan{1,1},Dscan{1,4},Dscan{1,5},Dscan{1,6},Dscan{1,7},Dscan{1,8},Dscan{1,9},Dscan{1,10},Dscan{1,11},Dscan{1,12},Dscan{1,13},Dscan{1,14},Dscan{1,15},Dscan{1,16},Dscan{1,17},Dscan{1,18},Dscan{1,19},zeros(length(Dscan{1,1}),1),zeros(length(Dscan{1,1}),1),zeros(length(Dscan{1,1}),1),Dscan{1,2},Dscan{1,3}];

fidE=fopen('BADC hourly data 2008.csv','rt');
Escan=textscan(fidE,'%*s%*f%f%*f%*s%*s%*f%*f%*f%*f%*f%f%f%*f%*f%*f%f%f%f%f%*f%f%*f%f%f%f%f%f%f%f%f%f%f%*f%*f%*f%*f%f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*f%*s%*f%*f%*f%*f%*f','Delimiter',',','EmptyValue',-9999);
fclose(fidE);
E=[Escan{1,1},Escan{1,4},Escan{1,5},Escan{1,6},Escan{1,7},Escan{1,8},Escan{1,9},Escan{1,10},Escan{1,11},Escan{1,12},Escan{1,13},Escan{1,14},Escan{1,15},Escan{1,16},Escan{1,17},Escan{1,18},Escan{1,19},zeros(length(Escan{1,1}),1),zeros(length(Escan{1,1}),1),zeros(length(Escan{1,1}),1),Escan{1,2},Escan{1,3}];

fidF=fopen('BADC hourly data 2007.csv','rt');
Fscan=textscan(fidF,'%*s%*f%f%*f%*s%*s%*f%*f%*f%*f%*f%f%f%*f%*f%*f%f%f%f%f%*f%f%*f%f%f%f%f%f%f%f%f%f%f%*f%*f%*f%*f%f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*f%*s%*f%*f%*f%*f%*f','Delimiter',',','EmptyValue',-9999);
fclose(fidF);
F=[Fscan{1,1},Fscan{1,4},Fscan{1,5},Fscan{1,6},Fscan{1,7},Fscan{1,8},Fscan{1,9},Fscan{1,10},Fscan{1,11},Fscan{1,12},Fscan{1,13},Fscan{1,14},Fscan{1,15},Fscan{1,16},Fscan{1,17},Fscan{1,18},Fscan{1,19},zeros(length(Fscan{1,1}),1),zeros(length(Fscan{1,1}),1),zeros(length(Fscan{1,1}),1),Fscan{1,2},Fscan{1,3}];

fidG=fopen('BADC hourly data 2006.csv','rt');
Gscan=textscan(fidG,'%*s%*f%f%*f%*s%*s%*f%*f%*f%*f%*f%f%f%*f%*f%*f%f%f%f%f%*f%f%*f%f%f%f%f%f%f%f%f%f%f%*f%*f%*f%*f%f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*f%*s%*f%*f%*f%*f%*f','Delimiter',',','EmptyValue',-9999);
fclose(fidG);
G=[Gscan{1,1},Gscan{1,4},Gscan{1,5},Gscan{1,6},Gscan{1,7},Gscan{1,8},Gscan{1,9},Gscan{1,10},Gscan{1,11},Gscan{1,12},Gscan{1,13},Gscan{1,14},Gscan{1,15},Gscan{1,16},Gscan{1,17},Gscan{1,18},Gscan{1,19},zeros(length(Gscan{1,1}),1),zeros(length(Gscan{1,1}),1),zeros(length(Gscan{1,1}),1),Gscan{1,2},Gscan{1,3}];

fidH=fopen('BADC hourly data 2005.csv','rt');
Hscan=textscan(fidH,'%*s%*f%f%*f%*s%*s%*f%*f%*f%*f%*f%f%f%*f%*f%*f%f%f%f%f%*f%f%*f%f%f%f%f%f%f%f%f%f%f%*f%*f%*f%*f%f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*f%*s%*f%*f%*f%*f%*f','Delimiter',',','EmptyValue',-9999);
fclose(fidH);
H=[Hscan{1,1},Hscan{1,4},Hscan{1,5},Hscan{1,6},Hscan{1,7},Hscan{1,8},Hscan{1,9},Hscan{1,10},Hscan{1,11},Hscan{1,12},Hscan{1,13},Hscan{1,14},Hscan{1,15},Hscan{1,16},Hscan{1,17},Hscan{1,18},Hscan{1,19},zeros(length(Hscan{1,1}),1),zeros(length(Hscan{1,1}),1),zeros(length(Hscan{1,1}),1),Hscan{1,2},Hscan{1,3}];

fidI=fopen('BADC hourly data 2004.csv','rt');
Iscan=textscan(fidI,'%*s%*f%f%*f%*s%*s%*f%*f%*f%*f%*f%f%f%*f%*f%*f%f%f%f%f%*f%f%*f%f%f%f%f%f%f%f%f%f%f%*f%*f%*f%*f%f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*f%*s%*f%*f%*f%*f%*f','Delimiter',',','EmptyValue',-9999);
fclose(fidI);
I=[Iscan{1,1},Iscan{1,4},Iscan{1,5},Iscan{1,6},Iscan{1,7},Iscan{1,8},Iscan{1,9},Iscan{1,10},Iscan{1,11},Iscan{1,12},Iscan{1,13},Iscan{1,14},Iscan{1,15},Iscan{1,16},Iscan{1,17},Iscan{1,18},Iscan{1,19},zeros(length(Iscan{1,1}),1),zeros(length(Iscan{1,1}),1),zeros(length(Iscan{1,1}),1),Iscan{1,2},Iscan{1,3}];

fidJ=fopen('BADC hourly data 2003.csv','rt');
Jscan=textscan(fidJ,'%*s%*f%f%*f%*s%*s%*f%*f%*f%*f%*f%f%f%*f%*f%*f%f%f%f%f%*f%f%*f%f%f%f%f%f%f%f%f%f%f%*f%*f%*f%*f%f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*f%*s%*f%*f%*f%*f%*f','Delimiter',',','EmptyValue',-9999);
fclose(fidJ);
J=[Jscan{1,1},Jscan{1,4},Jscan{1,5},Jscan{1,6},Jscan{1,7},Jscan{1,8},Jscan{1,9},Jscan{1,10},Jscan{1,11},Jscan{1,12},Jscan{1,13},Jscan{1,14},Jscan{1,15},Jscan{1,16},Jscan{1,17},Jscan{1,18},Jscan{1,19},zeros(length(Jscan{1,1}),1),zeros(length(Jscan{1,1}),1),zeros(length(Jscan{1,1}),1),Jscan{1,2},Jscan{1,3}];

fidK=fopen('BADC hourly data 2002.csv','rt');
Kscan=textscan(fidK,'%*s%*f%f%*f%*s%*s%*f%*f%*f%*f%*f%f%f%*f%*f%*f%f%f%f%f%*f%f%*f%f%f%f%f%f%f%f%f%f%f%*f%*f%*f%*f%f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*f%*s%*f%*f%*f%*f%*f','Delimiter',',','EmptyValue',-9999);
fclose(fidK);
K=[Kscan{1,1},Kscan{1,4},Kscan{1,5},Kscan{1,6},Kscan{1,7},Kscan{1,8},Kscan{1,9},Kscan{1,10},Kscan{1,11},Kscan{1,12},Kscan{1,13},Kscan{1,14},Kscan{1,15},Kscan{1,16},Kscan{1,17},Kscan{1,18},Kscan{1,19},zeros(length(Kscan{1,1}),1),zeros(length(Kscan{1,1}),1),zeros(length(Kscan{1,1}),1),Kscan{1,2},Kscan{1,3}];

fidL=fopen('BADC hourly data 2001.csv','rt');
Lscan=textscan(fidL,'%*s%*f%f%*f%*s%*s%*f%*f%*f%*f%*f%f%f%*f%*f%*f%f%f%f%f%*f%f%*f%f%f%f%f%f%f%f%f%f%f%*f%*f%*f%*f%f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*f%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*s%*f%*s%*f%*f%*f%*f%*f','Delimiter',',','EmptyValue',-9999);
fclose(fidL);
L=[Lscan{1,1},Lscan{1,4},Lscan{1,5},Lscan{1,6},Lscan{1,7},Lscan{1,8},Lscan{1,9},Lscan{1,10},Lscan{1,11},Lscan{1,12},Lscan{1,13},Lscan{1,14},Lscan{1,15},Lscan{1,16},Lscan{1,17},Lscan{1,18},Lscan{1,19},zeros(length(Lscan{1,1}),1),zeros(length(Lscan{1,1}),1),zeros(length(Lscan{1,1}),1),Lscan{1,2},Lscan{1,3}];

%% Create unity in all duplicate hours. If there is a disparity between the
%two, the worser case of the two will be selected, i.e the higher of the
%two. As magnitude does not affect the weather type, it is assumed that the
%earlier reading is incorrect. 
disp(['Removing Duplicate Hours',1])
%Begins at row 2 as the loop searches i-1 and cannot access (0,1).
for iterations=1:2;
    for i=1:length(A)-1;
        for j=2:22;
            if A(i,1)==A(i+1,1); %if the hour number is the same with the next  hour number
                if A(i,j)<A(i+1,j); %if there is a disparity between the two measurements
                    A(i,j)=A(i+1,j); %set the anomaly to the higher of the values
                elseif A(i,j)>A(i+1,j);
                    A(i+1,j)=A(i,j);
                end
            end
        end
    end
end
for iterations=1:2;
    for i=1:length(B)-1;
        for j=2:22;
            if B(i,1)==B(i+1,1); %if the hour number is the same with the next  hour number
                if B(i,j)<B(i+1,j); %if there is a disparity between the two measurements
                    B(i,j)=B(i+1,j); %set the anomaly to the higher of the values
                elseif B(i,j)>B(i+1,j);
                    B(i+1,j)=B(i,j);
                end
            end
        end
    end
end
for iterations=1:2;
    for i=1:length(C)-1;
        for j=2:22;
            if C(i,1)==C(i+1,1); %if the hour number is the same with the next  hour number
                if C(i,j)<C(i+1,j); %if there is a disparity between the two measurements
                    C(i,j)=C(i+1,j); %set the anomaly to the higher of the values
                elseif C(i,j)>C(i+1,j);
                    C(i+1,j)=C(i,j);
                end
            end
        end
    end
end
for iterations=1:2;
    for i=1:length(D)-1;
        for j=2:22;
            if D(i,1)==D(i+1,1); %if the hour number is the same with the next  hour number
                if D(i,j)<D(i+1,j); %if there is a disparity between the two measurements
                    D(i,j)=D(i+1,j); %set the anomaly to the higher of the values
                elseif D(i,j)>D(i+1,j);
                    D(i+1,j)=D(i,j);
                end
            end
        end
    end
end
for iterations=1:2;
    for i=1:length(E)-1;
        for j=2:22;
            if E(i,1)==E(i+1,1); %if the hour number is the same with the next  hour number
                if E(i,j)<E(i+1,j); %if there is a disparity between the two measurements
                    E(i,j)=E(i+1,j); %set the anomaly to the higher of the values
                elseif E(i,j)>E(i+1,j);
                    E(i+1,j)=E(i,j);
                end
            end
        end
    end
    for i=1:length(F)-1;
        for j=2:22;
            if F(i,1)==F(i+1,1); %if the hour number is the same with the next  hour number
                if F(i,j)<F(i+1,j); %if there is a disparity between the two measurements
                    F(i,j)=F(i+1,j); %set the anomaly to the higher of the values
                elseif F(i,j)>F(i+1,j);
                    F(i+1,j)=F(i,j);
                end
            end
        end
    end
end
for iterations=1:2;
    for i=1:length(G)-1;
        for j=2:14;
            if G(i,1)==G(i+1,1); %if the hour number is the same with the next  hour number
                if G(i,j)<G(i+1,j); %if there is a disparity between the two measurements
                    G(i,j)=G(i+1,j); %set the anomaly to the higher of the values
                elseif G(i,j)>G(i+1,j);
                    G(i+1,j)=G(i,j);
                end
            end
        end
    end
end
for iterations=1:2;
    for i=1:length(H)-1;
        for j=2:22;
            if H(i,1)==H(i+1,1); %if the hour number is the same with the next  hour number
                if H(i,j)<H(i+1,j); %if there is a disparity between the two measurements
                    H(i,j)=H(i+1,j); %set the anomaly to the higher of the values
                elseif A(i,j)>H(i+1,j);
                    H(i+1,j)=H(i,j);
                end
            end
        end
    end
end
for iterations=1:2;
    for i=1:length(I)-1;
        for j=2:14;
            if I(i,1)==I(i+1,1); %if the hour number is the same with the next  hour number
                if I(i,j)<I(i+1,j); %if there is a disparity between the two measurements
                    I(i,j)=I(i+1,j); %set the anomaly to the higher of the values
                elseif I(i,j)>I(i+1,j);
                    I(i+1,j)=I(i,j);
                end
            end
        end
    end
end
for iterations=1:2;
    for i=1:length(J)-1;
        for j=2:22;
            if J(i,1)==J(i+1,1); %if the hour number is the same with the next  hour number
                if J(i,j)<J(i+1,j); %if there is a disparity between the two measurements
                    J(i,j)=J(i+1,j); %set the anomaly to the higher of the values
                elseif J(i,j)>J(i+1,j);
                    J(i+1,j)=J(i,j);
                end
            end
        end
    end
end
for iterations=1:2;
    for i=1:length(K)-1;
        for j=2:22;
            if K(i,1)==K(i+1,1); %if the hour number is the same with the next  hour number
                if K(i,j)<K(i+1,j); %if there is a disparity between the two measurements
                    K(i,j)=K(i+1,j); %set the anomaly to the higher of the values
                elseif K(i,j)>K(i+1,j);
                    K(i+1,j)=K(i,j);
                end
            end
        end
    end
end
for iterations=1:2;
    for i=1:length(L)-1;
        for j=2:22;
            if L(i,1)==L(i+1,1); %if the hour number is the same with the next  hour number
                if L(i,j)<L(i+1,j); %if there is a disparity between the two measurements
                    L(i,j)=L(i+1,j); %set the anomaly to the higher of the values
                elseif L(i,j)>L(i+1,j);
                    L(i+1,j)=L(i,j);
                end
            end
        end
    end
end

%Remove duplicate hours
Aa=unique(A,'rows');
Ba=unique(B,'rows');
Ca=unique(C,'rows');
Da=unique(D,'rows');
Ea=unique(E,'rows');
Fa=unique(F,'rows');
Ga=unique(G,'rows');
Ha=unique(H,'rows');
Ia=unique(I,'rows');
Ja=unique(J,'rows');
Ka=unique(K,'rows');
La=unique(L,'rows');

% % % if La(1,1)==-9999;  %La seems to add a row of blanks in column 1. This line removes it.
% % %     La(1,:)=[];
% % % end

%% Create large blank(9999) arrays with a full number of hours in first column 
hrs_year=8760;
hrs_leapyear=8784;
disp(['Producing Data File',1])
Ab=ones(hrs_leapyear,22)*-9999;%2012 LEAP YEAR
Ab(:,1)=(1:hrs_leapyear);
Bb=ones(hrs_year,22)*-9999; %2011
Bb(:,1)=(1:hrs_year);
Cb=ones(hrs_year,22)*-9999; %2010
Cb(:,1)=(1:hrs_year);
Db=ones(hrs_year,22)*-9999; %2009
Db(:,1)=(1:hrs_year);
Eb=ones(hrs_leapyear,22)*-9999; %2008 LEAP YEAR
Eb(:,1)=(1:hrs_leapyear);
Fb=ones(hrs_year,22)*-9999; %2007
Fb(:,1)=(1:hrs_year);
Gb=ones(hrs_year,22)*-9999; %2006
Gb(:,1)=(1:hrs_year);
Hb=ones(hrs_year,22)*-9999; %2005
Hb(:,1)=(1:hrs_year);
Ib=ones(hrs_leapyear,22)*-9999; %2004 LEAP YEAR
Ib(:,1)=(1:hrs_leapyear);
Jb=ones(hrs_year,22)*-9999; %2003
Jb(:,1)=(1:hrs_year);
Kb=ones(hrs_year,22)*-9999; %2002
Kb(:,1)=(1:hrs_year);
Lb=ones(hrs_year,22)*-9999; %2001
Lb(:,1)=(1:hrs_year);
%Replace any blank hour with measured data if available
for i=1:length(Aa);   
     Ac=Aa(:,1);
     Ab(Ac(i,1),:)=Aa(i,:);
end
for i=1:length(Ba);   
     Bc=Ba(:,1);
     Bb(Bc(i,1),:)=Ba(i,:);
end
for i=1:length(Ca);   
     Cc=Ca(:,1);
     Cc=round(Cc);
     Cb(Cc(i,1),:)=Ca(i,:);
end
for i=1:length(Da);   
     Dc=Da(:,1);
     Db(Dc(i,1),:)=Da(i,:);
end
for i=1:length(Ea);   
     Ec=Ea(:,1);  
     Eb(Ec(i,1),:)=Ea(i,:);
end
for i=1:length(Fa);   
     Fc=Fa(:,1);
     Fb(Fc(i,1),:)=Fa(i,:);
end
for i=1:length(Ga);   
     Gc=Ga(:,1);
     Gb(Gc(i,1),:)=Ga(i,:);
end
for i=1:length(Ha);   
     Hc=Ha(:,1);
     Hb(Hc(i,1),:)=Ha(i,:);
end
for i=1:length(Ia);   
     Ic=Ia(:,1);
     Ib(Ic(i,1),:)=Ia(i,:);
end
for i=1:length(Ja);   
     Jc=Ja(:,1);
     Jb(Jc(i,1),:)=Ja(i,:);
end
for i=1:length(Ka);   
     Kc=Ka(:,1);
     Kb(Kc(i,1),:)=Ka(i,:);
end
for i=1:length(La);   
     Lc=La(:,1);
     Lb(Lc(i,1),:)=La(i,:);
end
      
%% Produce a single file for Markov chain creation

%add the year and day number to the array. Column 18) year. 19)Hour of Day.
%20)day number.

Ab(:,18)=2012; %Leap Year
Ab(:,19)=2; %set next hours as 2
Ab(1,19)=1;%set first hour to 1
Ab(:,20)=1;% set day number to 1
for i=2:length(Ab)-1;
    if Ab(i,19)==24;
        Ab(i+1,19)=1; %reset hour of day
    else Ab(i+1,19)=Ab(i,19)+1;
    end
end
for i=2:length(Ab)-1;
    if Ab(i,19)==24; %if hour number = 24
        Ab(i+1,20)=Ab(i,20)+1; %day = day+1
    else Ab(i+1,20)=Ab(i,20); %day=stays same
    end
end

Bb(:,18)=2011;
Bb(:,19)=2;
Bb(1,19)=1;
Bb(:,20)=1;
for i=2:length(Bb)-1;
    if Bb(i,19)==24;
        Bb(i+1,19)=1;
    else Bb(i+1,19)=Bb(i,19)+1;
    end
end
for i=2:length(Bb)-1;
    if Bb(i,19)==24;
        Bb(i+1,20)=Bb(i,20)+1;
    else Bb(i+1,20)=Bb(i,20);
    end
end

Cb(:,18)=2010;
Cb(:,19)=2;
Cb(1,19)=1;
Cb(:,20)=1;
for i=2:length(Cb)-1;
    if Cb(i,19)==24;
        Cb(i+1,19)=1;
    else Cb(i+1,19)=Cb(i,19)+1;
    end
end
for i=2:length(Cb)-1;
    if Cb(i,19)==24;
        Cb(i+1,20)=Cb(i,20)+1;
    else Cb(i+1,20)=Cb(i,20);
    end
end

Db(:,18)=2009;
Db(:,19)=2;
Db(1,19)=1;
Db(:,20)=1;
for i=2:length(Db)-1;
    if Db(i,19)==24;
        Db(i+1,19)=1;
    else Db(i+1,19)=Db(i,19)+1;
    end
end
for i=2:length(Db)-1;
    if Db(i,19)==24;
        Db(i+1,20)=Db(i,20)+1;
    else Db(i+1,20)=Db(i,20);
    end
end

Eb(:,18)=2008; %Leap Year
Eb(:,19)=2;
Eb(1,19)=1;
Eb(:,20)=1;
for i=2:length(Eb)-1;
    if Eb(i,19)==24;
        Eb(i+1,19)=1;
    else Eb(i+1,19)=Eb(i,19)+1;
    end
end
for i=2:length(Eb)-1;
    if Eb(i,19)==24;
        Eb(i+1,20)=Eb(i,20)+1;
    else Eb(i+1,20)=Eb(i,20);
    end
end

Fb(:,18)=2007;
Fb(:,19)=2;
Fb(1,19)=1;
Fb(:,20)=1;
for i=2:length(Fb)-1;
    if Fb(i,19)==24;
        Fb(i+1,19)=1;
    else Fb(i+1,19)=Fb(i,19)+1;
    end
end
for i=2:length(Fb)-1;
    if Fb(i,19)==24;
        Fb(i+1,20)=Fb(i,20)+1;
    else Fb(i+1,20)=Fb(i,20);
    end
end

Gb(:,18)=2006;
Gb(:,19)=2;
Gb(1,19)=1;
Gb(:,20)=1;
for i=2:length(Gb)-1;
    if Gb(i,19)==24;
        Gb(i+1,19)=1;
    else Gb(i+1,19)=Gb(i,19)+1;
    end
end
for i=2:length(Gb)-1;
    if Gb(i,19)==24;
        Gb(i+1,20)=Gb(i,20)+1;
    else Gb(i+1,20)=Gb(i,20);
    end
end

Hb(:,18)=2005;
Hb(:,19)=2;
Hb(1,19)=1;
Hb(:,20)=1;
for i=2:length(Hb)-1;
    if Hb(i,19)==24;
        Hb(i+1,19)=1;
    else Hb(i+1,19)=Hb(i,19)+1;
    end
end
for i=2:length(Hb)-1;
    if Hb(i,19)==24;
        Hb(i+1,20)=Hb(i,20)+1;
    else Hb(i+1,20)=Hb(i,20);
    end
end

Ib(:,18)=2004; %Leap Year
Ib(:,19)=2;
Ib(1,19)=1;
Ib(:,20)=1;
for i=2:length(Ib)-1;
    if Ib(i,19)==24;
        Ib(i+1,19)=1;
    else Ib(i+1,19)=Ib(i,19)+1;
    end
end
for i=2:length(Ib)-1;
    if Ib(i,19)==24;
        Ib(i+1,20)=Ib(i,20)+1;
    else Ib(i+1,20)=Ib(i,20);
    end
end

Jb(:,18)=2003; 
Jb(:,19)=2;
Jb(1,19)=1;
Jb(:,20)=1;
for i=2:length(Jb)-1;
    if Jb(i,19)==24;
        Jb(i+1,19)=1;
    else Jb(i+1,19)=Jb(i,19)+1;
    end
end
for i=2:length(Jb)-1;
    if Jb(i,19)==24;
        Jb(i+1,20)=Jb(i,20)+1;
    else Jb(i+1,20)=Jb(i,20);
    end
end

Kb(:,18)=2002; 
Kb(:,19)=2;
Kb(1,19)=1;
Kb(:,20)=1;
for i=2:length(Kb)-1;
    if Kb(i,19)==24;
        Kb(i+1,19)=1;
    else Kb(i+1,19)=Kb(i,19)+1;
    end
end
for i=2:length(Kb)-1;
    if Kb(i,19)==24;
        Kb(i+1,20)=Kb(i,20)+1;
    else Kb(i+1,20)=Kb(i,20);
    end
end

Lb(:,18)=2001; 
Lb(:,19)=2;
Lb(1,19)=1;
Lb(:,20)=1;
for i=2:length(Lb)-1;
    if Lb(i,19)==24;
        Lb(i+1,19)=1;
    else Lb(i+1,19)=Lb(i,19)+1;
    end
end
for i=2:length(Lb)-1;
    if Lb(i,19)==24;
        Lb(i+1,20)=Lb(i,20)+1;
    else Lb(i+1,20)=Lb(i,20);
    end
end

data=[Lb;Kb;Jb;Ib;Hb;Gb;Fb;Eb;Db;Cb;Bb;Ab]; %Colaborate
%% gather pressure data
pressure(:,1)=1:length(data); % GATHER PRESSURE FOR THE TOTAL TIME
pressure(:,2)=data(:,7);
pressure_length=length(pressure);
disp(['Gathering Pressure Data',1])
for j=1:10;
    for i=1:length(pressure);
        if pressure(i,2)==-9999;
            pressure(i,3)=1;
        end
    end
    
    plength=sum(pressure(:,3));
    
    for i=1:(length(pressure)-plength);
        if pressure(i,2)==-9999;
            pressure(i,:)=[];
        end
    end
    
    for i=1:20;
        if pressure(length(pressure),2)==-9999;
            pressure(length(pressure),:)=[];
        end
    end
end

disp(['Writing To File',1])
csvwrite('1395pressure2001to2012.csv',pressure);
csvwrite('1395data2001to2012.csv',data);
%% report success
% 
% old_hours=[length(A);length(B);length(C);length(D);length(E);length(F);length(G);length(H);length(I);length(J);length(K);length(L)];
% new_hours=[length(Ab);length(Bb);length(Cb);length(Db);length(Eb);length(Fb);length(Gb);length(Hb);length(Ib);length(Jb);length(Kb);length(Lb)];
% difference=old_hours-new_hours;
% year=[2012;2011;2010;2009;2008;2007;2006;2005;2004;2003;2002;2001];
% report=[year,old_hours,new_hours,difference]; 
toc


