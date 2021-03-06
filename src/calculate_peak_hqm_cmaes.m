function [peak_hqm] = calculate_peak_hqm_cmaes(x, p)
% CALCULATE_PEAK_HQM_CMAES - Returns the maximum value of the HQM transfer
% function magnitude or a large psuedo HQM value if the constraints are not
% met.
%
% Syntax: peak_hqm = calculate_peak_hqm_cmaes(x, p)
%
% Inputs:
%   x - 23x1 double, vector of the optimization parameters
%   p - structure containing the principal parameters
% Outputs:
%   peak_hqm - Maximum scalar value of the HQM magnitude.

display(sprintf(repmat('=', 1, 79)))
display('Values passed into the objective function:')
x'

p = update_principal_parameters(p, x);
b = convert_principal_to_benchmark(p);

[A, B, C, D] = whipple_pull_force_abcd(b, b.v);

data = generate_data('Browser', b.v, ...
                     'simulate', false, ...
                     'forceTransfer', {}, ...
                     'fullSystem', false, ...
                     'stateSpace', {A, B, C, D}, ...
                     'display', 0);
lateral_dev_loop = minreal(tf(data.closedLoops.Y.num, ...
                              data.closedLoops.Y.den));
real_evals = real(pole(lateral_dev_loop));

constraints = compute_constraints(x, p, real_evals);
display('Constraints:')
constraints'

if any(constraints > 0.0)
    % NOTE : This is a cheat to try to enforce the constraints. If any
    % constraints are every positive the lowest HQM is slightly larger than
    % Jason + Browser default parameters at 3.0 m/s. But it will also output
    % larger HQMs if the constraints are very positive. This means the
    % optimizer must find that all constraints are negative to get anything
    % below the initial HQM value.
    mag_con = 10*sqrt(sum(constraints(constraints > 0).^2));
    if (mag_con < 30.0)
    	peak_hqm = 30.0 + mag_con/10;
    else
	peak_hqm = mag_con;
    end
else
    hqm_num = data.handlingMetric.num;
    hqm_den = data.handlingMetric.den;
    freqs = linspace(0.01, 40, 200);
    [mag, ~, ~] = bode(tf(hqm_num, hqm_den), freqs);
    peak_hqm = max(mag);
end

display('Value of the objective function:')
peak_hqm
display(sprintf(repmat('=', 1, 79)))
