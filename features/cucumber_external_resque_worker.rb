# https://gist.github.com/532100
class CucumberExternalResqueWorker
  DEFAULT_STARTUP_TIMEOUT = 1.minute
  COUNTER_KEY = "cucumber:counter"

  class << self
    attr_accessor :pid, :startup_timeout

    def start
      # Call from a Cucumber support file so it is run on startup
      return unless Rails.env.cucumber?
      if self.pid = fork
        start_parent
        wait_for_worker_to_start
      else
        start_child
      end
    end

    def install_hooks_on_startup
      # Call from a Rails initializer
      return unless Rails.env.cucumber?
      install_pause_on_start_hook
      install_worker_base_counter_patch
    end

    def process_all
      # Call from a Cucumber step
      unpause
      sleep 1 until done?
      pause
    end

    def incr
      Resque.redis.incr(COUNTER_KEY)
    end

    def decr
      Resque.redis.decr(COUNTER_KEY)
    end

    def reset_counter
      Resque.redis.set(COUNTER_KEY, 0)
    end

    private

    def done?
      Resque.redis.get(CucumberExternalResqueWorker::COUNTER_KEY).to_i.zero?
    end

    def pause(pid = self.pid)
      return unless Rails.env.cucumber?
      Process.kill("USR2", pid)
    end

    def unpause
      return unless Rails.env.cucumber?
      Process.kill("CONT", pid)
    end

    def start_parent
      at_exit do
        reset_counter
        Process.kill("KILL", pid) if pid
      end
    end

    def start_child
      # Array form of exec() is required here, otherwise the worker is not a direct child process of cucumber.
      # If it's not the direct child process then the PID returned from fork() is wrong, which means we can't
      # communicate with the worker.
      exec('rake', 'resque:work', "QUEUE=*", "RAILS_ENV=cucumber")
    end

    def wait_for_worker_to_start
      self.startup_timeout ||= DEFAULT_STARTUP_TIMEOUT
      start = Time.now.to_i
      while (Time.now.to_i - start) < startup_timeout
        return if worker_started?
        sleep 1
      end

      raise "Timeout while waiting for the worker to start. Waited #{startup_timeout} seconds."
    end

    def worker_started?
      Resque.info[:workers].to_i > 0
    end

    def install_pause_on_start_hook
      Resque.before_first_fork do
        reset_counter
        pause(Process.pid)
      end
    end

    def install_worker_base_counter_patch
      WorkerBase.class_eval do
        class << self
          def enqueue_with_counters(*args, &block)
            CucumberExternalResqueWorker.incr
            enqueue_without_counters(*args, &block)
          end
          alias_method_chain :enqueue, :counters

          def perform_with_counters(*args, &block)
            perform_without_counters(*args, &block)
          ensure
            CucumberExternalResqueWorker.decr
          end
          alias_method_chain :perform, :counters
        end
      end
    end
  end
end


CucumberExternalResqueWorker.start
CucumberExternalResqueWorker.install_hooks_on_startup
