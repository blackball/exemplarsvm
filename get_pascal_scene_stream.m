function fg = get_pascal_scene_stream(set_name, cls, VOCopts, MAXLENGTH)
%Create a scene stream, such that each element fg{i} contains
%these fields: (I, bbox, cls, curid, [objectid], [anno])

basedir = sprintf('%s/scene-streams/',VOCopts.localdir);
if ~exist(basedir,'dir')
  mkdir(basedir);
end
streamname = sprintf('%s/%s-%s.mat',basedir,set_name,cls);
if fileexists(streamname)
  fprintf(1,'Loading %s\n',streamname);
  load(streamname);
  return;
end

%The maximum number of exemplars to process
if ~exist('MAXLENGTH','var')
  MAXLENGTH = 1000000;
end

%% Load ids of all images in trainval that contain cls
[ids,gt] = textread(sprintf(VOCopts.clsimgsetpath,cls,set_name),...
                  '%s %d');
ids = ids(gt==1);

fg = cell(0,1);

for i = 1:length(ids)
  curid = ids{i};

  recs = PASreadrecord(sprintf(VOCopts.annopath,curid));  
  filename = sprintf(VOCopts.imgpath,curid);
  
  fprintf(1,'.');
  
  res.I = filename;

  res.bbox = [1 1 recs.imgsize(1) recs.imgsize(2)];
  %res.bbox = recs.objects(objectid).bbox;
  res.cls = cls;
  res.objectid = i;
  
  %size(convert_to_I(res.I))
  %res.bbox



  
  %anno is the data-set-specific version
  res.anno = recs.objects;
  
  res.filer = sprintf('%s.%d.%s.mat', curid, res.objectid, cls);
  
  fg{end+1} = res;
  
  if length(fg) == MAXLENGTH
    save(streamname,'fg');
    return;
    
  end
end

save(streamname,'fg');