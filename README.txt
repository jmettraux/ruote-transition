
= ruote-transition


== overview

a small project about turning place-transition based process definitions to OpenWFEru process definitions.

For now, is able to parse XPDL (http://www.wfmc.org/standards/xpdl.htm) and YAWL (http://www.yawl-system.com/)

== get it

    git clone git://github.com/jmettraux/ruote-transition.git

(depends on OpenWFEru - http://github.com/jmettraux/ruote)


== run it

    ./bin/to_owfe -h

    ./bin/to_owfe -o ruby -i xpdl test/xpdl/troubleticket.xpdl
    ./bin/to_owfe -o xml -i yawl test/yawl/sample.yawl
    ./bin/to_owfe -o dot -i xpdl test/xpdl/troubleticket.xpdl


== Links

http://openwferu.rubyforge.org
http://rubyforge.org/projects/openwferu


== license

BSD


== feedback

user mailing list :        http://groups.google.com/group/openwferu-users
developers mailing list :  http://groups.google.com/group/openwferu-dev

issue tracker :            http://rubyforge.org/tracker/?atid=10023&group_id=2609&func=browse

