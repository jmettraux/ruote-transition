
# ruote-transition


## overview

a small project about turning place-transition based process definitions to ruote process definitions.

For now, is able to parse XPDL (http://www.wfmc.org/standards/xpdl.htm) and YAWL (http://www.yawl-system.com/)


## get it

    git clone git://github.com/jmettraux/ruote-transition.git

    cd ruote-transition
    bundle install

(I tend to do "bundle install --path .bundle")

## run it

    ./bin/to_ruote --help

    ./bin/to_ruote -o ruby -i xpdl test/xpdl/troubleticket.xpdl
    ./bin/to_ruote -o xml -i yawl test/yawl/sample.yawl
    ./bin/to_ruote -o dot -i xpdl test/xpdl/troubleticket.xpdl


## Links

http://ruote.rubyforge.org
https://github.com/jmettraux/ruote


## license

MIT


## feedback

mailing list :  http://groups.google.com/group/openwferu-users
issue tracker : https://github.com/jmettraux/ruote-transition/issues

