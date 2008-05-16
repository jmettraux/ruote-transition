
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
  # an initial, super-naive "compiler"
  #
  class StepCompiler

    #
    # compiles a graph to an OpenWFEru tree
    #
    def self.compile (graph)

      StepCompiler.new(graph).send :compile
    end

    protected

      def initialize (graph)

        @graph = graph

        @tree = [ 
          'process-definition', 
          { 'name' => 'none', 'revision' => 'none' }, 
          [] ]

        @current_expression = @tree

        @seen_places = []
      end

      def current_exp_name

        @current_expression.first
      end

      def current_children

        @current_expression.last
      end

      def compile

        @graph.find_start_places.each do |pl| 
          consider_place pl
        end

        @tree
      end

      def move_to (expression)

        @current_expression = expression
      end

      def move_to_root

        move_to @tree
      end

      def enter_sequence

        seq = [ 'sequence', {},  [] ]
        current_children << seq
        move_to seq
      end

      def enter_subprocess (place)

        sub = [ 'process-definition', { 'name' => place.eid }, [] ]
        current_children << sub
        move_to sub

        @graph.next_from(place).each do |pl|
          consider_place pl
        end
      end

      def consider_place (place)

        return if @seen_places.include?(place.eid)

        @seen_places << place.eid

        part = [ 
          'participant', 
          { 'ref' => place.eid, 'activity' => place.label }, [] ]

        out = @graph.out_transitions place

        if out.size == 1

          enter_sequence unless current_exp_name == 'sequence'

          current_children << part
          
          consider_place @graph.next_from(place).first

        elsif out.size > 1

          step = [ 
            'step', 
            { 
              'step' => place.eid, 
              'outcomes' => out.collect { |tr| tr.to }.join(", ") }, 
            [] ]

          current_children << step

          move_to_root
          enter_subprocess place

        else

          current_children << part
        end
      end
  end

end
end

