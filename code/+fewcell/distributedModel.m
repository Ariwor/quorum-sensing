%% Geometry
bactSize= [1;2]*1e-6;
bact= [4;0;0;bactSize;0];  % ellipse
domainLim= 2e-5;
%domain= [3;4;[-1;-1;1;1;-1;1;1;-1]*domainLim]; % square
d=(0:5)'*pi/3;
domain= [2;6; [cos(d); sin(d)]*domainLim];
bact= [bact;zeros(length(domain)-length(bact),1)];
geomNames= char('domain','bact')';
dl= decsg([domain,bact], 'domain+bact', geomNames);
%% PDE
numPde= 1;
model= createpde(numPde);
geometryFromEdges(model,dl);

%% Boundaries
applyBoundaryCondition(model,'neumann','Edge',1:6,'g',0,'q',0);
applyBoundaryCondition(model,'neumann','Edge',7:10,'g',0,'q',100);
%% PDE coeffs
%prodFun= @(~,st)(exp(-st.u*1e10)-0.85)*20e-6;
bacteriaTable= fewcell.BacteriaTable(1);
% d: d*u', c: -div(c*grad(u)), f: source
specifyCoefficients(model, 'Face',1, 'm',0, 'd',1, 'c',1e-9, 'a',0, 'f',0);
specifyCoefficients(model, 'Face',2, 'm',0, 'd',1, 'c',1e-9, 'a',0, 'f',@(r,s)bacteriaTable.AHLProd(r,s));
%% Initial conditions
setInitialConditions(model,0);
%{
% Plot pde domain
figure(1);
pdegplot(model,'EdgeLabels','on','FaceLabels','on');
drawnow;
axis equal;
%}
%% Mesh
mesh= generateMesh(model,'MesherVersion','R2013a','GeometricOrder','linear', ...
  'Hgrad',1.15,'Hmax',2*domainLim /1);
%{
% Plot mesh
figure(2); clf;
pdeplot(model);
drawnow;
axis equal;
%}
%% Time discretization
nframes= 200;
tlist= logspace(-3.5,-1.7,nframes);

%% Solve
fprintf('Solving...\n');
tic;
model.SolverOptions.ReportStatistics= 'off';
result= solvepde(model,tlist);
%umin= abs(2*min(result.NodalSolution(:)));
toc;

%% Plot solution
% Prepare solution interpolation
fprintf('Interpolating solution...\n');
tic;
[AHLDistrib,x,y]= fewcell.util.interpolateAHL(result,domainLim*0.8,100);
totalAHL= fewcell.util.integrateAHL(result,domainLim*0.8);
toc;
% Plot
fprintf('Plotting solution...\n');
global distribAHL_interp_graphics;
distribAHL_interp_graphics= []; distribAHL_interp_graphics.first= true;
for t=30:nframes
  tic;
  fewcell.viz.distribAHL_interp(AHLDistrib,x,y,totalAHL,result.SolutionTimes,...
    domainLim,false,3,t);
  % Control framerate
  pauseTime= 1/35 - toc;
  if pauseTime>1e-4, pause(pauseTime); end
end