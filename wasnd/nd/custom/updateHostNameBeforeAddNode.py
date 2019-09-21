#####################################################################################
#                                                                                   #
#  Script to update Hostname                                                        #
#                                                                                   #
#  Usage : wsadmin -lang jython -f updateHostName.py <node name >  < host name >    #
#                                                                                   #
#####################################################################################


def updateHostNameBeforeAddNode(nodename, hostname):
    nlist = AdminConfig.list('ServerIndex')
    attr = [["hostName", hostname]]
    AdminConfig.modify(nlist, attr)
    AdminConfig.save()


updateHostNameBeforeAddNode(sys.argv[0], sys.argv[1])
