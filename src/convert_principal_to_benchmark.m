function benchmark_par = convert_principal_to_benchmark(principal_par)
% CONVERT_PRINCIPAL_TO_BENCHMARK - Returns a structure containing the
% benchmark bicycle parameters as defined in Meijaard2007 which are
% converted from the principal parameters as defined in MooreHubbard2019.
%
% Syntax: benchmark_par = convert_principal_to_benchmark(principal_par)
%
% Inputs:
%   principal_par - Structure containing parameter names mapped to doubles.
% Outputs:
%   benchmark_par - Structure containing parameter names mapped to doubles.

p = principal_par;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% primary geometry, gravity, and speed
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b.w = p.w;
b.c = p.c;
b.lam = p.lam;
b.g = p.g;
b.v = p.v;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rear frame [B]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b.mB = p.mD + p.mP;
Bcom = combine_mass_centers([p.mD, p.mP], ...
                            [[p.xD; p.yD; p.zD], [p.xP; p.yP; p.zP]]);
b.xB = Bcom(1, 1);
b.yB = Bcom(2, 1);
b.zB = Bcom(3, 1);

% symmetry is assumed about the XZ plane
ID_principal = p.mD*diag([p.kDaa^2, p.kDyy^2, p.kDbb^2]);
IDxyz = rotate_inertia_about_y(ID_principal, -p.alphaD);

% person
% NOTE : The max/min calls ensure that alphaP is always measured wrt to the
% maximum principal axes in the xz plane. This has bearing on whether the
% constraint that ensures the rider is above the ground functions correctly.
IP_principal = p.mP*diag([max(p.kPaa, p.kPbb)^2, p.kPyy^2, min(p.kPaa, p.kPbb)^2]);
IPxyz = rotate_inertia_about_y(IP_principal, -p.alphaP);

% combined rear frame and person
IBxyz = sum_central_inertias(p.mD, [p.xD; p.yD; p.zD], IDxyz, ...
                             p.mP, [p.xP; p.yP; p.zP], IPxyz);
b.IBxx = IBxyz(1, 1);
b.IByy = IBxyz(2, 2);
b.IBzz = IBxyz(3, 3);
b.IBxz = IBxyz(1, 3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% front frame [H]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b.mH = p.mH;
b.xH = p.xH;
b.yH = p.yH;
b.zH = p.zH;

% symmetry is assumed about the XZ plane
IH123 = p.mH*diag([p.kHaa^2, p.kHyy^2, p.kHbb^2]);
IH = rotate_inertia_about_y(IH123, -p.alphaH);
b.IHxx = IH(1, 1);
b.IHyy = IH(2, 2);
b.IHzz = IH(3, 3);
b.IHxz = IH(1, 3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rear wheel [R]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b.rR = p.rR;
b.mR = p.mR;
% wheel is symmetric about XY, YZ, and XZ planes, thus no products of
% inertia, wheel is ring or disc like, thus Ixx=Izz and Iyy > Ixx
b.IRxx = p.mR * p.kR22^2;
b.IRyy = p.mR * p.kR11^2;
b.IRzz = p.mR * p.kR33^2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% front wheel [F]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b.rF = p.rF;
b.mF = p.mF;
% wheel is symmetric about XY, YZ, and XZ planes, thus no prodcuts of
% inertia, wheel is always ring or disc like, thus Ixx=Izz and Iyy > Ixx
b.IFxx = p.mF * p.kF22^2;
b.IFyy = p.mF * p.kF11^2;
b.IFzz = p.mF * p.kF33^2;

% return the benchmark parameters
benchmark_par = b;
