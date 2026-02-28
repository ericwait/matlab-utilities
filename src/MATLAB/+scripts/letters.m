% Create combined E and W surface
[X, Y, Z] = Art.combine_letters({'E', 'W'}, 300, 0.75);

% Clip Z values - set zeros to NaN so they don't render
Z_clipped = Z;
Z_clipped(Z < 0.1) = NaN; % Adjust threshold as needed


% Downsample for coarse mesh visualization
height_factor = 1.0;
coarse_factor = 2; % Adjust this for mesh density (higher = coarser)
X_coarse = X(1:coarse_factor:end, 1:coarse_factor:end);
Y_coarse = Y(1:coarse_factor:end, 1:coarse_factor:end);
Z_coarse = Z_clipped(1:coarse_factor:end, 1:coarse_factor:end) .* height_factor;

% Render with mesh edges colored by height
figure('Color', 'k', 'Position', [100 100 1200 600]);
h = mesh(X_coarse, Y_coarse, Z_coarse);
set(h, 'FaceColor', 'interp', 'FaceAlpha', 0.6); % 0.6 = 60% opaque
colormap("winter");
lighting gouraud;
camlight('left');
% camlight('right');
% material([0.4 0.6 0.3 5 0.5]);
material("shiny")
axis equal tight off;
% view([-37.5, 30]);
% title('Embossed Letters E and W', 'FontSize', 14);
% xlabel('X'); ylabel('Y'); zlabel('Height');
grid off;
set(gca, 'CameraPosition', [0.0756   -1.3900    9.6384])