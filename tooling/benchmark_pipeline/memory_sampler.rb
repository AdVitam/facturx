# frozen_string_literal: true

require 'json'

module PipelineBenchmark
  class MemorySampler
    INTERVAL = 0.005

    def initialize(parent)
      @parent = parent
      @samples = 0
      @peaks = { parent_rss_kib: 0, descendants_rss_sum_kib: 0, largest_descendant_rss_kib: 0 }
      @commands = {}
    end

    def run(ready, output)
      running = true
      Signal.trap('TERM') { running = false }
      ready.write('.')
      ready.close
      sample_while { running }
      output.write(JSON.generate(@peaks.merge(samples: @samples, descendant_commands: @commands)))
    ensure
      output.close
    end

    private

    def sample_while
      while yield
        sample
        sleep(INTERVAL)
      end
      sample
    end

    def sample
      @samples += 1
      peak(:parent_rss_kib, rss(@parent))
      values = descendants.map { |pid| descendant_rss(pid) }
      peak(:descendants_rss_sum_kib, values.sum)
      peak(:largest_descendant_rss_kib, values.max || 0)
    end

    def descendant_rss(pid)
      value = rss(pid)
      command = proc_read(pid, 'comm').strip
      @commands[command] = [@commands.fetch(command, 0), value].max unless command.empty?
      value
    end

    def descendants
      pending = [@parent]
      visited = {}
      visit_children(pending.shift, visited, pending) until pending.empty?
      visited.keys
    end

    def visit_children(pid, visited, pending)
      children = proc_read(pid, "task/#{pid}/children").split.map(&:to_i)
      children.each do |child|
        next if child == Process.pid || visited[child]

        visited[child] = true
        pending << child
      end
    end

    def rss(pid)
      proc_read(pid, 'status')[/^VmRSS:\s+(\d+)/, 1].to_i
    end

    def peak(key, value)
      @peaks[key] = [@peaks.fetch(key), value].max
    end

    def proc_read(pid, entry)
      File.read("/proc/#{pid}/#{entry}")
    rescue Errno::ENOENT, Errno::ESRCH
      ''
    end
  end

  class MemoryCapture
    def initialize
      @reader, @writer = IO.pipe
      @ready_reader, @ready_writer = IO.pipe
    end

    def call
      start
      result = yield
      result.merge(memory: finish)
    ensure
      finish if @pid
      [@reader, @writer, @ready_reader, @ready_writer].each { |io| io.close unless io.closed? }
    end

    private

    def start
      parent = Process.pid
      @pid = Process.fork do
        @reader.close
        @ready_reader.close
        MemorySampler.new(parent).run(@ready_writer, @writer)
        exit!(0)
      end
      @writer.close
      @ready_writer.close
      raise 'Memory sampler failed to start' unless @ready_reader.read(1) == '.'
    end

    def finish
      Process.kill('TERM', @pid)
      Process.wait(@pid)
      @pid = nil
      JSON.parse(@reader.read, symbolize_names: true)
    end
  end
end
