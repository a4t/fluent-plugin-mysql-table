module Fluent
  class ChangePrevRecordFilter < Filter
    Fluent::Plugin.register_filter('change_prev_record', self)

    def configure(conf)
      super
      set_prev_record ''
    end

    def set_prev_record(record)
      @prev_record = record
    end

    def filter_stream(tag, es)
      new_es = MultiEventStream.new
      es.each do |time, record|
        if change?(record)
          change_tables = diff_table(record)
          new_es.add(time, record)
        end
      end
      new_es
    end

    def change?(record)
      if @prev_record == ''
        @prev_record = record
        return false
      end

      if @prev_record != record
        set_prev_record(record)
        return true
      end

      false
    end

    def diff_table(now_record)
      now_tables = now_record.split(',')
      prev_tables = @prev_record.split(',')
      diff1 = now_tables - prev_tables
      diff2 = prev_tables - now_tables
      diff1 + diff2
    end
  end
end
