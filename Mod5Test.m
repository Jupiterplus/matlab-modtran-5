function List = Mod5Test(Filespec, InputDir, OutputDir)
% Mod5Test : Test reading, writing of MODTRAN 5 cases
%
% This function reads all the .tp5 files in the InputDir and
% writes the same files to the OutputDir. It will also write 
% the file mod5root.in listing all the test cases to the MODTRAN
% executable directory. Note that this function does not run the cases. To
% run the cases, use the function Mod5TestRun.
% 
% Usage :
%   List = Mod5Test(FileSpec, InputDir, OutputDir)
%
% If no file specification is given, it will default to *.tp5 (read and
% write all .tp5 files from InputDir to OutputDir).
% If the input and output directories are not given, a directory selection
% dialog will be presented.
% Note that this function does not run the case. The cases can be run in
% bulk by starting MODTRAN in a command window.
%
% Example:
%   Mod5Test('*.tp5', 'TEST', 'TESTA');
%
% This example will read all .tp5 files from the TEST subdirectory of the
% MODTRAN executable home directory and write the cases to the TESTA
% sub-directory. If the directory does not start with / or \, the directory
% is assumed relative to the MODTRAN executable directory.
%  
%
% See also : Mod5Compare, Mod5TestRun

% Copyright 2011, DPSS, CSIR, $Author:$
% $Id:$

List = {};
persistent MODTRANPath MODTRANExe
%% Deal with location of the MODTRAN executable
if isempty(MODTRANExe)
    MODTRANExeFile = [fileparts(which('Mod5.m')) '\MODTRANExe.mat'];
    if exist(MODTRANExeFile, 'file')
        load(MODTRANExeFile);
        if ~exist(MODTRANExe, 'file') % Check that the MODTRAN executable exists
            [MODTRANExe, MODTRANPath] = Mod5.SetMODTRANExe;
        end
    else
        [MODTRANExe, MODTRANPath] = Mod5.SetMODTRANExe;
    end
end

if ~exist('Filespec', 'var') || isempty(Filespec)
    Filespec = '\*.tp5';
else
    assert(ischar(Filespec), 'Mod5Test:BadFilespec',...
        'The input Filespec must be a string.');
    if ~any(Filespec(1) == '/\')
        Filespec = ['\' Filespec];
    end
end

if ~exist('InputDir', 'var') || isempty(InputDir)
    InputDir = uigetdir(MODTRANPath, 'Select the Directory for MODTRAN Input Test Cases');
    if InputDir(1) == 0
        return;
    end
else
    assert(ischar(InputDir), 'Mod5Test:BadInputDir',...
        'The input InputDir must be a string.');
    if ~any(InputDir(1) == '/\')
        InputDir = [MODTRANPath InputDir];
    end
end
% The input directory must exist
assert(exist(InputDir, 'dir') == 7, 'Mod5Test:InputDirNotExist', ...
    'The input directory %s does not exist.', InputDir)
if ~exist('OutputDir', 'var') || isempty(OutputDir)
    OutputDir = uigetdir(MODTRANPath, 'Select the Directory for the Output MODTRAN Cases');
    if OutputDir(1) == 0
        return;
    end
else
    assert(ischar(OutputDir), 'Mod5Test:BadOutputDir',...
        'The input InputDir must be a string.');
    if ~any(OutputDir(1) == '/\')
        OutputDir = [MODTRANPath OutputDir];
    end
    
end
% The output directory might not exist
if exist(OutputDir, 'dir') ~= 7
    Answer = questdlg(['Create Directory ' OutputDir ' ?'],'Directory Create', 'Yes');
    if strcmpi(Answer, 'Yes')
      [Success, Message] = mkdir(OutputDir);
      if ~Success
          error('Mod5Test:FolderCreateFailed', 'Unable to create folder %s. %s.', OutputDir, Message);
      end
    else
        return;
    end
end
%% Read and write all cases
TheCases = dir([InputDir Filespec]);
try
    fid = fopen([MODTRANPath 'mod5root.in'], 'wt'); % Will write to mod5root.in
    for iCase = 1:numel(TheCases)
        fprintf('Reading and Writing Case %s\n', TheCases(iCase).name);
        List = [List TheCases(iCase).name];
        ThisMod5 = Mod5([InputDir '\' TheCases(iCase).name]);
        ThisMod5.Write([OutputDir '\' TheCases(iCase).name]);
        fprintf(fid, '%s\n', [OutputDir '\' TheCases(iCase).name]);
    end
    fclose(fid);
catch TestingFailed
    fclose(fid);
    rethrow(TestingFailed);
end
end
