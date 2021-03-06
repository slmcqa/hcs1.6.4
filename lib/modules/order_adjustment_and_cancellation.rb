require File.dirname(__FILE__) + '/helpers/locators'

module OrderAdjustmentAndCancellation
  include Locators::OrderAdjustmentAndCancellation

  def get_pending_ecu_cancellation_count
    wait_for(:wait_for => :ajax)
    sleep 3
    get_text(Locators::OrderAdjustmentAndCancellation.pending_ecu_cancellation_link).gsub(" Pending ECU Cancellation","").to_i
  end
  def click_pending_ecu_cancellation_link
    click Locators::OrderAdjustmentAndCancellation.pending_ecu_cancellation_link
    sleep Locators::NursingGeneralUnits.waiting_time
  end
  def pending_ecu_cancellation_actions(options={})
    go_to_order_adjustment_and_cancellation
    click_pending_ecu_cancellation_link
    if options[:cancel]
      sleep 2
      click_cancel_item(options)
      click Locators::OrderAdjustmentAndCancellation.confirm_ecu_confirmation, :wait_for => :page
      is_text_present("Order Adjustment and Cancellation › Adjustment")
    elsif options[:reprint]
      sleep 10
      click Locators::OrderAdjustmentAndCancellation.reprint_item, :wait_for => :page
      get_text('css=div[class="warning"]')
    end
  end
  def ecu_cancel_confirmation
    click Locators::OrderAdjustmentAndCancellation.cancel_item
    sleep 3
    jtext = get_text "ecuConfimationHeader"
    return jtext
  end
  def click_cancel_item(options={})
    count = get_css_count("css=#ecuCancelRows>tr")
    arr = []

    count.times do |i|
      arr << get_text("css=#ecuCancelRows>tr:nth-child(#{i + 1})>td>a>div") if is_element_present("css=#ecuCancelRows>tr:nth-child(#{i + 1})>td>a>div")
    end

    a = (arr.index(options[:pin])).to_i + 2
    return false if a == 2
    click "css=#ecuCancelRows>tr:nth-child(#{a})>td:nth-child(5)>div>a", :wait_for => :element, :element => Locators::OrderAdjustmentAndCancellation.confirm_ecu_confirmation
    sleep 2
  end
  def click_order_search_link
    sleep 2
    click "link=Order Search", :wait_for => :page
    is_text_present("Order List")
  end
  #Refund related methods
  def cancel_order_for_refund(options={})
    click "link=View Details", :wait_for => :page
    j = self.pos_cancel_order options
    return j
  end
  def pos_cancel_order(options={})
    click "link=Cancel"
    get_confirmation()
    choose_ok_on_next_confirmation()
    sleep 3
    select "cancelReason", "label=#{options[:reason]}"
    type "cancelRemarks", "testRemarks" || options[:remarks] if options[:remarks]
    click "btnOK", :wait_for => :page
    click "//input[@value='Submit']", :wait_for => :page
    me = get_alert if is_alert_present
    click("popup_ok", :wait_for => :page) if is_element_present("popup_ok")
    return me
  end
  def submit_refund(options={})
    type("refundReceivedBy", options[:receiver]) if options[:receiver]
    type("validIDPresented", options[:valid_id]) if options[:valid_id]
    type("refundAmount", options[:amount]) if options[:amount]
    return get_alert if is_alert_present # alert if entered refund is higher than amount
    click "//input[@value='Submit']", :wait_for => :page
    if is_element_present("css=div[id='errorMessages']")
      get_text("css=div[id='errorMessages']")
    elsif is_text_present("Patient Billing and Accounting Home")
      is_element_present("criteria")
    else
      tag_document
      get_text('css=div[class="success"]')
    end
  end
  def click_list_of_cancelled_discount_link
    go_to_pos_order_cancellation
    click "link=View/List of Cancelled/Adjusted Discounts", :wait_for => :page
    is_text_present("POS Document Search › Discount List")
  end
  def click_list_of_refund_link
    go_to_pos_order_cancellation
    click "link=View/List of Refund", :wait_for => :page
    is_text_present("POS Document Search › View/List of Refunds")
  end
  def search_discount(options={})
    if options[:search_by_date]
      click "//input[@name='searchType' and @value='discountDate']"
      type "txtDiscountDate", Date.today.strftime("%m/%d/%Y")
    else
      type "txtDiscountNo", options[:discount_no]
    end
    click "//input[@value='Search']", :wait_for => :page
    is_element_present("css=#results>tbody>tr>td:nth-child(5)")
  end
  def search_refund(options={})
    if options[:search_by_date]
      click "//input[@name='searchType' and @value='refundDate']"
      type "txtRefundDate", Date.today.strftime("%m/%d/%Y")
    else
      type "txtRefundNo", options[:discount_no]
    end
    click "//input[@value='Search']", :wait_for => :page
    is_element_present("css=#results>tbody>tr>td:nth-child(5)")
  end
  def click_order_adjustment_quick_links(options={})#Order Search, Clinical Order, Reprint Order Batch
    click "link=#{options[:page]}", :wait_for => :page
    return is_text_present("Order List") if options[:order_search]
    return is_text_present("Clinical Ordering") if options[:clinical_order]
    return is_text_present("Order Adjustment and Cancellation") if options[:reprint]
  end
  def click_reprint_prooflist
    click "link=Reprint Prooflist", :wait_for => :page
    is_element_present("//input[@value='Search']")
  end
  def click_reprint_refund_slip
    click "link=Reprint Refund Slip", :wait_for => :page
    is_element_present("//input[@value='Search']")
  end
  def batch_order_adjustment(options={})
    count = get_css_count("css=#activeBatchOrdersTable>tbody>tr")
    if options[:edit]
      count.times do |rows|
        my_row = get_text("css=#activeBatchOrdersTable>tbody>tr:nth-child(#{rows + 1})>td:nth-child(9)")
        if my_row == options[:item]
          stop_row = rows
        end
        @edit_row = stop_row
        click("css=#activeBatchOrdersTable>tbody>tr:nth-child(#{stop_row + 1})>td:nth-child(14)>a")
      end
      sleep 1
      type("activeBatchOrderQtyPerTake-#{@edit_row}", options[:quantity])
      days_to_adjust = -365
      d = Date.strptime(Time.now.strftime('%Y-%m-%d'))
      my_date = ((d - days_to_adjust).strftime("%m/%d/%Y").upcase).to_s
      end_date = options[:end_date] || my_date
      type("activeBatchOrderEndDate-#{@edit_row}", end_date)
      click("editActiveBatchOrder-#{@edit_row}") if options[:undo_edit]
      sleep 1
    elsif options[:cancel]
      count.times do |rows|
        my_row = get_text("css=#activeBatchOrdersTable>tbody>tr:nth-child(#{rows + 1})>td:nth-child(9)")
        if my_row == options[:item]
          stop_row = rows
        end
        click("css=#activeBatchOrdersTable>tbody>tr:nth-child(#{stop_row + 1})>td:nth-child(14)>a:nth-child(2)")
      end
    end
    click("//input[@id='submit' and @value='Submit']", :wait_for => :page) if options[:submit]
    is_text_present("Batch Order Details:")
  end

end