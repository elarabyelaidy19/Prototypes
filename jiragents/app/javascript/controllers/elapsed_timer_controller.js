import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    const started = parseInt(this.element.dataset.started, 10)
    this.tick(started)
    this.interval = setInterval(() => this.tick(started), 1000)
  }

  disconnect() {
    clearInterval(this.interval)
  }

  tick(started) {
    const elapsed = Math.floor(Date.now() / 1000) - started
    const m = Math.floor(elapsed / 60)
    const s = elapsed % 60
    this.element.textContent = m > 0
      ? `${m}m ${s.toString().padStart(2, "0")}s`
      : `${s}s`
  }
}
