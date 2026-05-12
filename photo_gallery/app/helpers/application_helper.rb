module ApplicationHelper
  def inline_svg(name, classes: "")
    path = Rails.root.join("app/assets/images", name)
    svg  = File.read(path)
    svg.sub("<svg", %(<svg class="#{classes}")).html_safe
  end
end
