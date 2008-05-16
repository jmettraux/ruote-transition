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


require 'rexml/parsers/sax2parser'
require 'rexml/sax2listener'

require 'openwfe/trans/graph'


module OpenWFE::Trans

  module XPDL

    def self.parse (filename)
      
      File.open(filename, 'r') do |f|

        parser = REXML::Parsers::SAX2Parser.new f

        class << parser
          attr_reader :tag_stack
        end

        graphs = []

        # keeping track of the element being parsed

        graph = nil
        place = nil
        transition = nil
        t_restriction = nil

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

        parser.listen(:characters) do |text| # very minimalistic...

          transition.condition[:expression] = text \
            if transition and transition.condition and text.strip != ""
        end

        # parse now

        parser.parse

        graphs
      end
    end
  end

end
