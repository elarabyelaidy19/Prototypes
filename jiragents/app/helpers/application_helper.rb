module ApplicationHelper
  AVATAR_PALETTES = [
    { bg: "#f0fdfa", text: "#0d9488", border: "#ccfbf1" }, # teal
    { bg: "#fdf4ff", text: "#a855f7", border: "#f3e8ff" }, # purple
    { bg: "#fff7ed", text: "#ea580c", border: "#fed7aa" }, # orange
    { bg: "#f0fdf4", text: "#16a34a", border: "#bbf7d0" }, # green
    { bg: "#eff6ff", text: "#2563eb", border: "#bfdbfe" }, # blue
    { bg: "#fef2f2", text: "#dc2626", border: "#fecaca" }  # red
  ].freeze

  def agent_avatar_style(name)
    palette = AVATAR_PALETTES[name.bytes.sum % AVATAR_PALETTES.length]
    "background: #{palette[:bg]}; color: #{palette[:text]}; border-color: #{palette[:border]};"
  end
end
