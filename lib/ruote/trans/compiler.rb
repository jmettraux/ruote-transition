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


module Ruote
module Trans

  class Expression < Array

    def initialize(exp_name, attributes)
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

    def parent(exp_name=nil)

      return @parent if exp_name == nil
      return nil if @parent == nil
      return @parent if @parent.name == exp_name
      @parent.parent(exp_name)
    end
  end

  class Children < Array
    def initialize(exp)
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

    # compiles a graph to a ruote tree
    #
    def self.compile(graph)

      StepCompiler.new(graph).send :compile
    end

    protected

    def initialize(graph)

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

    def start(expname, atts={})

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
        { 'ref' => place.participant,
          'eid' => place.eid,
          'activity' => place.label_to_s })

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
            'eid' => place.eid,
            'ref' => place.participant,
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

