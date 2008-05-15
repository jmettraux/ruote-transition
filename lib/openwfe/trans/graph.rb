#
#--
# Copyright (c) 2008, John Mettraux, OpenWFE.org
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
# . Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.  
# 
# . Redistributions in binary form must reproduce the above copyright notice, 
#   this list of conditions and the following disclaimer in the documentation 
#   and/or other materials provided with the distribution.
# 
# . Neither the name of the "OpenWFE" nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#++
#

#
# "made in Japan"
#
# John Mettraux at openwfe.org
#

module OpenWFE
module Trans

  #
  # the parent class for Place and Transition
  #
  class Element

    attr_accessor :eid
    attr_accessor :label
    attr_accessor :original_name
    attr_accessor :attributes

    def initialize (eid, label, original_name, attributes)

      @eid = eid
      @label = label
      @original_name = original_name
      @attributes = attributes
    end
  end

  #
  # a place, could represent an activity, a step, a state, ...
  #
  class Place < Element

    #
    # storing info like { transition_eid => [ :split, :and ] }
    #
    attr_accessor :transitions


    def initialize (eid, label, original_name, attributes)

      super

      @transitions = {}
    end
  end

  #
  # linking a place to another
  #
  class Transition < Element

    attr_accessor :from
    attr_accessor :to

    attr_accessor :condition
  end

  #
  # a set of places and transitions
  #
  class Graph

    #
    # the attributes of the graph itself
    #
    attr_accessor :attributes

    attr_accessor :places
    attr_accessor :transitions

    #
    # things that are not places nor transitions
    #
    attr_accessor :others


    def initialize

      @places = {}
      @transitions = {}
    end

    #
    # accepts Place and Transition instances. Other kind of instances will
    # be placed in the "others" array.
    #
    def << (item)

      if item.is_a?(Place)

        @places[item.eid] = item

      elsif item.is_a?(Transition)

        @transitions[item.eid] = item

      else

        # ...
      end
    end

    #
    # outputs the graph in the DOT format
    #
    # http://graphviz.org
    #
    def to_dot

      s = ""
      
      s << "digraph #{self.class.name} {\n"
      s << "rankdir=LR;\n"
      s << "size=\"8,5\";\n"
      s << "node [shape = cirle];\n"

      @places.values.each do |pl|
        s << "\"#{pl.eid}\" [ label = \"#{pl.label}\" ];\n"
      end

      @transitions.values.each do |t|
        s << "\"#{t.from}\" -> \"#{t.to}\" [ label = \"#{t.label}\" ];\n"
      end

      s << "}\n"

      s
    end
  end
end
end
