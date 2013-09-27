# Counter Cache With Conditions

Replacement for ActiveRecord belongs_to :counter_cache with ability to specify conditions.

## Installation

Add this line to your application's Gemfile:

    gem 'counter_cache_with_conditions'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install counter_cache_with_conditions

## Usage

When additional counter cache need

    belongs_to :folder, :counter_cache => true
    counter_cache_with_conditions :folder, :unread_messages_count, :unread => true

Or as replacement for rails build in solution.

    belongs_to :folder
    counter_cache_with_conditions :folder, :messages_count, {}
    counter_cache_with_conditions :folder, :unread_messages_count, :unread => true
    counter_cache_with_conditions :folder, :unread_messages_count, [:read, :source], lambda{|read, source| read == false && source == 'message'}
    counter_cache_with_conditions :folder, :published_events_count, [:published_at], lambda{|published_at| published_at != nil }



Copyright (c) 2010 Sergey Kojin, released under the MIT license
