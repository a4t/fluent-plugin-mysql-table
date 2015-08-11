require 'helper'

class FilterChangePrevRecordTest < Test::Unit::TestCase
  def setup
    @change_prev_record_filter = Fluent::ChangePrevRecordFilter.new
  end

  sub_test_case "test change?" do
    def test_is_change_success
      @change_prev_record_filter.set_prev_record('hoge')
      result = @change_prev_record_filter.change?('moge')
      assert_true(result)
    end

    def test_is_change_failed_first_try
      @change_prev_record_filter.set_prev_record('')
      result = @change_prev_record_filter.change?('moge')
      assert_false(result)
    end

    def test_is_change_failed_not_change
      @change_prev_record_filter.set_prev_record('moge')
      result = @change_prev_record_filter.change?('moge')
      assert_false(result)
    end
  end

  sub_test_case "test diff table" do
    def test_diff_table_success_no_change
      @change_prev_record_filter.set_prev_record('foo,bar')
      result = @change_prev_record_filter.diff_table('foo,bar')
      assert_equal([], result)
    end

    def test_diff_table_success_add_table
      @change_prev_record_filter.set_prev_record('foo,bar')
      result = @change_prev_record_filter.diff_table('foo,bar,piyo')
      assert_equal(['piyo'], result)
    end

    def test_diff_table_success_del_table
      @change_prev_record_filter.set_prev_record('foo,bar')
      result = @change_prev_record_filter.diff_table('foo')
      assert_equal(['bar'], result)
    end
  end

end