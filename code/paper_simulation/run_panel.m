% Solve the paper's four partial-equilibrium calibrations and write the actual
% first-order Dynare simulation panels (no digitized or target-fitted points).
%
% Before running: generate the .mod files with generate_dynare.py. The annual
% firm TFP parameters come from the cited Imrohoroglu-Tuzel calibration.

function run_panel()
  here = fileparts(mfilename('fullpath'));
  generated = fullfile(here, 'generated');
  addpath('/Applications/Dynare/6.5-arm64/matlab');
  addpath(generated);
  cd(generated);
  files = {'paper_partial_eq_g05','paper_partial_eq_g10', ...
           'paper_partial_eq_g15','paper_partial_eq_g20'};
  n_firms = 1000;
  n_periods = 200;
  rng(20261005, 'twister');

  for j = 1:numel(files)
    model_name = files{j};
    eval(sprintf('dynare %s noclearall nolog nograph', model_name));
    model = evalin('base', 'M_');
    opts = evalin('base', 'options_');
    results = evalin('base', 'oo_');
    names = cellstr(model.endo_names);
    idx_y = find(strcmp(names, 'y'));
    idx_labor = find(strcmp(names, 'labor'));
    idx_rev = find(strcmp(names, 'revenue'));
    idx_k = find(strcmp(names, 'k'));
    idx_invest = find(strcmp(names, 'invest'));
    idx_z = find(strcmp(names, 'z'));
    idx_p = find(strcmp(names, 'innov_prob'));
    if any(cellfun(@isempty, {idx_y, idx_labor, idx_rev, idx_k, idx_invest, idx_z, idx_p}))
      error('Missing expected endogenous variable in %s.', model_name);
    end

    total = n_periods;
    rows = cell(n_firms, 1);
    for firm = 1:n_firms
      shocks = randn(total, model.exo_nbr) * sqrt(model.Sigma_e(1,1));
      path = simult_(model, opts, results.dr.ys, results.dr, shocks, 1);
      path = path(:, 2:end); % omit steady initial condition
      path = exp(path);       % Dynare loglinear decision rule returns log levels
      ytilde = path(idx_y, :);
      revtilde = path(idx_rev, :);
      ztilde = path(idx_z, :);
      prob = path(idx_p, :);
      if any(ztilde <= 0) || any(prob < 0 | prob > 1)
        error(['First-order path left the feasible R&D/probability domain in ' ...
               '%s, firm %d. No clipping or fabricated points applied.'], model_name, firm);
      end

      q = ones(1, total);
      for t = 1:total-1
        q(t+1) = q(t) * (1 + (model.params(strcmp(cellstr(model.param_names), 'lambda'))-1) ...
                           * (rand < prob(t)));
      end
      keep = 1:total;
      rows{firm} = table(repmat(firm, n_periods, 1), (1:n_periods)', ...
          ytilde(keep)', revtilde(keep)'.*q(keep)', ztilde(keep)'.*q(keep)', ...
          path(idx_k,keep)', path(idx_labor,keep)', path(idx_invest,keep)', ...
          ztilde(keep)', q(keep)', log(path(find(strcmp(names,'omega')),keep))', ...
          'VariableNames', {'firm','period','output_stationary','sales','rnd', ...
                            'capital_stationary','labor_stationary','investment_stationary', ...
                            'rnd_stationary','quality','log_tfp'});
    end
    panel = vertcat(rows{:});
    writetable(panel, [model_name '_panel.csv']);
    fprintf('%s: wrote %d firms x %d periods (%d observations)\n', ...
            model_name, n_firms, n_periods, height(panel));
  end
end
