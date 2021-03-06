#!/usr/bin/env ruby

=begin
    This script gathers information from each project and makes a package.cfg from it
=end

def id(name)
    $id = name
end
def name(name)
    $current[:name] = name
end
def install(data = {})
    data.each_pair do |k, v|
        if k.is_a? Array
          k.each do |k2|
            $current[:files][File.join("master/#{$entry}", k2)] = v
          end
        else
          $current[:files][File.join("master/#{$entry}", k)] = v
        end
    end
end
def depend(packages = {})
    packages.each do |k, v|
        $current[:dependencies][k] = v
    end
end
def description(desc)
    $current[:description] = desc
end
def hide!
    $current[:hidden] = true
end
def note(note)
    $current[:note] = note
end
def authors(authors)
    $current[:authors] = authors
end

def dirs(path)
    Dir.entries(path).select {|entry| File.directory? File.join(path,entry) and !(entry =='.' || entry == '..') }
end

def search(path)
    $data = {}
    dirs(path).each do |entry|
        file = File.join(File.join(path, entry), 'pkgbuild.rb')
        if File.exist? file
            puts "Found package #{file}"
            $entry = entry
            $current = {files: {}, repo: File.join('tree/master', entry), dependencies: {}}
            $id = nil
            Dir.chdir File.join(path, entry) do
                require_relative file
            end
            $data[$id] = $current
        end
    end
    $data
end

class Hash
    def to_lua(indent = 1)
        "{\n" +
        " " * indent * 4  + collect{|k, v| "[\"#{k.to_s}\"] = #{v.to_lua(indent + 1)}"}.join(",\n" + " " * indent * 4) +
        "\n#{" " * (indent - 1) * 4}}"
    end
end
class Array
    def to_lua(indent = 0)
        "{\n" +
        " " * indent * 4  + collect{|v| v.to_lua(indent + 1)}.join(",\n" + " " * indent * 4) +
        "\n#{" " * (indent - 1) * 4}}"
    end
end
class String
    def to_lua(indent = 0)
        '"' + self.gsub('\\', '\\\\').gsub("\n", '\\n') + '"'
    end
end
class Symbol
    def to_lua(indent = 0)
        to_s.to_lua(indent)
    end
end
class TrueClass
    def to_lua(indent = 0)
        'true'
    end
end
class FalseClass
    def to_lua(indent = 0)
        'false'
    end
end
class NilClass
    def to_lua(indent = 0)
        'nil'
    end
end

data = "-- THIS FILE IS GENERATED BY A SCRIPT. DO NOT EDIT BY HAND.\n" + search('.').to_lua
puts "Writing file..."
File.write 'programs.cfg', data