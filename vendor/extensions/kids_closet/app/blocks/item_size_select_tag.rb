class ItemSizeSelectTag < FieldTag
  def initialize(tag_name, markup, tokens)
    begin
      super(tag_name, markup, tokens)
    rescue Liquid::SyntaxError => e
      raise Liquid::SyntaxError.new("Syntax Error in 'time_zone_select' - Valid syntax: time_zone_select [name]")
    end
  end

  private

  def field_html
    value = parse_attribute(attributes.delete('value'))
    category = parse_attribute(attributes.delete('category')).to_s
    include_blank = false
    formatted_name = parse_attribute(attributes.delete('name'))
    tab_index = parse_attribute(attributes.delete('tabindex'))
    class_style = parse_attribute(attributes.delete('class'))
    field_id = parse_attribute(attributes.delete('id'))
    attributes.symbolize_keys!

    select_tag(
      formatted_name,
      options_for_select(ConsignorInventory.size_array(category, value), value),
      attributes.merge({ :tabindex => tab_index, :class => class_style, :id => field_id })
    )
  end

end
Liquid::Template.register_tag('item_size_select', ItemSizeSelectTag)