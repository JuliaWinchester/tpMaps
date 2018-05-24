function touch(dir_string)
%TOUCH Summary of this function goes here
%   Detailed explanation goes here

disp(dir_string);
disp(class(dir_string));

if ~exist(dir_string, 'dir')
    mkdir(dir_string);
end

end

