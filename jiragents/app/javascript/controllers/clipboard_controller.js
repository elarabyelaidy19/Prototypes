import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { target: String }

  copy() {
    const el = document.querySelector(this.targetValue)
    if (!el) return

    navigator.clipboard.writeText(el.textContent).then(() => {
      const original = this.element.textContent
      this.element.textContent = "Copied!"
      setTimeout(() => { this.element.textContent = original }, 1500)
    })
  }
}
