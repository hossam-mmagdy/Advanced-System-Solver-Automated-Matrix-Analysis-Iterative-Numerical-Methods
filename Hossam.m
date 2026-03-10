clc; clear; close all;

disp('╔════════════════════════════════════════════════════════════════╗');
disp('║         ADVANCED LINEAR SYSTEM SOLVER  (Professional)         ║');
disp('║             6 methods · Smart recommendation                  ║');
disp('║             High precision · Interactive plots                ║');
disp('║             Save results · Step-by-step display               ║');
disp('║             Now supports CSV & Excel files!                   ║');
disp('╚════════════════════════════════════════════════════════════════╝');
fprintf('\n');

while true
    fprintf('-----------------------------------------------------------------\n');
    fprintf('STEP 1: Choose input method\n');
    fprintf('  1 – Manual entry\n');
    fprintf('  2 – From Excel file (.xlsx, .xls)\n');
    fprintf('  3 – From CSV file (.csv)\n');
    inputMethod = input('  Your choice (1/2/3): ');
    
    A = [];
    b = [];
    n = [];
    
    if inputMethod == 1
        n = input('  Number of equations (unknowns): ');
        if isempty(n) || n <= 0 || floor(n) ~= n
            disp('  Please enter a positive integer.');
            continue;
        end
        
        A = zeros(n, n);
        b = zeros(n, 1);
        fprintf('\n  Enter coefficients row by row:\n');
        for i = 1:n
            for j = 1:n
                A(i,j) = input(sprintf('    A(%d,%d): ', i, j));
            end
            b(i) = input(sprintf('    b(%d): ', i));
        end
        
    elseif inputMethod == 2 || inputMethod == 3
        if inputMethod == 2
            fileFilter = {'*.xlsx;*.xls', 'Excel files (*.xlsx,*.xls)'};
            fileType = 'Excel';
        else
            fileFilter = {'*.csv', 'CSV files (*.csv)'};
            fileType = 'CSV';
        end
        
        fileLoaded = false;
        
        [filename, pathname] = uigetfile(fileFilter, ['Select ' fileType ' file']);
        
        if isequal(filename, 0)
            disp('  File selection dialog canceled or not available.');
            disp('  Choose alternative method:');
            disp('    1 – Enter file name manually');
            disp('    2 – List files in current folder and select');
            disp('    3 – Go back to main menu');
            altMethod = input('    Your choice (1/2/3): ');
            
            if altMethod == 1
                filename = input('    Enter file name (with extension): ', 's');
                pathname = [pwd filesep];
                fullpath = fullfile(pathname, filename);
                try
                    data = readmatrix(fullpath);
                    [n, m] = size(data);
                    if m ~= n + 1
                        error('File must have n columns for A and 1 column for b');
                    end
                    A = data(:, 1:n);
                    b = data(:, n+1);
                    n = size(A,1);
                    fileLoaded = true;
                    fprintf('System successfully loaded from "%s".\n', fullpath);
                catch ME
                    fprintf('Error reading file: %s\n', ME.message);
                    disp('  Returning to main menu...');
                    continue;
                end
                
            elseif altMethod == 2
                if inputMethod == 2
                    files = dir('*.xlsx');
                    files = [files; dir('*.xls')];
                else
                    files = dir('*.csv');
                end
                
                if isempty(files)
                    disp('    No matching files found in current folder.');
                    disp('    Returning to main menu...');
                    continue;
                else
                    fprintf('    Available %s files:\n', fileType);
                    for k = 1:length(files)
                        fprintf('      %d – %s\n', k, files(k).name);
                    end
                    choice = input('    Select file number (0 to cancel): ');
                    if choice >= 1 && choice <= length(files)
                        filename = files(choice).name;
                        pathname = [files(choice).folder filesep];
                        fullpath = fullfile(pathname, filename);
                        try
                            data = readmatrix(fullpath);
                            [n, m] = size(data);
                            if m ~= n + 1
                                error('File must have n columns for A and 1 column for b');
                            end
                            A = data(:, 1:n);
                            b = data(:, n+1);
                            n = size(A,1);
                            fileLoaded = true;
                            fprintf('System successfully loaded from "%s".\n', fullpath);
                        catch ME
                            fprintf('Error reading file: %s\n', ME.message);
                            disp('  Returning to main menu...');
                            continue;
                        end
                    else
                        disp('    Cancelled. Returning to main menu...');
                        continue;
                    end
                end
                
            else
                disp('  Returning to main menu...');
                continue;
            end
        else
            fullpath = fullfile(pathname, filename);
            try
                data = readmatrix(fullpath);
                [n, m] = size(data);
                if m ~= n + 1
                    error('File must have n columns for A and 1 column for b');
                end
                A = data(:, 1:n);
                b = data(:, n+1);
                n = size(A,1);
                fileLoaded = true;
                fprintf('System successfully loaded from "%s".\n', fullpath);
            catch ME
                fprintf('Error reading file: %s\n', ME.message);
                disp('  Returning to main menu...');
                continue;
            end
        end
        
        if ~fileLoaded
            continue;
        end
    else
        disp('  Invalid choice. Please try again.');
        continue;
    end
    
    fprintf('\nYour system:\n');
    for i = 1:n
        eq = '';
        for j = 1:n
            if A(i,j) ~= 0
                if j > 1 && A(i,j) > 0
                    eq = [eq ' + '];
                elseif j > 1 && A(i,j) < 0
                    eq = [eq ' - '];
                elseif j == 1 && A(i,j) < 0
                    eq = [eq '-'];
                end
                if abs(A(i,j)) ~= 1
                    eq = [eq num2str(abs(A(i,j))) '*'];
                end
                eq = [eq sprintf('x%d', j)];
            end
        end
        eq = [eq ' = ' num2str(b(i))];
        disp(eq);
    end
    
    fprintf('\nAnalyzing matrix properties...\n');
    
    condA = cond(A);
    fprintf('   Condition number: %g\n', condA);
    if condA > 1e12
        disp('   Extremely ill-conditioned. Use SVD or high precision.');
    elseif condA > 1e6
        disp('   Ill-conditioned. Results may be sensitive.');
    else
        disp('   Well-conditioned.');
    end
    
    diagDominant = all(2*abs(diag(A)) > sum(abs(A),2));
    if diagDominant
        disp('   Diagonally dominant -> iterative methods converge.');
    else
        disp('   Not diagonally dominant -> iterative methods may diverge.');
    end
    
    zeroDiag = any(abs(diag(A)) < eps);
    if zeroDiag
        disp('   Zero diagonal entries -> Jacobi/Gauss-Seidel not suitable.');
    end
    
    isSym = norm(A - A', inf) < 1e-12;
    isPosDef = false;
    if isSym && n <= 100
        try
            isPosDef = all(eig(A) > 0);
        catch
        end
    end
    if isSym && isPosDef
        disp('   Symmetric positive definite -> Conjugate Gradient ideal.');
    end
    
    fprintf('\nRecommendation: ');
    if zeroDiag
        rec = 1;
        fprintf('Use LU decomposition (direct, handles zero diagonal).\n');
    elseif n <= 3
        rec = 4;
        fprintf('Use Cramer''s rule (simple and direct for n <= 3).\n');
    elseif n > 1000 && diagDominant
        rec = 3;
        fprintf('Use Gauss-Seidel (fast, memory-efficient for large diagonally dominant systems).\n');
    elseif n > 1000
        rec = 2;
        fprintf('Use Jacobi (simpler iterative method).\n');
    elseif isSym && isPosDef
        rec = 6;
        fprintf('Use Conjugate Gradient (exploits symmetry & definiteness).\n');
    elseif condA > 1e12
        rec = 5;
        fprintf('Use SVD (robust for ill-conditioned matrices).\n');
    else
        rec = 1;
        fprintf('Use LU decomposition (general purpose, direct).\n');
    end
    
    fprintf('\n-----------------------------------------------------------------\n');
    fprintf('STEP 2: Choose solution method (recommended: %d)\n', rec);
    disp('  1 – LU decomposition (general, direct)');
    disp('  2 – Jacobi iteration (simple iterative)');
    disp('  3 – Gauss-Seidel iteration (faster than Jacobi)');
    disp('  4 – Cramer''s rule (only for n <= 5)');
    disp('  5 – SVD (singular/ill-conditioned matrices)');
    disp('  6 – Conjugate Gradient (symmetric positive definite)');
    method = input('  Your choice (1-6): ');
    while ~ismember(method, 1:6)
        method = input('  Invalid. Please enter 1-6: ');
    end
    
    fprintf('\n-----------------------------------------------------------------\n');
    fprintf('STEP 3: Configure advanced options\n');
    useHighPrecision = false;
    showSteps = false;
    saveResults = false;
    interactivePlots = false;
    useSparse = false;
    
    adv = input('  Would you like to configure advanced settings? (y/n): ', 's');
    if strcmpi(adv, 'y')
        useHighPrecision = input('    Use high precision (vpa, requires Symbolic Toolbox)? (y/n): ', 's') == 'y';
        showSteps = input('    Show detailed solution steps? (y/n): ', 's') == 'y';
        saveResults = input('    Save results to a folder? (y/n): ', 's') == 'y';
        interactivePlots = input('    Use interactive plots (zoom/rotate)? (y/n): ', 's') == 'y';
        if n > 500
            useSparse = input('    Use sparse matrix format (for large systems)? (y/n): ', 's') == 'y';
        end
    end
    
    if useSparse
        A = sparse(A);
        b = sparse(b);
    end
    
    if useHighPrecision
        try
            digits(50);
            A = vpa(A);
            b = vpa(b);
        catch
            disp('Symbolic Toolbox not available. High precision disabled.');
            useHighPrecision = false;
        end
    end
    
    fprintf('\n-----------------------------------------------------------------\n');
    fprintf('Solving...\n');
    tic;
    
    try
        switch method
            case 1
                if showSteps, disp('--- LU Decomposition ---'); end
                [L, U, P] = lu(A);
                if showSteps
                    disp('L ='); disp(L);
                    disp('U ='); disp(U);
                    disp('P (permutation) ='); disp(P);
                end
                y = L \ (P * b);
                x = U \ y;
                methodName = 'LU decomposition';
                
            case 2
                tol = input('    Tolerance (default 1e-6): ');
                if isempty(tol), tol = 1e-6; end
                maxit = 10000;
                if useHighPrecision, tol = vpa(tol); end
                [x, iter, errHist, success] = jacobi_solve(A, b, tol, maxit, showSteps);
                if success
                    fprintf('    Converged in %d iterations.\n', iter);
                else
                    fprintf('    Did NOT converge in %d iterations.\n', maxit);
                end
                methodName = 'Jacobi';
                
            case 3
                tol = input('    Tolerance (default 1e-6): ');
                if isempty(tol), tol = 1e-6; end
                maxit = 10000;
                if useHighPrecision, tol = vpa(tol); end
                [x, iter, errHist, success] = gauss_seidel_solve(A, b, tol, maxit, showSteps);
                if success
                    fprintf('    Converged in %d iterations.\n', iter);
                else
                    fprintf('    Did NOT converge in %d iterations.\n', maxit);
                end
                methodName = 'Gauss-Seidel';
                
            case 4
                if n > 5
                    error('Cramer''s rule is impractical for n > 5.');
                end
                x = cramer_solve(A, b);
                methodName = 'Cramer''s rule';
                
            case 5
                if showSteps, disp('--- SVD Decomposition ---'); end
                [U, S, V] = svd(A);
                if showSteps
                    disp('U ='); disp(U);
                    disp('S ='); disp(S);
                    disp('V ='); disp(V);
                end
                s = diag(S);
                tolSVD = max(size(A)) * eps(norm(s, inf));
                r = sum(s > tolSVD);
                s_inv = zeros(size(s));
                s_inv(1:r) = 1 ./ s(1:r);
                x = V * diag(s_inv) * (U' * b);
                methodName = 'SVD';
                
            case 6
                if ~isSym || ~isPosDef
                    error('CG requires symmetric positive definite matrix.');
                end
                tol = input('    Tolerance (default 1e-6): ');
                if isempty(tol), tol = 1e-6; end
                maxit = min(1000, n);
                [x, iter, success] = cg_solve(A, b, tol, maxit);
                if success
                    fprintf('    Converged in %d iterations.\n', iter);
                else
                    fprintf('    Did NOT converge in %d iterations.\n', maxit);
                end
                methodName = 'Conjugate Gradient';
        end
        
        elapsedTime = toc;
        
        residual = A*x - b;
        if useHighPrecision
            res_norm = double(norm(residual));
        else
            res_norm = norm(residual);
        end
        
        fprintf('\nSolution (%s) obtained in %.4f seconds:\n', methodName, elapsedTime);
        if useHighPrecision
            for i = 1:n
                fprintf('   x%d = %s\n', i, char(x(i)));
            end
        else
            for i = 1:n
                fprintf('   x%d = %g\n', i, x(i));
            end
        end
        fprintf('\nResidual norm: %g\n', res_norm);
        
        if saveResults
            timestamp = datestr(now, 'yyyymmdd_HHMMSS');
            folderName = ['Results_' timestamp];
            mkdir(folderName);
            
            save(fullfile(folderName, 'workspace.mat'));
            
            fid = fopen(fullfile(folderName, 'solution.txt'), 'w');
            fprintf(fid, 'Solution using %s\n', methodName);
            fprintf(fid, 'Time: %.4f s\n', elapsedTime);
            fprintf(fid, 'Residual norm: %g\n', res_norm);
            for i = 1:n
                if useHighPrecision
                    fprintf(fid, 'x%d = %s\n', i, char(x(i)));
                else
                    fprintf(fid, 'x%d = %g\n', i, x(i));
                end
            end
            fclose(fid);
            
            if n == 2 || n == 3
                saveas(gcf, fullfile(folderName, 'geometry.png'));
            end
            
            fprintf('Results saved in folder: %s\n', folderName);
        end
        
        if n == 2
            fig = figure('Name', '2D System', 'NumberTitle', 'off');
            plot_2D_system(A, b, x, useHighPrecision);
            if interactivePlots
                zoom on; pan on; datacursormode on;
            end
        elseif n == 3
            fig = figure('Name', '3D System', 'NumberTitle', 'off');
            plot_3D_system(A, b, x, useHighPrecision);
            if interactivePlots
                rotate3d on; zoom on; pan on; datacursormode on;
            end
        end
        
        show_extra = input('\nWould you like to see additional plots? (y/n): ', 's');
        if strcmpi(show_extra, 'y')
            extra_plot_menu(n, x, residual, method, iter, errHist, interactivePlots, useHighPrecision);
        end
        
    catch ME
        elapsedTime = toc;
        fprintf('Error: %s\n', ME.message);
        fprintf('   (Time to error: %.4f s)\n', elapsedTime);
    end
    
    again = input('\nSolve another system? (y/n): ', 's');
    if strcmpi(again, 'n')
        break;
    end
end

fprintf('\nThank you for using the Advanced Linear System Solver. Goodbye!\n');

function [x, iter, err_hist, success] = jacobi_solve(A, b, tol, maxit, showSteps)
    n = length(b);
    x = zeros(n, 1);
    x_new = zeros(n, 1);
    err_hist = zeros(maxit, 1);
    
    if any(abs(diag(A)) < eps)
        error('Jacobi requires non-zero diagonal entries. Reorder equations or use another method.');
    end
    
    success = false;
    for iter = 1:maxit
        for i = 1:n
            sum1 = A(i,:) * x - A(i,i) * x(i);
            x_new(i) = (b(i) - sum1) / A(i,i);
        end
        err = norm(x_new - x, inf);
        err_hist(iter) = err;
        if showSteps && mod(iter,10)==0
            fprintf('   Iter %d: err = %g\n', iter, err);
        end
        if err < tol
            x = x_new;
            success = true;
            err_hist = err_hist(1:iter);
            return;
        end
        x = x_new;
    end
    err_hist = err_hist(1:maxit);
end

function [x, iter, err_hist, success] = gauss_seidel_solve(A, b, tol, maxit, showSteps)
    n = length(b);
    x = zeros(n, 1);
    err_hist = zeros(maxit, 1);
    
    if any(abs(diag(A)) < eps)
        error('Gauss-Seidel requires non-zero diagonal entries.');
    end
    
    success = false;
    for iter = 1:maxit
        x_old = x;
        for i = 1:n
            sum1 = A(i,1:i-1) * x(1:i-1) + A(i,i+1:n) * x_old(i+1:n);
            x(i) = (b(i) - sum1) / A(i,i);
        end
        err = norm(x - x_old, inf);
        err_hist(iter) = err;
        if showSteps && mod(iter,10)==0
            fprintf('   Iter %d: err = %g\n', iter, err);
        end
        if err < tol
            success = true;
            err_hist = err_hist(1:iter);
            return;
        end
    end
    err_hist = err_hist(1:maxit);
end

function x = cramer_solve(A, b)
    n = length(b);
    detA = det(A);
    if abs(detA) < eps
        error('Matrix is singular (determinant = 0).');
    end
    x = zeros(n, 1);
    for i = 1:n
        Ai = A;
        Ai(:, i) = b;
        x(i) = det(Ai) / detA;
    end
end

function [x, iter, success] = cg_solve(A, b, tol, maxit)
    n = length(b);
    x = zeros(n, 1);
    r = b - A * x;
    p = r;
    rsold = r' * r;
    
    success = false;
    for iter = 1:maxit
        Ap = A * p;
        alpha = rsold / (p' * Ap);
        x = x + alpha * p;
        r = r - alpha * Ap;
        rsnew = r' * r;
        if sqrt(rsnew) < tol
            success = true;
            return;
        end
        p = r + (rsnew / rsold) * p;
        rsold = rsnew;
    end
end

function plot_2D_system(A, b, x, useHighPrecision)
    if useHighPrecision
        A = double(A);
        b = double(b);
        x = double(x);
    end
    hold on;
    x_vals = linspace(-10, 10, 100);
    colors = lines(2);
    for i = 1:2
        if abs(A(i,2)) > 1e-12
            y_vals = (b(i) - A(i,1)*x_vals) / A(i,2);
            plot(x_vals, y_vals, 'Color', colors(i,:), 'LineWidth', 2, ...
                'DisplayName', sprintf('Eq %d: %.3g x1 + %.3g x2 = %.3g', i, A(i,1), A(i,2), b(i)));
        else
            x_line = b(i)/A(i,1) * ones(size(x_vals));
            plot(x_line, x_vals, 'Color', colors(i,:), 'LineWidth', 2, ...
                'DisplayName', sprintf('Eq %d: %.3g x1 = %.3g', i, A(i,1), b(i)));
        end
    end
    plot(x(1), x(2), 'ro', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Solution');
    xlabel('x_1');
    ylabel('x_2');
    title('2D System');
    legend('Location','best');
    grid on;
    hold off;
end

function plot_3D_system(A, b, x, useHighPrecision)
    if useHighPrecision
        A = double(A);
        b = double(b);
        x = double(x);
    end
    hold on;
    [X, Y] = meshgrid(linspace(-10, 10, 30));
    colors = lines(3);
    for i = 1:3
        if abs(A(i,3)) > 1e-12
            Z = (b(i) - A(i,1)*X - A(i,2)*Y) / A(i,3);
            surf(X, Y, Z, 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'FaceColor', colors(i,:), ...
                'DisplayName', sprintf('Eq %d', i));
        else
            Z = linspace(-10, 10, 30);
            [Xq, Zq] = meshgrid(linspace(-10,10,30), Z);
            Yq = (b(i) - A(i,1)*Xq) / A(i,2);
            surf(Xq, Yq, Zq, 'FaceAlpha', 0.5, 'EdgeColor', 'none', 'FaceColor', colors(i,:), ...
                'DisplayName', sprintf('Eq %d', i));
        end
    end
    plot3(x(1), x(2), x(3), 'ro', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Solution');
    xlabel('x_1');
    ylabel('x_2');
    zlabel('x_3');
    title('3D System');
    legend('Location','best');
    grid on;
    view(3);
    hold off;
end

function extra_plot_menu(n, x, residual, method, iter_used, errHist, interactive, useHighPrecision)
    if useHighPrecision
        x = double(x);
        residual = double(residual);
        errHist = double(errHist);
    end
    
    while true
        fprintf('\n--- Additional Plots ---\n');
        fprintf('  1 – Bar chart of solution values\n');
        fprintf('  2 – Bar chart of residuals (A*x - b)\n');
        if (method == 2 || method == 3) && ~isempty(iter_used) && exist('errHist','var') && ~isempty(errHist)
            fprintf('  3 – Convergence history (iterative method)\n');
        end
        fprintf('  0 – Return to main menu\n');
        choice = input('  Select plot (0 to exit): ');
        
        switch choice
            case 1
                figure('Name', 'Solution Bar Chart', 'NumberTitle', 'off');
                bar(x, 'FaceColor', [0.2 0.6 0.9]);
                xlabel('Unknown index');
                ylabel('Value');
                title('Solution Vector');
                xticks(1:n);
                xticklabels(arrayfun(@(k) sprintf('x_%d', k), 1:n, 'UniformOutput', false));
                grid on;
                if interactive, datacursormode on; end
                
            case 2
                figure('Name', 'Residual Bar Chart', 'NumberTitle', 'off');
                bar(residual, 'FaceColor', [0.9 0.3 0.3]);
                xlabel('Equation index');
                ylabel('Residual');
                title('Residuals A*x - b');
                xticks(1:n);
                grid on;
                if interactive, datacursormode on; end
                
            case 3
                if (method == 2 || method == 3) && exist('errHist','var') && ~isempty(errHist)
                    figure('Name', 'Convergence History', 'NumberTitle', 'off');
                    semilogy(1:length(errHist), errHist, 'b-o', 'LineWidth', 1.5);
                    xlabel('Iteration');
                    ylabel('Error (infinity norm)');
                    title('Convergence History');
                    grid on;
                    if interactive, datacursormode on; end
                else
                    disp('  No convergence history available.');
                end
                
            case 0
                break;
                
            otherwise
                disp('  Invalid choice. Please try again.');
        end
    end
end