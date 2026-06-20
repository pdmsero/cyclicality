% run_dynare.m -- solve the cyclicality firm-level R&D model in Dynare 6.5 for
% all four gamma calibrations, confirm the Blanchard-Kahn rank condition, and
% write the reference IRFs (to the TFP shock e) for the engine cross-check.
%
% Usage (MATLAB, Dynare 6.5 on the path):
%   addpath('/Applications/Dynare/6.5-arm64/matlab'); run_dynare
%
% Writes <model>_irf.csv for each calibration; engine_crosscheck.py compares
% the aether-macro perturbation engine against these.

here = fileparts(mfilename('fullpath')); cd(here);
models = {'cyclicality_g05','cyclicality_g10','cyclicality_g15','cyclicality_g20'};

fprintf('\n==== Dynare solve + Blanchard-Kahn check ====\n');
for k = 1:numel(models)
  m = models{k};
  clear oo_ M_ options_;
  % dynare errors out if Blanchard-Kahn fails, so reaching the next line == BK ok
  evalin('base', sprintf('dynare %s noclearall nolog nograph', m));
  oo = evalin('base','oo_'); M = evalin('base','M_');

  % steady-state residual (max abs over static equations)
  resid = evalin('base', 'oo_.steady_state;');  %#ok<NASGU>  (ensure SS exists)
  % report the largest dynamic eigenvalue modulus and BK counts
  ev = sort(abs(oo.dr.eigval));
  n_explosive = sum(abs(oo.dr.eigval) > 1 + 1e-9);
  n_forward   = M.nsfwrd;        % number of forward-looking variables
  n_state     = M.nspred;        % number of predetermined states
  bk_ok = (n_explosive == n_forward);
  bk_str = 'FAILED'; if bk_ok, bk_str = 'VERIFIED'; end
  fprintf('%-18s : states=%d forward=%d explosive=%d  BK rank %s\n', ...
          m, n_state, n_forward, n_explosive, bk_str);

  % write IRFs (all endogenous vars to shock e)
  vn = M.endo_names; en = M.exo_names;
  T = []; cols = {};
  for s = 1:numel(en)
    for v = 1:numel(vn)
      f = [vn{v} '_' en{s}];
      if isfield(oo.irfs, f), T = [T, oo.irfs.(f)(:)]; cols{end+1} = f; end %#ok<AGROW>
    end
  end
  writetable(array2table(T,'VariableNames',cols), [m '_irf.csv']);
  fprintf('%-18s : wrote %d IRF columns\n', m, numel(cols));
end
fprintf('==== done ====\n');
