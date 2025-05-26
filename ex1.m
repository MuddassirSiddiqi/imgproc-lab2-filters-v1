% Lab 2 - Frequency and Spatial Filtering: STAN Image
clc; clear; close all;

% 1. Load and preprocess the image
I = imread('STAN.jpeg'); % Replace with actual file if needed
I = im2double(rgb2gray(I));
[M, N] = size(I);

% Display original image
figure, imshow(I), title('Original Image');

% 2. Compute and show magnitude spectrum
F = fftshift(fft2(I));  % Shifted FFT for visualization
magSpec1 = log(1 + abs(F));
figure, imshow(magSpec1, []), title('Magnitude Spectrum');

% 3. Design filters to remove periodic and Gaussian noise
D0 = 30;  % Gaussian low-pass cutoff
u = 0:N-1;
v = 0:M-1;
u = u - floor(N/2);
v = v - floor(M/2);
V_col = v(:);            % M×1
U_row = u(:).';          % 1×N
D = sqrt(V_col.^2 + U_row.^2);  % M×N distance matrix

% Gaussian Low-pass filter (removes Gaussian noise)
H_gaussian = exp(-(D.^2) / (2 * D0^2));

% Notch reject filter (for periodic noise)
H_notch = ones(M, N);
notch_centers = [130 100; 130 156; 198 100; 198 156]; % Sample notch points (use ginput in practice)

notch_radius = 10;
for i = 1:size(notch_centers, 1)
    % Convert coordinates to frequency-domain origin
    u0 = notch_centers(i,1) - floor(N/2);
    v0 = notch_centers(i,2) - floor(M/2);

    D1 = sqrt((U_row - u0).^2 + (V_col - v0).^2);
    D2 = sqrt((U_row + u0).^2 + (V_col + v0).^2);
    
    % Gaussian notch reject filter
    H_notch = H_notch .* (1 - exp(-(D1.^2) / (2 * notch_radius^2))) ...
                      .* (1 - exp(-(D2.^2) / (2 * notch_radius^2)));
end

% Combined filter
H_combined = H_gaussian .* H_notch;

% Optional visualization of filters
figure, imshow(H_notch, []), title('Notch Filter Mask');
figure, imshow(H_combined, []), title('Combined Frequency Filter');

% 4. Apply the combined filter in frequency domain
G = H_combined .* F;

% Show the filtered spectrum (NEW STEP)
filtered_spectrum = log(1 + abs(G));
figure, imshow(filtered_spectrum, []), title('Filtered Spectrum');

% Inverse FFT to recover filtered image
g_filtered_freq = real(ifft2(ifftshift(G)));

% 5. Apply spatial Gaussian filter as comparison
g_filtered_spatial = imgaussfilt(I, 2);  % sigma = 2

% 6. Show montage of results
figure;
montage({I, g_filtered_freq, g_filtered_spatial}, 'Size', [1 3]);
title('Original | Frequency Domain Filtered | Spatial Domain Filtered');
