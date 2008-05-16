
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

    class Element
      attr_accessor :seen
    end

    #
    # compiles a graph to an OpenWFEru tree
    #
    def self.compile (graph)

      StepCompiler.new(graph).send :compile
    end

    protected

      def initialize (graph)

        @graph = graph

        @current_children = []

        @tree = [ 
          'process-definition', 
          { 'name' => 'none', 'revision' => 'none' }, 
          @current_children ]
      end

      def compile

        @graph.find_start_places.each do |pl| 
          consider_place pl
        end

        @tree.inspect
      end

      def consider_place (place)

        part = [ 'participant', { 'ref' => place.label }, nil ]
        out = @graph.out_transitions place

        if out.size == 1

          seq = [ 'sequence', {},  [ part ] ]
          @current_children << seq
          @current_chldren = seq.last

          consider_place @graph.next_from(place)

        else

          @current_children << part
        end
      end
  end

end
end

