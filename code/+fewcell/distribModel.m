% 4th QS model: model a petri dish as a cylinder and solve on 2D due to
% angular symmetry. Algebraically transform the resulting diffusion equation
% to form an equivalent 2d cartesian problem with radial coefficients
% - Help topic: "Heat Distribution in a Circular Cylindrical Rod"
clear params;
%% Parameters
% Units:
% Molarity: nM, Time: min, Length: mm, Quantity: fmol (nM*mm^3)
runID= randi(2147483644);
global enableSinglecellEq; enableSinglecellEq= true;
% time
params.t.tstop= 60*1;   % min
params.t.tstart= 0;
params.t.timePoints= 30;
% coefficients
%params.c.c_agar= 7.1e-5*60;                 % [mm^2/min]
params.c.c_agar= 30e-5*60;
params.c.c_cytoplasm= 50e-5*60;            % [mm^2/min]
params.c.d_AHL= 7e-5;                      % [1/min]
params.c.bactMperm= 10;                    % [1/min]
% geometry
params.g.nRings= 1; params.g.nLayers= 1;
params.g.ringDist= .5*1e-3; params.g.layerSeparation= 1*1e-3;
params.g.lateralSpacing= .1e-3;  % spacing between the membranes of adjacent bacteria in a ring
params.g.bactCenter0= 1e-3*[2,-2.5];
params.g.bactSize= 1e-3*[1,2.164];
%params.g.domainLim= [17,5.51];     % small disk
params.g.domainLim= [1.7,.551];     % xs
% mesh
params.m.Hgrad= 1.4;
params.m.HmaxCoeff= 1/10;
% init
params.solve.y0= [1.6;0;0;0;0; 0;0;0];  % [nM]
% solve
params.solve.AbsTol_y= [1e-5,1e-6,1e-5,1e-3,1e-3,  1e-6,1e-6,1e-6]*1e-1;
params.solve.AbsTol= 1e-2;    % for diffusion nodes
params.solve.RelTol= 1e-4;
params.solve.FeatureSize= min(params.g.bactSize)/4;
% viz
params.viz.showMesh= true;
params.viz.domLim= [0.02,0.01];
params.viz.zoominFactor= params.g.domainLim./params.viz.domLim;
params.viz.interpResolution= 130;
params.viz.integrateAbstol= 1;
params.viz.timePoints= floor(params.t.timePoints/3);
params.viz.dynamicScaling= true;
params.viz.logscaleSinglecell= false;
params.viz.figID= [3,4,5];

%% Solve
[params,model,tlist,domainVolume]= fewcell.problemSetup(params,params.viz.showMesh);
fprintf('--> Solving...\n');
result= fewcell.solveProblem(model,tlist,params);

%% Plot solution
% Prepare solution interpolation
fprintf('--> Interpolating solution...\n');
[AHLDistrib,x,y,interp_t,totalAHL]= ...
  fewcell.util.interpolateIntegrateAHL(model,result,params);
% Plot
if params.viz.figID(1), fprintf('--> [paused] Press key to plot the solution\n'); pause; end
fprintf('--> Plotting solution...\n');
fewcell.output(model,result,tlist,...
               AHLDistrib,x,y,interp_t,totalAHL,params.viz);
