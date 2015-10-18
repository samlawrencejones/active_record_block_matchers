RSpec::Matchers.define :create do |klasses|
  include ActiveSupport::Inflector

  supports_block_expectations

  description do
    "create #{klasses}"
  end
  match do |block|
    time_before = Time.current

    block.call

    @created_records = {}
    klasses.each{
        |klass, count|
      column_name = ActiveRecordBlockMatchers::Config.created_at_column_name
      @created_records[klass] = klass.to_s.constantize.where("#{column_name} > ?", time_before)
    }.select{
      |klass, count|
      count != @created_records[klass].count
    }.empty?
  end

  failure_message do
    generate_failure_message(klasses, 'should')
  end

  failure_message_when_negated do
    generate_failure_message(klasses, 'should not')
  end

  def generate_failure_message(klasses, should)
    klasses.select{
      |klass, count|
      @created_records[klass] != count
    }.map{
        |klass, count|
      "The block #{should} have created #{count} #{klass.to_s.pluralize(count)}, but created #{@created_records[klass].count}."
    }.join(' ')
  end
end