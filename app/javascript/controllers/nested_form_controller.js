import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "container"]

  connect() {
    if (this.containerTarget.querySelectorAll("tr:not(.hidden)").length === 0) {
      this._insertRow()
    }
    this.updateRowNumbers()
  }

  addRow(event) {
    event.preventDefault()
    this._insertRow()
  }

  removeRow(event) {
    event.preventDefault()
    const row = event.currentTarget.closest("tr")
    const destroyField = row.querySelector("input[name*='_destroy']")
    if (destroyField) {
      destroyField.value = "1"
      row.classList.add("hidden")
    } else {
      row.remove()
    }
    this.updateRowNumbers()
  }

  _insertRow() {
    const timestamp = new Date().getTime()
    // template.content is a DocumentFragment — innerHTML would be empty
    const clone = this.templateTarget.content.cloneNode(true)
    // Use tbody to correctly serialize <tr> content to an HTML string
    const temp = document.createElement("tbody")
    temp.appendChild(clone)
    const html = temp.innerHTML.replace(/NEW_RECORD/g, timestamp)
    this.containerTarget.insertAdjacentHTML("beforeend", html)
    this.updateRowNumbers()
  }

  updateRowNumbers() {
    const rows = this.containerTarget.querySelectorAll("tr:not(.hidden)")
    rows.forEach((row, i) => {
      const el = row.querySelector("[data-row-number]")
      if (el) el.textContent = i + 1
    })
  }
}
