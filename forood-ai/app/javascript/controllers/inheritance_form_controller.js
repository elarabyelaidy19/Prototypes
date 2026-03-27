import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["wifeField", "husbandField", "form", "heirInput", "heirRow", "submitBtn", "submitText"]

  connect() {
    this.updateSpouseFields()
    this.updateAllRowStates()
  }

  // ── Gender toggle ──────────────────────────────

  genderChanged() {
    this.updateSpouseFields()
  }

  updateSpouseFields() {
    const gender = this.element.querySelector('input[name="deceased_gender"]:checked')?.value

    if (gender === "male") {
      this.wifeFieldTarget.style.display = ""
      this.husbandFieldTarget.style.display = "none"
      this.husbandFieldTarget.querySelector("input[type=number]").value = 0
      this.updateRowState(this.husbandFieldTarget.querySelector(".heir-row"))
    } else {
      this.wifeFieldTarget.style.display = "none"
      this.husbandFieldTarget.style.display = ""
      this.wifeFieldTarget.querySelector("input[type=number]").value = 0
      this.updateRowState(this.wifeFieldTarget.querySelector(".heir-row"))
    }
  }

  // ── Increment / Decrement ──────────────────────

  increment(event) {
    const btn = event.currentTarget
    const inputId = btn.dataset.targetInput
    const input = document.getElementById(inputId)
    const max = parseInt(btn.dataset.max) || 99
    const current = parseInt(input.value) || 0

    if (current < max) {
      input.value = current + 1
      this.updateRowState(input.closest(".heir-row"))
    }
  }

  decrement(event) {
    const btn = event.currentTarget
    const inputId = btn.dataset.targetInput
    const input = document.getElementById(inputId)
    const current = parseInt(input.value) || 0

    if (current > 0) {
      input.value = current - 1
      this.updateRowState(input.closest(".heir-row"))
    }
  }

  inputChanged(event) {
    this.updateRowState(event.target.closest(".heir-row"))
  }

  // ── Active row highlight ───────────────────────

  updateRowState(row) {
    if (!row) return
    const input = row.querySelector(".heir-input")
    const val = parseInt(input?.value) || 0
    row.classList.toggle("heir-row--active", val > 0)
  }

  updateAllRowStates() {
    this.element.querySelectorAll(".heir-row").forEach(row => {
      this.updateRowState(row)
    })
  }

  // ── Submit loading state ───────────────────────

  onSubmit() {
    if (this.hasSubmitBtnTarget) {
      this.submitBtnTarget.classList.add("btn-submit--loading")
    }
    if (this.hasSubmitTextTarget) {
      this.submitTextTarget.textContent = "جارٍ الحساب..."
    }
  }

  onSubmitEnd() {
    if (this.hasSubmitBtnTarget) {
      this.submitBtnTarget.classList.remove("btn-submit--loading")
    }
    if (this.hasSubmitTextTarget) {
      this.submitTextTarget.textContent = "احسب الميراث"
    }
  }
}
