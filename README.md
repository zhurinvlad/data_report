# DataReport
* [https://www.netguru.co/blog/creating-a-gem-a-step-by-step-tutorial](https://www.netguru.co/blog/creating-a-gem-a-step-by-step-tutorial)
* [https://github.com/esminc/adhoq](https://github.com/esminc/adhoq)
* [http://docs.seattlerb.org/rdoc/RDoc/Markup.html](http://docs.seattlerb.org/rdoc/RDoc/Markup.html)
* [http://guides.rubygems.org/gems-with-extensions/](http://guides.rubygems.org/gems-with-extensions/)
* [http://api.rubyonrails.org/classes/Rails/Railtie.html](http://api.rubyonrails.org/classes/Rails/Railtie.html)
* [https://github.com/krautcomputing/gem_config](https://github.com/krautcomputing/gem_config)
* [https://github.com/svenfuchs/gem-release](https://github.com/svenfuchs/gem-release)
* [https://travis-ci.org/](https://travis-ci.org/)
* [Frozen String Literal: true What is it?](https://freelancing-gods.com/2017/07/27/friendly-frozen-string-literals.html)
* [https://github.com/kaminari/kaminari/blob/master/kaminari-core/lib/kaminari/config.rb](https://github.com/kaminari/kaminari/blob/master/kaminari-core/lib/kaminari/config.rb)

The personal gem data-reports
* Поддержка форматов json, html, pdf, excel, csv, zip(внутри сжатый файл)
* Возможность получения данных из SP, SQL-query, напрямую передать данные. (по умолчанию из SP, либо get_data: [:sp, :sql, :data])
* Возможность ежедневной и тд настраиваемой генерации с сохранение промежуточных данных.
* Глобальный конфиги для всех видов отчетов, локальный для конкретного с указанием полей и другой уникальной информацией
* возможность отправки на почту/переопределение на slack либо сразу реализовать
* сохранение в бд пути к файлу, связать с моделью
* опция force, для перезаписи существующих файлов.
* Статусы обработки(:waiting, :processing, :processed, :error) 
* I18n.t ru/en
* Миграция(пользователь, type, формат, email(slack, etc), status, params, filename, created,  updated, deleted )
* Разбивка при еже-генерации
* Доп методы

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/data_report`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'data_report'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install data_report

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/data_report. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License
About [MIT licence](https://choosealicense.com/licenses/mit/)

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the DataReport project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/data_report/blob/master/CODE_OF_CONDUCT.md).
