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

  class Expression < Array

    def initialize (exp_name, attributes)
      super([ exp_name, attributes, Children.new(self) ])
    end

    def name
      self.first
    end

    def attributes
      self[1]
    end

    def children
      self.last
    end

    def children= (cs)
      self[2] = cs
    end

    def parent= (expression)
      @parent = expression
    end

    def parent (exp_name=nil)

      return @parent if exp_name == nil
      return nil if @parent == nil
      return @parent if @parent.name == exp_name
      @parent.parent(exp_name)
    end
  end

  class Children < Array
    def initialize (exp)
      super()
      @exp = exp
    end
    def << (expression)
      expression.parent = @exp
      super
    end
  end

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

        @tree = Expression.new(
          'process-definition',
          { 'name' => 'none', 'revision' => 'none' })

        @current_expression = @tree

        @seen_places = []
      end

      def compile

        @graph.find_start_places.each do |pl|
          handle_place pl
        end

        clean_tree(@tree)
      end

      def move_to (expression)

        @current_expression = expression
      end

      def move_to_root

        move_to @tree
      end

      def start (expname, atts={})

        exp = Expression.new expname, atts
        @current_expression.children << exp
        move_to exp
        exp
      end

      def wrap_in_subprocess (place)

        return if @seen_places.include?(place.eid)
        start 'process-definition', { 'name' => "d_#{place.eid}" }
        handle_place place
      end

      def handle_place (place)

        return if @seen_places.include?(place.eid)

        @seen_places << place.eid

        part = Expression.new(
          'participant',
          { 'ref' => place.eid, 'activity' => place.label_to_s })

        #
        # considering incoming transitions

        iin = @graph.in_transitions place

        if iin.size > 1 #and place.transition_types(:in) == [ :and ]

          con = @current_expression.parent 'concurrence'
          move_to(con.parent) if con
        end

        #
        # considering outgoing transitions

        out = @graph.out_transitions place

        if out.size == 1

          start('sequence') unless @current_expression.name == 'sequence'

          @current_expression.children << part

          handle_place @graph.next_from(place).first

        elsif out.size > 1 and place.transition_types(:out) == [ :and ]

          @current_expression.children << part

          start('concurrence')

          con = @current_expression

          @graph.next_from(place).each do |pl|
            handle_place pl
            move_to con
          end

        elsif out.size > 1

          step = Expression.new(
            'step',
            {
              'ref' => place.eid,
              'outcomes' => out.collect { |tr| "d_#{tr.to}" }.join(", "),
              'activity' => place.label })

          @current_expression.children << step

          @graph.next_from(place).each do |pl|
            move_to_root
            wrap_in_subprocess pl
          end

        else

          @current_expression.children << part
        end
      end

      #
      # clean the tree, for example, eliminates sequence that have only
      # one child (use the child directly).
      #
      def clean_tree (branch)

        branch.children = branch.children.inject(Children.new(branch)) do |r, c|
          cc = if c.name == 'sequence' and c.children.size == 1
            c.children.first
          else
            c
          end
          r << clean_tree(cc)
        end

        branch
      end
  end

end
end

