function [ output_args ] = ros_load_ptam( input_args ,  plot_on )
%ROS_LOAD_PTAM Loads the PTAM data output by ROSbag files.
%   This script converts the csv file output from ROS into a MATLAB array
%   with field names, time-stamps. It is for a single PTAM pose
%   history.
%
%   The first input must be the file name of the csv extracted using the
%   'extractBag.sh' script.
%
%   The second optional input specifies if the data should be plotted.
%   1=plot, 0=do not plot.
%
%   The current MATLAB directory must contain the csv file.  

%Check if the plot argument has been supplied, if not then set to zero.
if nargin < 2
    plot_on = 0;
end

%If no file name use default
if nargin < 1
    plot_on = 1;
    input_args = 'ptam_pose';
end

%Check the csv file exists
if ~exist(input_args,'file')
    error('Input file not found.');
end

%Load the file using the standard MATLAB function
%NOTE: this step may cause bugs depending on how well MATLAB interprets the
%data. Currently (2013-05-14 R2011b) the impoirt data function fails to
%fully recognise the data format hence some re-arranging is needed.
temp = importdata(input_args);

%Check if any data was loaded
if ~isempty(temp)
    
    %Create an empty array to store the extracted data
    output_args = struct;
    
    %Add the time column and sequence number
    output_args = setfield(output_args,'time',temp.textdata(2:end,1));     %Add the data as text to the field 'time'
    output_args.time = str2num(cell2mat(output_args.time(:)));             %Then convert to numerical format
    output_args = setfield(output_args,'seqno',temp.textdata(2:end,2));    %Add the data as text to the field 'seqno'
    % output_args.seqno = str2num(cell2mat(output_args.seqno(:)));
    % %TODO: the conversion to a numerical type fails due to the first
    % sequence number beign 0

    %Add the translational data
    output_args = setfield(output_args,'tx',temp.data(:,1));               %Add the x position to the field 'tx'
    output_args = setfield(output_args,'ty',temp.data(:,2));               %Add the y position to the field 'ty'
    output_args = setfield(output_args,'tz',temp.data(:,3));               %Add the z position to the field 'tz'

    %Add the rotational data
    output_args = setfield(output_args,'rx',temp.data(:,4));               %Add the x rotation to the field 'rx'
    output_args = setfield(output_args,'ry',temp.data(:,5));               %Add the y rotation to the field 'ry'
    output_args = setfield(output_args,'rz',temp.data(:,6));               %Add the z rotation to the field 'rz'
    output_args = setfield(output_args,'rw',temp.data(:,7));               %Add the w rotation to the field 'rw'
    
    %This completes the data loading

    if plot_on
        h1 = figure('name','Ptam: Time: Pos'); hold on;
        temp_time = ( output_args.time - output_args.time(1) )/1000000000;
        plot(temp_time,output_args.tx,'-r');
        plot(temp_time,output_args.ty,'-g');
        plot(temp_time,output_args.tz,'-b');
        legend('x','y','z');
        xlabel('Time (s)');
        ylabel('Pos. (m)');

        h2 = figure('name','Ptam: Time: Rot'); hold on;
        temp_time = ( output_args.time - output_args.time(1) )/1000000000;
        plot(temp_time,output_args.rx,'-r');
        plot(temp_time,output_args.ry,'-g');
        plot(temp_time,output_args.rz,'-b');
        plot(temp_time,output_args.rw,'-y');
        legend('x','y','z','w');
        xlabel('Time (s)');
        ylabel('Rot. (quarternion)');
    end
else
    %If the file exists but is empty then return 
    warning('ROSLIB:LOADPTAM','Input file is empty');
    output_args = [];
end

end %ros_load_ptam