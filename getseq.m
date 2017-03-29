%This function generate a seq.txt by parsing images.txt file
%in sfm_results, which retrieve the image list that used to
%generate the corresponding sfm result

function getseq(sfm_results)

input_file=fullfile(sfm_results,'images.txt');

fid = fopen(input_file,'r');

tline=fgets(fid);

is_camera_line= false;

count=1;

while ischar(tline)
    if (tline(1)=='#')
        tline=fgets(fid);
        continue;
    end
    
    is_camera_line= ~is_camera_line;
    if (is_camera_line)
        C=strsplit(tline);

        if length(C)>3
            im_names{count}=C{end-1};
        
            im_ids(count)=str2num(C{1});
        
            count=count+1;
        end
    end
    
    tline=fgets(fid);
end

[~,idx]=sort(im_ids);
im_names=im_names(idx);

fidw=fopen(fullfile(sfm_results,'seq.txt'),'w');

for i = 1:count-1
    fprintf(fidw,'%s\n',im_names{i});
end

fclose(fid);
fclose(fidw);



