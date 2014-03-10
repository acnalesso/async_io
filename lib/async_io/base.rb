require 'thread'
require 'async_io/worker'
require 'async_io/rescuer'

module AsyncIO
  class Base
    include AsyncIO::Rescuer

    ##
    # Default:
    # Number of threads to be spanwed is 5
    #
    # NOTE:
    #
    # Whenever an exception is raised, the thread that the
    # exception was raised from is killed, so we need a
    # way to prevent threads from being killed. Therefore it
    # rescues all exceptions raised and logs them.
    #
    attr_reader   :queue, :threads
    attr_accessor :logger
    def initialize(n_threads = 5, args = { logger: AsyncIO::Logger, queue: Queue.new })
      @logger   = args[:logger]
      @queue    = args[:queue]
      @threads  = []
      n_threads.times { @threads << Thread.new { consumer } }
    end

    ##
    # Ruby Queue#pop sets non_block to false.
    # It waits until data is pushed on to
    # the queue and then process it.
    #
    def consumer
      rescuer do
        while worker = queue.pop
          worker.call
        end
      end
    end
    private(:consumer)

    ##
    # It creates a new Worker, pushes it onto the queue,
    # whenever a 'task' (i.e a Ruby object ) is finished
    # it calls the payload and passes the result of that task
    # to it.
    #
    # For example:
    #
    # def aget_user(uid, &payload)
    #   worker(payload) do
    #     User.find(ui)
    #   end
    # end
    #
    # It returns the worker created for this particular task
    # which you could send message +done+ to it in order
    # to retrieve its completed task.
    # see async_io/worker.rb
    #
    # For example:
    # result = aget_user(1) { |u| Logger.info(u.name) }
    #
    # # task may take a while to be done...
    #
    # user = result.done
    # user.name
    # => "John"
    #
    # NOTE: Whenever you use the snippet above, if the task
    # has not been finished yet you will get +false+
    # whenever you send a message +task+ to it. Once
    # task is finished you will be able to get its result.
    #
    def worker(payload, task)
      Worker.new(payload, task).tap { |w| queue.push(w) }
    end

    ##
    # Perform any sort of task that needs to be
    # asynchronously done.
    # NOTE: It does not return anything, as it receives
    # and empty task. ( i.e empty block of code )
    #
    def async(&payload)
      worker(payload, proc {})
    end

    def async_with(task)
      worker(proc {}, task)
    end

    ##
    # TODO:
    # Allow multiple intervals to run on the same thread by storing
    # them in a list, and calling them later on.
    #
    def interval(seconds)
      new_interval? do
        while true
          rescuer { yield }
          sleep(seconds)
        end
      end
    end

    def new_interval?
      @interval ||= Thread.new { yield }
    end

    def clear_interval!
      @interval.terminate
      @interval = nil
    end

  end
end
