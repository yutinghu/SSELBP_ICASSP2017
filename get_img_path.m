function imgPath = get_img_path(file,n)
% Path of the tested database
paths = textread(file,'%s', 'delimiter', '\n','whitespace', '');
imgPath = paths{n};
end










