module NdTranscriber
  def self.included base
    base.class_eval do
      extend ClassMethods
    end
  end

  def transcribe origin, &block
    copier = Copier.new(origin, self)
    copier.instance_exec self, &self.class.transcribe_block if self.class.transcribe_block
    copier.instance_exec self, &block if block
    self
  end

  module ClassMethods
    def transcribe_block
      @transcribe_block
    end

    def transcribe_block=(transcribe_block)
      @transcribe_block = transcribe_block
    end

    def transcribes_to_block
      @transcribes_to_block
    end

    def transcribes_to_block=(transcribes_to_block)
      @transcribes_to_block = transcribes_to_block
    end

    def transcriber &block
      self.transcribe_block = block
    end

    def transcribes_to &block
      self.transcribes_to_block = block
    end

    def transcribe origin, &block
      destination = (transcribes_to_block && instance_exec(origin,
        &transcribes_to_block)) || new
      destination.transcribe origin, &block
    end

    def transcribe_all origins, &block
      origins.collect { |origin| transcribe origin, &block }
    end
  end
end

require 'nd_transcriber/copier'
