module Fluent
  class MysqlTableInput < Input
    Fluent::Plugin.register_input("in_mysql_table", self)

    config_param :tag,       :string
    config_param :host,      :string,  :default => nil
    config_param :port,      :integer, :default => 3306
    config_param :username,  :string,  :default => nil
    config_param :password,  :string,  :default => nil
    config_param :database,  :string
    config_param :interval , :integer, :default => 60

    def initialize
      super
      require 'mysql2'
    end

    def configure(conf)
      super
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

    def start
      super
      @watcher = Thread.new(&method(:watch))
    end

    def watch
      while true
        sleep @interval
        main
      end
    end

    def table_list
      tables = []
      data = @client.query("SHOW TABLES FROM #{@database}", :cast => false)
      data.each do |row|
        row.each do |key, value|
          tables << value
        end
      end

      tables
    end

    def main
      message = parse_table_list(table_list)
      output(@tag, message) if message
    end

    def parse_table_list(table_list)
      begin
        table_list.join(",")
      rescue => e
        false
      end
    end

    def output(tag, message)
      begin
        Engine.emit(tag, Engine.now, message)

        true
      rescue => e
        false
      end
    end

    def shutdown
      @watcher.kill
    end
  end
end