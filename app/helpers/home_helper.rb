module HomeHelper
  def home_icon(name)
    paths = {
      pin: [ "M20 10c0 6-8 12-8 12S4 16 4 10a8 8 0 1 1 16 0Z", "M15 10a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z" ],
      calendar: [ "M8 2v4m8-4v4M3 10h18", "M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2Z", "M8 14h3m-3 4h7" ],
      users: [ "M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2m20 0v-2a4 4 0 0 0-3-3.87", "M13 7a4 4 0 1 1-8 0 4 4 0 0 1 8 0Zm3-3.87a4 4 0 0 1 0 7.75" ],
      search: [ "M21 21l-5-5", "M18 10a8 8 0 1 1-16 0 8 8 0 0 1 16 0Z" ],
      check: [ "M20 6 9 17l-5-5" ]
    }

    tag.svg(viewBox: "0 0 24 24", fill: "none", stroke: "currentColor",
            "stroke-width": 1.75, "stroke-linecap": "round", "stroke-linejoin": "round",
            class: "home-icon", aria: { hidden: true }, focusable: "false") do
      safe_join(paths.fetch(name).map { |path| tag.path(d: path) })
    end
  end
end
