import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox"]

  toggle(event) {
    if (!event.target.checked) return
    this.checkboxTargets.forEach((cb) => {
      if (cb !== event.target) cb.checked = false
    })
  }
}
