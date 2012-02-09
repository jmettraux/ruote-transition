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

require 'openwfe/trans/graph'


module OpenWFE::Trans

  module XPDL

    def self.parse (filename)

      File.open(filename, 'r') do |f|

        parser = REXML::Parsers::SAX2Parser.new f

        graphs = []

        # keeping track of the element being parsed

        graph = nil
        place = nil
        transition = nil
        t_restriction = nil
        performer = nil

        # registering the listeners

        # u, l, q, a <=> url, local, qname, attributes

        parser.listen(:start_element, ['WorkflowProcess']) do |u, l, q, a|
          graph = Graph.new
          graphs << graph
        end

        #parser.listen(:end_element, ['WorkflowProcess']) do |u, l, q, a|
        #end

        parser.listen(:start_element, ['Activity']) do |u, l, q, a|

          place = Place.new a['Id'], a['Name'], l, a
          graph << place
        end

        parser.listen(:start_element, ['Split', 'Join']) do |u, l, q, a|

          t_restriction = [ l.downcase.to_sym, a['Type'].downcase.to_sym ]
        end

        parser.listen(:start_element, ['TransitionRef']) do |u, l, q, a|

          place.transition_details[a['Id']] = t_restriction #.dup() ...
        end

        parser.listen(:start_element, ['Transition']) do |u, l, q, a|

          transition = Transition.new a['Id'], a['Name'], l, a
          transition.from = a['From']
          transition.to = a['To']
          graph << transition
        end

        parser.listen(:start_element, ['Condition']) do |u, l, q, a|

          transition.condition = { :type => a['Type'] }
        end

        parser.listen(:start_element, ['Performer']) do |u, l, q, a|

          performer = true
        end

        parser.listen(:characters) do |text| # very minimalistic...

          if performer

            place.attributes['participant'] = text
            performer = nil

          elsif transition and transition.condition and text.strip != ""

            transition.condition[:expression] = text \
          end
        end

        # parse now

        parser.parse

        graphs
      end
    end
  end

end
