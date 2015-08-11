require 'helper'

class MysqlTableInputTest < Test::Unit::TestCase
  sub_test_case "test parse table list" do
    def test_parse_table_list_success
      test_tables = ['table_hoge', 'table_piyo']
      result = Fluent::MysqlTableInput.new.parse_table_list(test_tables)
      assert_equal(result, 'table_hoge,table_piyo')
    end

    def test_output_failed_tables_string
      test_tables = 'hoge'
      result = Fluent::MysqlTableInput.new.parse_table_list(test_tables)
      assert_false(result)
    end
  end
end