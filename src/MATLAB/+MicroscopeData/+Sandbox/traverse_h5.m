function traverse_h5(file_id, recurse)
    opt_in = struct('recurse',{recurse}, 'visited',[], 'level','');
    
    [status,idx_out,opt_out] = H5L.iterate(file_id,'H5_INDEX_NAME','H5_ITER_INC',0,@depth_traverse_iter,opt_in);
end

function [status, opt_out] = depth_traverse_iter(loc_id,name,opt_in)
    opt_out = opt_in;
    status = 0;
    
    obj_addr = getObjectAddress(loc_id,name);
    obj_type = getObjectIdType(loc_id,name);
    switch (obj_type)
        case H5ML.get_constant_value('H5I_GROUP')
            fprintf('%sG: %s\n', opt_in.level,name);
            
            [status,opt_out] = traverseSubgroup(loc_id, name, obj_addr, opt_in);
        case H5ML.get_constant_value('H5I_DATASET')
            data_id = H5D.open(loc_id,name,'H5P_DEFAULT');
            space_id = H5D.get_space(data_id);
            [~,dims] = H5S.get_simple_extent_dims(space_id);
            
            strDims = sprintf('%d',dims(end));
            for i=(length(dims)-1):-1:1
                strDims = sprintf('%s, %d',strDims,dims(i));
            end
            
            fprintf('%sD: %s   [%s]\n', opt_in.level,name,strDims);
            H5D.close(data_id);
        case H5ML.get_constant_value('H5I_DATATYPE')
            fprintf('%sT: %s\n', opt_in.level,name);
        otherwise
            fprintf('%s?!\n', opt_in.level);
    end
end

function [status,opt_out] = traverseSubgroup(group_id, subgroup_name, subgroup_addr, opt_in)
    status = 0;
    opt_out = opt_in;
    
    bCycle = any(subgroup_addr == opt_in.visited);
    if ( ~opt_in.recurse || bCycle )
        return;
    end
    
    opt_in.level = [opt_in.level '  '];
    opt_in.visited = [opt_in.visited subgroup_addr];

    subgroup_id = H5G.open(group_id,subgroup_name,'H5P_DEFAULT');
    [status,~,opt_out] = H5L.iterate(subgroup_id,'H5_INDEX_NAME','H5_ITER_INC',0,@depth_traverse_iter,opt_in);
    H5G.close(subgroup_id);
end

function addr = getObjectAddress(group_id,name)
    link_info = H5L.get_info(group_id,name,'H5P_DEFAULT');
    addr = link_info.address;
end

function type = getObjectIdType(group_id,name)
    obj_id = H5O.open(group_id,name,'H5P_DEFAULT');
    
    type = H5I.get_type(obj_id);
    
    H5O.close(obj_id);
end



    