clc; clear; close all;

% Improved Notch Filtering for Periodic Noise Removal in Frequency Domain

% Step 0: Read grayscale image
I = imread('Test Image.jpeg');  % Replace with your actual file
I = im2double(rgb2gray(I));
[M, N] = size(I);
figure, imshow(I, []), title('Input Image');

% Step 1: Compute FFT and shift
F = fftshift(fft2(I));
magSpec = log(1 + abs(F));
figure, imshow(magSpec, []), title('Magnitude Spectrum');

% Step 2: Define frequency grid
u = 0:N-1;
v = 0:M-1;
u = u - floor(N/2);
v = v - floor(M/2);
V_col = v(:);              % Mx1 column vector
U_row = u(:).';            % 1xN row vector

% Step 3: Get notch coordinates using ginput and shift to frequency origin
figure, imshow(magSpec, []), title('Click on Notch Centers (e.g., periodic peaks)');
[x, y] = ginput(2);  % Select 2 notch points
notch_coords = [x - floor(N/2), y - floor(M/2)];  % Adjust for fftshift origin

% Step 4: Construct Gaussian notch filter
H_notch = ones(M, N);
r = 12;  % Notch radius
for i = 1:size(notch_coords, 1)
    u0 = notch_coords(i, 1);
    v0 = notch_coords(i, 2);

    D1 = sqrt((U_row - u0).^2 + (V_col - v0).^2);
    D2 = sqrt((U_row + u0).^2 + (V_col + v0).^2);

    H_notch = H_notch .* (1 - exp(-(D1.^2) / (2 * r^2))) ...
                      .* (1 - exp(-(D2.^2) / (2 * r^2)));
end

% Step 5: Apply filter in frequency domain
F_filtered = F .* H_notch;

% Step 6: Inverse FFT to get filtered image
I_filtered = real(ifft2(ifftshift(F_filtered)));
I_filtered = mat2gray(I_filtered);  % Normalize for display

% Step 7: Display results
figure;
subplot(1, 3, 1); imshow(I, []); title('Original with Noise');
subplot(1, 3, 2); imshow(magSpec, []); title('Magnitude Spectrum');
subplot(1, 3, 3); imshow(I_filtered, []); title('Filtered Image (Notch)');

% Optional: Show filter mask
% figure, imshow(H_notch, []), title('Notch Filter Mask');
