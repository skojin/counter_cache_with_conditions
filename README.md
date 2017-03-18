# Counter Cache With Conditions

[![Build Status](https://secure.travis-ci.org/thoughtbot/pacecar.png?branch=master)](http://travis-ci.org/thoughtbot/pacecar)


Replacement for ActiveRecord belongs_to :counter_cache with ability to specify conditions.

## Installation

Just include in your Gemfile:

    gem 'counter_cache_with_conditions'

## Usage

When additional counter cache need

``` ruby
class Message < ActiveRecord::Base
  belongs_to :folder, :counter_cache => true # rails default counter cache
  # hash syntax
  # counter_cache_with_conditions :association, :association_column_name, attribute: value
  counter_cache_with_conditions :folder, :unread_messages_count, unread: true

  # lambda syntax
  # counter_cache_with_conditions :association, :association_column_name, [:attribute], lambda{|attribute| ... }
  # lambda syntax need [:used_attributes_array] because it need to track changes, and lambda will be called only when attributes are changed
  counter_cache_with_conditions :folder, :unread_messages_count, [:read_at], lambda{|read_at| !read_at }

end
```

More examples.

```ruby
# hash syntax
counter_cache_with_conditions :folder, :unread_messages_count, :unread => true
counter_cache_with_conditions :folder, :archived_messages_count, status: 'archived'

# lambda syntax
counter_cache_with_conditions :folder, :unread_messages_count, [:read, :source], lambda{|read, source| read == false && source == 'message'}
counter_cache_with_conditions :folder, :published_events_count, [:published_at], lambda{|published_at| published_at != nil }
```
Or even as replacement for rails build in solution.

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
