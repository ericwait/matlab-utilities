function xmlNodes = FindXMLNodes(xmlDOM, nodePath, varargin)
    if ( mod(length(varargin),2) ~= 0 )
        error('Expected key-value pairs for attribute matching');
    end
    
    attribKeys = varargin(1:2:end);
    attribVals = varargin(2:2:end);
    
    chkPath = strsplit(nodePath,'>');
    xmlNodes = recursiveFindPath(xmlDOM, chkPath);
    
    xmlNodes = checkAttribs(xmlNodes, attribKeys,attribVals);
end

function matchNodes = checkAttribs(chkNodes, attribKeys,attribVals)
    matchNodes = [];
    for i=1:length(chkNodes)
        bMatchAttrib = false(1,length(attribKeys));
        for j=1:length(attribKeys)
            if ( ~chkNodes(i).hasAttribute(attribKeys{j}) )
                break;
            end
            
            if ( strcmp(chkNodes(i).getAttribute(attribKeys{j}),attribVals{j}) )
                bMatchAttrib(j) = true;
            end
        end
        
        if ( all(bMatchAttrib) )
            matchNodes = [matchNodes; chkNodes(i)];
        end
    end
end

function matchNodes = recursiveFindPath(xmlNode, chkPath)
    matchNodes = [];
    
    bMatch = strcmp(chkPath{1}, char(xmlNode.getNodeName()));
    
    if ( bMatch )
        chkPath = chkPath(2:end);
        
        if ( isempty(chkPath) )
            matchNodes = xmlNode;
            return;
        end
    end
    
    if ( ~xmlNode.hasChildNodes() )
        return;
    end
    
    childNodes = xmlNode.getChildNodes();
    numChildren = childNodes.getLength();
    for i=1:numChildren
        chkNode = childNodes.item(i-1);
        newNode = recursiveFindPath(chkNode, chkPath);
        
        if ( ~isempty(newNode) )
            matchNodes = [matchNodes; newNode];
        end
    end
end
