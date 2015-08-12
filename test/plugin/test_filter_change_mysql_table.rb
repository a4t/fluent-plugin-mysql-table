require 'helper'

class FilterChangeMysqlTableTest < Test::Unit::TestCase
  def setup
    @change_mysql_table_filter = Fluent::ChangeMysqlTableFilter.new
  end

  sub_test_case "parse_table_record" do
    def test_parse_table_record_success
      test_record = 'moge,hoge'
      result = @change_mysql_table_filter.parse_table_record(test_record)
      assert_equal(['moge', 'hoge'], result)
    end

    def test_parse_table_record_success_one_table
      test_record = 'moge'
      result = @change_mysql_table_filter.parse_table_record(test_record)
      assert_equal(['moge'], result)
    end

    def test_parse_table_record_success_zero_table
      test_record = ''
      result = @change_mysql_table_filter.parse_table_record(test_record)
      assert_equal([], result)
    end

    def test_parse_table_record_success_not_comma
      test_record = 'hoge-hifow'
      result = @change_mysql_table_filter.parse_table_record(test_record)
      assert_equal(['hoge-hifow'], result)
    end
  end

  sub_test_case "test table_info" do
    def test_table_info_success
      data = [{'Create Table' => 'moge'}]
      result = @change_mysql_table_filter.table_info(data)
      assert_equal('moge', result)
    end

    def test_table_info_failed_not_key
      data = [{'foo' => 'moge'}]
      result = @change_mysql_table_filter.table_info(data)
      assert_nil(result)
    end
  end

  sub_test_case "test change table infos" do
    def test_change_table_infos_failed_no_change
      table_infos_arr = {
        'table1' => 'CREATE TABLE `table1` (`id` int(11) unsigned NOT NULL AUTO_INCREMENT, PRIMARY KEY (`id`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;',
        'table2' => 'CREATE TABLE `table2` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT, `path` varchar(255) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '', `width` int(10) unsigned NOT NULL, `height` int(10) unsigned NOT NULL, `deleted` datetime DEFAULT NULL, `created` datetime NOT NULL, `modified` datetime NOT NULL, PRIMARY KEY (`id`), KEY `created` (`created`), KEY `deleted` (`deleted`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;'
      }
      @change_mysql_table_filter.set_prev_table_infos('mysql.table', table_infos_arr)
      result = @change_mysql_table_filter.change_table_infos('mysql.table', table_infos_arr)
      assert_equal([], result)
    end

    def test_change_table_infos_failed_add_table
      table_infos_arr = {
        'table1' => 'CREATE TABLE `table1` (`id` int(11) unsigned NOT NULL AUTO_INCREMENT, PRIMARY KEY (`id`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;',
        'table2' => 'CREATE TABLE `table2` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT, `path` varchar(255) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '', `width` int(10) unsigned NOT NULL, `height` int(10) unsigned NOT NULL, `deleted` datetime DEFAULT NULL, `created` datetime NOT NULL, `modified` datetime NOT NULL, PRIMARY KEY (`id`), KEY `created` (`created`), KEY `deleted` (`deleted`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;'
      }
      @change_mysql_table_filter.set_prev_table_infos('mysql.table', table_infos_arr)
      change_table_infos_arr = table_infos_arr
      change_table_infos_arr['table3'] = 'CREATE TABLE `table3` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT, `path` varchar(255) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '', `width` int(10) unsigned NOT NULL, `height` int(10) unsigned NOT NULL, `deleted` datetime DEFAULT NULL, `created` datetime NOT NULL, `modified` datetime NOT NULL, PRIMARY KEY (`id`), KEY `created` (`created`), KEY `deleted` (`deleted`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;'
      result = @change_mysql_table_filter.change_table_infos('mysql.table', change_table_infos_arr)
      assert_equal([], result)
    end

    def test_change_table_infos_failed_del_table
      table_infos_arr = {
        'table1' => 'CREATE TABLE `table1` (`id` int(11) unsigned NOT NULL AUTO_INCREMENT, PRIMARY KEY (`id`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;',
        'table2' => 'CREATE TABLE `table2` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT, `path` varchar(255) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '', `width` int(10) unsigned NOT NULL, `height` int(10) unsigned NOT NULL, `deleted` datetime DEFAULT NULL, `created` datetime NOT NULL, `modified` datetime NOT NULL, PRIMARY KEY (`id`), KEY `created` (`created`), KEY `deleted` (`deleted`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;'
      }
      @change_mysql_table_filter.set_prev_table_infos('mysql.table', table_infos_arr)
      change_table_infos_arr = table_infos_arr
      change_table_infos_arr = {
        'table2' => 'CREATE TABLE `table2` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT, `path` varchar(255) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '', `width` int(10) unsigned NOT NULL, `height` int(10) unsigned NOT NULL, `deleted` datetime DEFAULT NULL, `created` datetime NOT NULL, `modified` datetime NOT NULL, PRIMARY KEY (`id`), KEY `created` (`created`), KEY `deleted` (`deleted`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;'
      }
      result = @change_mysql_table_filter.change_table_infos('mysql.table', table_infos_arr)
      assert_equal([], result)
    end

    def test_change_table_infos_success
      table_infos_arr = {
        'table1' => 'CREATE TABLE `table1` (`id` int(11) unsigned NOT NULL AUTO_INCREMENT, PRIMARY KEY (`id`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;',
        'table2' => 'CREATE TABLE `table2` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT, `path` varchar(255) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '', `width` int(10) unsigned NOT NULL, `height` int(10) unsigned NOT NULL, `deleted` datetime DEFAULT NULL, `created` datetime NOT NULL, `modified` datetime NOT NULL, PRIMARY KEY (`id`), KEY `created` (`created`), KEY `deleted` (`deleted`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;'
      }
      @change_mysql_table_filter.set_prev_table_infos('mysql.table', table_infos_arr)
      change_table_infos_arr = {
        'table1' => 'hoge',
      }
      result = @change_mysql_table_filter.change_table_infos('mysql.table', change_table_infos_arr)
      assert_equal(['table1'], result)
    end
  end

  def test_hoge
    table_infos_arr = {
      'table1' => 'CREATE TABLE `table1` (`id` int(11) unsigned NOT NULL AUTO_INCREMENT, PRIMARY KEY (`id`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;',
      'table2' => 'CREATE TABLE `table2` ( `id` int(10) unsigned NOT NULL AUTO_INCREMENT, `path` varchar(255) CHARACTER SET ascii COLLATE ascii_bin NOT NULL DEFAULT '', `width` int(10) unsigned NOT NULL, `height` int(10) unsigned NOT NULL, `deleted` datetime DEFAULT NULL, `created` datetime NOT NULL, `modified` datetime NOT NULL, PRIMARY KEY (`id`), KEY `created` (`created`), KEY `deleted` (`deleted`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;'
    }
    @change_mysql_table_filter.set_prev_table_infos('mysql.table', table_infos_arr)
  end
end