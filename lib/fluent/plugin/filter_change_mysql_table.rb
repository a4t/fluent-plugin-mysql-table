module Fluent
  class ChangeMysqlTableFilter < Filter
    Fluent::Plugin.register_filter('change_mysql_table', self)

    TABLE_SEPARATE_CHARACTER = ','

    config_param :host,      :string,  :default => nil
    config_param :port,      :integer, :default => 3306
    config_param :username,  :string,  :default => nil
    config_param :password,  :string,  :default => nil
    config_param :database,  :string
    config_param :interval , :integer, :default => 1

    def initialize
      super
      require 'mysql2'
    end

    def configure(conf)
      super
      set_prev_table_infos

      begin
        @client = Mysql2::Client.new({
          :host => conf['host'],
          :port => conf['port'],
          :username => conf['username'],
          :password => conf['password'],
          :database => conf['database']
        })
      rescue
        log.error "fluent-plugin-in-mysql-tables: cannot connect Mysql"
      end
    end

    def set_prev_table_infos(table_infos_arr = {})
      @prev_table_infos_arr = table_infos_arr
    end

    def filter_stream(tag, es)
      new_es = MultiEventStream.new
      es.each do |time, record|
        message = change?(record)
        if !message.empty?
          new_es.add(time, message)
        end
      end
      new_es
    end

    def parse_table_record(record)
      record.split(TABLE_SEPARATE_CHARACTER)
    end

    def now_table_infos(record)
      table_names = parse_table_record(record)

      table_infos = {}
      table_names.each do |table_name|
        data = @client.query("SHOW CREATE TABLE #{table_name}", :cast => false)
        table_infos[table_name] = table_info(data)
        sleep @interval
      end

      table_infos
    end

    def table_info(data)
      data.each do |row|
        return row["Create Table"]
      end
    end

    def change_table_infos(now_table_infos_arr)
      change_table_names = []

      now_table_infos_arr.each do |table_name, table_info|
        change_table_names << table_name if change_table_info(table_name, table_info)
      end

      change_table_names
    end

    def change_table_info(table_name, table_info)
      return false unless @prev_table_infos_arr.has_key? table_name
      return false if @prev_table_infos_arr[table_name] == table_info
      true
    end

    def change?(record)
      now_table_infos_arr = now_table_infos(record)
      change_tables = change_table_infos(now_table_infos_arr)
      set_prev_table_infos(now_table_infos_arr)
      change_tables
    end
  end
end
