frame_width   = 1280;
frame_height  = 720;
input_num     = frame_width*frame_height/4;
pixel_bit_num = 8; % multiple of 4

A = zeros(2,2, frame_height/2, frame_width/2);

for i = 1:(frame_height/2)
    for j = 1:(frame_width/2)
        A(:,:,i,j) = [test_R(2*i-1, 2*j-1), test_R(2*i-1, 2*j); test_R(2*i, 2*j-1), test_R(2*i, 2*j)];
    end
end

A_2 = uint8(A);
A_3 = dec2hex(A_2);  % convert all elements into a string, each element consists of two chars

str_tmp = zeros(input_num, pixel_bit_num);
str_tmp = char(str_tmp);

for i = 1:input_num
    str_tmp(i,:) = strcat(A_3(4*i-3,:), A_3(4*i-1,:), A_3(4*i-2,:), A_3(4*i,:));
end

dlmwrite('test_mat.file', str_tmp ,'delimiter','');