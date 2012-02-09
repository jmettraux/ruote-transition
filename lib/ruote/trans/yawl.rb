#--
# Copyright (c) 2005-2012, John Mettraux, jmettraux@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


require 'rexml/parsers/sax2parser'
require 'rexml/sax2listener'

require 'ruote/trans/graph'


module Ruote::Trans

  module YAWL

    def self.parse(filename)

      File.open(filename, 'r') do |f|

        parser = REXML::Parsers::SAX2Parser.new f

        graphs = []

        # keeping track of the element being parsed

        graph = nil
        place = nil

        transition_id = 0

        # registering the listeners

        # u, l, q, a <=> url, local, qname, attributes

        parser.listen(:start_element, ['processControlElements']) do |u, l, q, a|
          graph = Graph.new
          graphs << graph
        end

        parser.listen(:start_element, ['inputCondition', 'outputCondition']) do |u, l, q, a|

          place = Place.new a['id'], a['id'], l, a
          graph << place
        end

        parser.listen(:start_element, ['task']) do |u, l, q, a|

          place = Place.new a['id'], a['id'], l, a
          graph << place
        end

        parser.listen(:start_element, ['nextElementRef']) do |u, l, q, a|

          tid = "t_#{transition_id}"

          transition = Transition.new tid, tid, l, a

          transition_id += 1

          transition.from = place.eid
          transition.to = a['id']

          graph << transition
        end

        parser.listen(:start_element, ['split', 'join']) do |u, l, q, a|

          place.transition_details[:all] =
            [ l.to_sym, a['code'].downcase.to_sym ]
        end

        parser.listen(:start_element, ['decomposesTo']) do |u, l, q, a|
          # TODO
          # <-> performer / participant ?
        end

        #parser.listen(:characters) do |text| # very minimalistic...
        #end

        # parse now

        parser.parse

        graphs
      end
    end
  end
end

