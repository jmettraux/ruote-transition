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

    #
    # returns the label, but without CR and LF and double spaces
    #
    def label_to_s

      return "" unless @label

      @label.gsub(/[\n\r]/, ' ').gsub(/  */, ' ')
    end

    #
    # used mainly by the to_dot routine
    #
    def label_and_id

      "#{label_to_s} (#{@eid})".strip
    end

    #
    # the label, but downcased and spaces are replaced by underscores
    #
    def label_compact

      label_to_s.downcase.gsub(/ /, '_')
    end

    #
    # returns the participant / performer name or the place id
    #
    def participant

      @attributes['participant'] || @eid
    end
  end

  #
  # a place, could represent an activity, a step, a state, ...
  #
  class Place < Element

    #
    # storing info like { transition_eid => [ :split, :and ] }
    #
    attr_accessor :transition_details


    def initialize (eid, label, original_name, attributes)

      super

      @transition_details = {}
    end

    def transition_types (direction)

      split, join = @transition_details.values.partition do |detail|
        detail.first == :split
      end

      r = (direction == :split or direction == :out) ? split : join
      r.collect { |e| e.last }.uniq
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
    # returns places that have no incoming transitions
    #
    def find_start_places

      find_end_or_start true
    end

    #
    # returns places that have no outgoing transitions
    #
    def find_end_places

      find_end_or_start false
    end

    #
    # given a place, lists outgoing transitions
    #
    def out_transitions (place)

      transitions.values.select { |tr| tr.from == place.eid }
    end

    #
    # given a place, lists incoming transitions
    #
    def in_transitions (place)

      transitions.values.select { |tr| tr.to == place.eid }
    end

    #
    # returns the next place from the given one, will follow the first
    # transition available.
    #
    def next_from (place)

      out_transitions(place).collect { |tr| @places[tr.to] }
    end

    #
    # outputs the graph in the DOT format
    #
    # http://graphviz.org
    #
    def to_dot

      s = ""

      s << "digraph \"#{self.class.name}\" {\n"
      s << "rankdir=LR;\n"
      s << "size=\"8,5\";\n"
      s << "node [ shape = \"rectangle\", style = \"rounded\" ];\n"

      @places.values.each do |pl|
        s << "\"#{pl.eid}\" [ label = \"#{pl.label_and_id}\" ];\n"
      end

      @transitions.values.each do |t|

        from_place = @places[t.from]
        details = from_place ? from_place.transition_details[t.eid] : nil

        split_xor = (details == [ :split, :xor ])

        s << "\"#{t.from}\" -> \"#{t.to}\""
        s << " [ label = \"#{t.label_and_id}\""
        s << ", arrowtail = \"ediamond\"" if split_xor
        s << " ];\n"
      end

      s << "}\n"

      s
    end

    protected

      #
      # returns places that have no incoming transitions (start=true)
      # or that have no outgoing transitions (start=false)
      #
      def find_end_or_start (start=true)

        pls = @places.dup

        @transitions.values.each do |t|
          pls.delete(start ? t.to : t.from)
        end

        pls.values
      end

  end
end
end
