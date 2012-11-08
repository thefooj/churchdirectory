module ApplicationHelper
  def objects_to_pages_columns_and_rows(objects, rows_per_page = 10, cols_per_page = 2)
    entries_per_page = rows_per_page * cols_per_page
    num_pages = (objects.count.to_f / entries_per_page.to_f).ceil
    the_pages = []
    1.upto(num_pages) do |page|
      page_data = {
        :pagenum => page,
        :matrix => [],
      }
      sub_items = objects[((page-1) * entries_per_page)..((page*entries_per_page)-1)]
      rownum = 0
      sub_items.each do |item|
        page_data[:matrix][rownum] ||= []
        page_data[:matrix][rownum] << item
        rownum += 1
        
        # start back up if needed
        if rownum == rows_per_page
          rownum = 0
        end
      end
      the_pages << page_data
    end
    
    return the_pages
  end
end
