function ModifyXMLAttribute(xmlNode, name,value)
    if ( ~xmlNode.hasAttribute(name) )
        return;
    end

    xmlNode.setAttribute(name, value);
end
