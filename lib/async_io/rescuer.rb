module AsyncIO
  module Rescuer

    ##
    # Rescues any sort of exception raised and
    # log it to a default logger, returns :rescued
    # if any exception was raised.
    #
    def rescuer
      begin
        yield
      rescue Exception => notice
        AsyncIO::Logger.error("[-:AsyncIO::AsyncIO:-] - #{notice}\n")
        :rescued
      end
    end

  end
end
