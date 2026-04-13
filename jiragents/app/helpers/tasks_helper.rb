module TasksHelper
  STATUS_STYLES = {
    "pending"   => "bg-gray-100 text-gray-700",
    "running"   => "bg-blue-100 text-blue-700",
    "completed" => "bg-green-100 text-green-700",
    "failed"    => "bg-red-100 text-red-700"
  }.freeze

  def task_status_badge(status)
    classes = STATUS_STYLES.fetch(status, "bg-gray-100 text-gray-700")
    if status == "running"
      tag.span(class: "inline-flex items-center gap-1.5 text-sm font-medium px-3 py-1 rounded-full #{classes} animate-pulse") do
        tag.span("●", class: "text-blue-500") + tag.span("Running")
      end
    else
      tag.span(status.capitalize, class: "text-sm font-medium px-3 py-1 rounded-full #{classes}")
    end
  end
end
