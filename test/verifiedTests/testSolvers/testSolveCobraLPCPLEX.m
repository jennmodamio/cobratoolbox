% The COBRAToolbox: testSolveCobraLPCPLEX.m
%
% Purpose:
%     - testSolveCobraLPCPLEX tests the SolveCobraLPCPLEX
%     function and its different methods
%
% Author:
%     - original file: Marouen BEN GUEBILA - 31/01/2017
%     - CI integration: Laurent Heirendt, February 2017
%
% Note:
%       test is performed on objective as solution can vary between machines, solver version etc..

% define global paths
global path_TOMLAB
global path_ILOG_CPLEX

% save the current path
currentDir = pwd;

% initialize the test
initTest(fileparts(which(mfilename)));

load testDataSolveCobraLPCPLEX;
load('ecoli_core_model', 'model');

tol = 1e-2;%set tolerance
ecoli_blckd_rxn = {'EX_fru(e)', 'EX_fum(e)', 'EX_gln_L(e)', 'EX_mal_L(e)',...
                   'FRUpts2', 'FUMt2_2', 'GLNabc', 'MALt2_2'}; % blocked rxn in Ecoli

%test solver packages
solverPkgs = {'tomlab_cplex', 'ILOGsimple', 'ILOGcomplex'};

for k = 1:length(solverPkgs)
    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(path_TOMLAB));
    elseif strcmp(solverPkgs{k}, 'ILOGsimple') || strcmp(solverPkgs{k}, 'ILOGcomplex')
        addpath(genpath(path_ILOG_CPLEX));
    end

    if ~verLessThan('matlab','8') && ( strcmp(solverPkgs{k}, 'ILOGcomplex') || strcmp(solverPkgs{k}, 'ILOGsimple')) %2016b
        fprintf(['\n IBM ILOG CPLEX - ', solverPkgs{k}, ' - is incompatible with this version of MATLAB, please downgrade or change solver\n'])
    elseif (~exist('tomRun')) && strcmp(solverPkgs{k}, 'tomlab_cplex')
        fprintf(['TOMLAB CPLEX is not installed.\n']);
    else
        fprintf('   Running solveCobraLPCPLEX using %s ... ', solverPkgs{k});

        % Note: Do not change the solver using changeCobraSolver()
        solTest = solveCobraLPCPLEX(model, 0, 0, 0, [], 0, solverPkgs{k});
        assert(any(abs(solTest.obj - sol.obj) < tol))

        %test minNorm
        solTest = solveCobraLPCPLEX(model, 0, 0, 0, [], 1e-6, solverPkgs{k});
        assert(isequal(ecoli_blckd_rxn, model.rxns(find(~solTest.full))'));
        assert(any(abs(solTest.obj - sol.obj) < tol));

        %test basis generation
        [solTest, basisTest] = solveCobraLPCPLEX(model, 0, 1, 0, [], 0, solverPkgs{k});
        assert(any(abs(solTest.obj - sol.obj) < tol));

        %test basis reuse
        [solTest] = solveCobraLPCPLEX(basis, 0, 1, 0, [], 0, solverPkgs{k});
        assert(any(abs(solTest.obj - sol.obj) < tol));

        % output a success message
        fprintf('Done.\n');
    end

    % remove the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        rmpath(genpath(path_TOMLAB));
    elseif strcmp(solverPkgs{k}, 'ILOGsimple') || strcmp(solverPkgs{k}, 'ILOGcomplex')
        rmpath(genpath(path_ILOG_CPLEX));
    end
end

% change the directory
cd(currentDir)