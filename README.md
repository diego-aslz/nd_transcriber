# Transcriber

This gem provides an easy way to copy attributes around.

## Installation

This gem is NOT available in Rubygems because there is already a gem named
`transcriber` that seems not to be being used, but I cannot remove it.

Using bundler:

```ruby
gem 'transcriber', github: 'nerde/transcriber'
```

## Usage

Basically, you just need to include `Transcriber` and define a block wich will
be called every time an object is copied.

```ruby
# We are going to copy from Origin objects.
Origin = Struct.new(:name, :last_name, :gender)

# Dest objects will receive the copied values
Dest = Struct.new(:name, :last_name, :complete_name, :male_female, :transcribed,
  :nickname) do
  include Transcriber

  transcriber do
    copy_fields :last_name,       # Copies field last_name as is
      :gender => :male_female,    # Copies field gender to field male_female
      :name => [:name, :nickname] # Copies field name to both name and nickname

    copy :name, to: :complete_name do |name| # Uses the value returned from the block
      "#{name} #{origin.last_name}"
    end

    # You can also just assign attributes to self.
    self.transcribed = true
  end
end

origin = Origin.new('John', 'Doe', 'M')

# The kind of object being copied doesn't matter. It just needs to have the
# attributes or methods Transcriber was told to copy from.
dest   = Dest.transcribe(origin)

dest.name          # => 'John'
dest.nickname      # => 'John'
dest.last_name     # => 'Doe'
dest.complete_name # => 'John Doe'
dest.male_female   # => 'M'
dest.transcribed   # => true
```
