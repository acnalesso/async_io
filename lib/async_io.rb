require 'async_io/load'

module AsyncIO

  def self.async_creator=(new_async)
    @@async_creator = new_async
  end

  def self.async_creator
    @@async_creator ||= Base.new(5)
  end

  ##
  # Creates async jobs, if a payload (i.e ruby block)
  # is not given it passes an empty payload to woker.
  # That allows us to do:
  #
  # User.aget(1)
  # User.aget(1) { |u| print u.id }
  #
  # The response will be a worker that was created for this
  # particular job.
  #
  # NOTE: If you read PredictionIO::Worker you will see that
  # it calls payload and passes job as its arguments. This is
  # how it is available within a block later on.
  # NOTE: You must pass a job ( i.e ruby block ).
  #
  def self.async(task = proc {}, &payload)
    async_creator.worker(payload, task)
  end

  def self.async_with(task)
    async_creator.async_with(task)
  end

end
