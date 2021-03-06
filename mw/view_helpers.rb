def default_layout
  {layout: :layout}
end

def to_card(path, opts = {})
  erb(path, opts.merge(layout: :"layout/card"))
end

def full_page_card(path, opts = {})
  card = to_card(path, opts)
  erb(card, opts.merge(default_layout))
end


def escape_html(html, opts = {})
  Rack::Utils.escape_html(html.to_s)
end