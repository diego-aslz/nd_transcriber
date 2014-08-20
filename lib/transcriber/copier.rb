module Transcriber
  class Copier
    attr_accessor :origin, :dest

    def initialize origin, dest
      self.origin, self.dest = origin, dest
    end

    def copy_fields *fields
      fields.each do |field|
        if field.is_a?(Hash)
          field.each_pair do |from, to|
            copy from, to: to
          end
        else
          copy field
        end
      end
      dest
    end

    def copy field, to: field
      value = (field && origin.respond_to?(field) ? origin.send(field) : nil )
      value = yield(value) if block_given?
      if to.is_a?(Array)
        to.each do |f|
          dest.send("#{f}=", value)
        end
      else
        dest.send("#{to}=", value)
      end
    end

    def method_missing method, *args, &block
      dest.send(method, *args, &block)
    end
  end
end
