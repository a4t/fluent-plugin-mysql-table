module Fluent
  class ChangePrevRecordFilter < Filter
    Fluent::Plugin.register_filter('change_prev_record', self)

    def configure(conf)
      super
      set_prev_record('change_prev_record_default', {})
    end

    def set_prev_record(tag, record = {})
      @prev_record = {} if @prev_record.nil?
      @prev_record[tag] = record
    end

    def filter_stream(tag, es)
      new_es = MultiEventStream.new
      es.each do |time, record|
        if change?(tag, record)
          change_tables = diff_table(tag, record)
          new_es.add(time, change_tables)
        end
      end
      new_es
    end

    def change?(tag, record)
      @prev_record[tag] = {} if @prev_record[tag].nil?
      if @prev_record[tag].empty?
        set_prev_record(tag, record)
        return false
      end

      if @prev_record[tag] != record
        return true
      end

      false
    end

    def diff_table(tag, now_record)
      now_tables = now_record.split(',')
      prev_tables = @prev_record[tag].split(',')
      diff1 = now_tables - prev_tables
      diff2 = prev_tables - now_tables

      set_prev_record(tag, now_record)

      diff1 + diff2
    end
  end
end
