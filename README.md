# Counter Cache With Conditions

[![Build Status](https://secure.travis-ci.org/thoughtbot/pacecar.png?branch=master)](http://travis-ci.org/thoughtbot/pacecar)


Replacement for ActiveRecord belongs_to :counter_cache with ability to specify conditions.

## Installation

Just include in your Gemfile:

```ruby
gem 'counter_cache_with_conditions'
```

## Usage

When additional counter cache need

``` ruby
class Message < ActiveRecord::Base
  belongs_to :folder, :counter_cache => true # rails default counter cache
  # hash syntax
  # counter_cache_with_conditions :association, :association_column_name, attribute: value
  counter_cache_with_conditions :folder, :unread_messages_count, unread: true
  # in hash style, true value mean !!attribute, same as if(attribute)
  counter_cache_with_conditions :folder, :read_messages_count, read_at: true
  # but false still mean strict if(attribute == false)
  counter_cache_with_conditions :folder, :unread_messages_count, read_at: nil

  # lambda syntax
  # counter_cache_with_conditions :association, :association_column_name, lambda{|attribute| ... }
  # lambda parameter names should be same as this record attribute name, because it need to compare with attributes before change
  counter_cache_with_conditions :folder, :positive_messages_count, lambda{|rating| rating > 3 }

end
```

More examples.

```ruby
# hash syntax
counter_cache_with_conditions :folder, :unread_messages_count, :unread => true
counter_cache_with_conditions :folder, :archived_messages_count, status: 'archived'
# hash can have multi attributes to check
counter_cache_with_conditions :folder, :unread_messages_count, :unread => true, source: 'message'

# lambda syntax
counter_cache_with_conditions :folder, :unread_messages_count, lambda{|read, source| read == false && source == 'message'}
counter_cache_with_conditions :folder, :published_events_count, ->(published_at){ published_at != nil }
```
Or even as replacement for rails build in solution. Because it works better then rails counter cache when need to move item between parent records (change :folder is this code sample)

```ruby
belongs_to :folder
# same as rails default counter cache
counter_cache_with_conditions :folder, :messages_count
```



## See Also

* https://github.com/magnusvk/counter_culture
* https://github.com/r7kamura/conditional_counter_cache
* https://github.com/cedric/custom_counter_cache
* https://github.com/wanelo/counter-cache
* https://github.com/iguchi1124/counter_cache-rails

## Copyright

*Copyright (c) 2010-2017 Sergey Kojin, released under the MIT license*
