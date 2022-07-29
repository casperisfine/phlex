#!/usr/bin/env ruby

require "phlex"
require "erubi"
require "benchmark/ips"

class NavComponent < Phlex::Component
  def initialize(links)
    @links = links
  end

  def template
    nav id: "main_nav" do
      ul do
        @links.each do |title, url|
          li { a title, href: url }
        end
      end
    end
  end
end

links = {
  "Home" => "/",
  "About" => "/about",
  "Contact" => "/contact",
}

class NavTemplate
  src = Erubi::Engine.new(<<~HTML, escape: true).src
    <nav id="main_nav">
      <ul>
        <% @links.each do |title, url| %>
          <li><a href="<%= url %>"><%= title %></a></li>
        <% end %>
      </ul>
    </nav>
  HTML

  def initialize(links)
    @links = links
  end

  class_eval <<~RUBY, __FILE__, __LINE__ + 1
    def call
      #{src}
    end
  RUBY
end

puts RUBY_DESCRIPTION
puts '-' * 40
puts NavTemplate.new(links).call
puts '-' * 40
puts NavComponent.new(links).call
puts '-' * 40


Benchmark.ips do |x|
  x.report("erubi") { NavTemplate.new(links).call }
  x.report("phlex") { NavComponent.new(links).call }
  x.compare!
end
