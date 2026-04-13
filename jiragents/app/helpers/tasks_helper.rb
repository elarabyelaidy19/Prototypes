module TasksHelper
  BADGE_STYLES = {
    "pending"   => "bg-amber-50 text-amber-700 border border-amber-200",
    "running"   => "bg-teal-50 text-teal-700 border border-teal-200",
    "completed" => "bg-emerald-50 text-emerald-700 border border-emerald-200",
    "failed"    => "bg-rose-50 text-rose-700 border border-rose-200"
  }.freeze

  def task_status_badge(status)
    dot_class = "status-dot status-dot-#{status}"
    pill_class = BADGE_STYLES.fetch(status, "bg-gray-50 text-gray-600 border border-gray-200")

    tag.span(class: "inline-flex items-center gap-1.5 text-xs font-semibold px-2.5 py-1 rounded-full #{pill_class}") do
      tag.span(class: dot_class) + tag.span(status.capitalize)
    end
  end
end
