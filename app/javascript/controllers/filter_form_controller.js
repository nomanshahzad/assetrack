import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.timeout = null
  }

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 300)
  }

  filter() {
    this.element.requestSubmit()
  }

  clear(event) {
    event.preventDefault()
    this.element.querySelectorAll("input[type=search], input[type=date]").forEach(el => el.value = "")
    this.element.requestSubmit()
  }
}
