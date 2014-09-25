function Url=GetUrl2(ThisStorm,ThisAdvisory,ThisGrid,ThisMachine,ThisInstance,UrlBase,TheCatalog,CatalogEntryPoint)


%%
%%% Determine starting URL based in Instance

f=fields(TheCatalog.Catalog);
for i=1:length(f)
    s=sprintf('%s=[TheCatalog.Catalog.%s]'';',f{i},f{i});
    eval(s);
end

N=[~isempty(ThisStorm)    ...
   ~isempty(ThisAdvisory) ...
   ~isempty(ThisGrid)     ...
   ~isempty(ThisMachine)  ...
   ~isempty(ThisInstance)];

if isempty([ThisStorm ThisAdvisory ThisGrid ThisMachine ThisInstance])
    % take first entry in catalog.  It's the most recent
    currentStorm=Storms{1}; %#ok<USENS>
    currentAdv=Advisories{1}; %#ok<USENS>
    currentGrid=Grids{1}; %#ok<USENS>
    currentMachine=Machines{1}; %#ok<USENS>
    currentInstance=Instances{1}; %#ok<USENS>
    CurrentSelection=1;

else
    
    if ~isempty(ThisAdvisory)
        if ~ischar(ThisAdvisory)
            ThisAdvisory=num2str(ThisAdvisory);
        end
    end

    % filter out catalog parameters
    idxStorms=strcmp(Storms,ThisStorm);
    idxAdvisories=strcmp(Advisories,ThisAdvisory); 
    idxGrids=strcmp(Grids,ThisGrid);
    idxMachines=strcmp(Machines,ThisMachine); %#ok<*NODEF>
    idxInstances=strcmp(Instances,ThisInstance); %#ok<*NODEF>

    idxAll=sum([idxStorms idxAdvisories idxGrids idxMachines idxInstances]')==sum(N); %#ok<UDIM>

    idxAny=any([idxStorms idxAdvisories idxGrids idxMachines idxInstances]');

    if any(idxAll)
        % select most recent from those that satisty all of the
        % user-specified parameters
        CurrentSelection=find(idxAll,1);
    elseif any(idxAny) 
        % there are incomplete matches;  
         CurrentSelection=find(idxAny,1);
    else
        % no matches at all.  Pick first
        % the first entry in the catalog tree file is (presumably) the most recent forecast available.
        CurrentSelection=1;
    end
    currentStorm=Storms{CurrentSelection};
    currentAdv=Advisories{CurrentSelection};
    currentGrid=Grids{CurrentSelection};
    currentMachine=Machines{CurrentSelection};
    currentInstance=Instances{CurrentSelection};

end

% parse out ensemble member names
idx=strcmp(Storms,currentStorm) & strcmp(Advisories,currentAdv) & strcmp(Grids,currentGrid) & strcmp(Machines,currentMachine) & strcmp(Instances,currentInstance);
TheseEnsembles=Ensembles(idx);

% set default url and other things
Url.ThisInstance=currentInstance;
Url.ThisStorm   =currentStorm;
Url.ThisAdv     =currentAdv;
Url.ThisGrid    =currentGrid;
Url.Basin='al';
if str2double(currentAdv)<1000
    Url.StormType='TC';    
else  %  otherwise it will be the nam date...
    Url.StormType='other';
end
Url.FullDodsC=[UrlBase '/dodsC/' CatalogEntryPoint '/' currentStorm '/' currentAdv '/' currentGrid '/' currentMachine '/' currentInstance];
Url.FullFileServer=[UrlBase '/fileServer/' CatalogEntryPoint '/' currentStorm '/' currentAdv '/' currentGrid '/' currentMachine '/' currentInstance];
Url.Ens=TheseEnsembles;
Url.CurrentSelection=CurrentSelection;
Url.Base=UrlBase;
