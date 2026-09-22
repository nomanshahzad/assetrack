import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["inputs", "previews"]
  static values = { removeLabel: String }

  connect() {
    this.urls = new Set()
  }

  disconnect() {
    this.urls.forEach(url => URL.revokeObjectURL(url))
  }

  take() { this.choose(true) }
  upload() { this.choose(false) }

  removePersisted(event) {
    const photo = event.currentTarget.closest("[data-photo-card]")
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = "asset[remove_photo_ids][]"
    input.value = event.currentTarget.dataset.photoId
    this.inputsTarget.append(input)
    photo.remove()
  }

  choose(camera) {
    // Keep each selected input so repeated camera captures accumulate on submit.
    const input = document.createElement("input")
    input.type = "file"
    input.name = "asset[photos][]"
    input.accept = "image/jpeg,image/png"
    if (camera) input.setAttribute("capture", "environment")
    else input.multiple = true
    this.inputsTarget.append(input)
    input.addEventListener("cancel", () => input.remove(), { once: true })
    input.addEventListener("change", () => {
      if (!input.files.length) { input.remove(); return }
      const group = document.createElement("div")
      group.className = "space-y-2"
      const urls = Array.from(input.files, file => {
        const url = URL.createObjectURL(file)
        this.urls.add(url)
        const image = document.createElement("img")
        image.src = url
        image.alt = file.name
        image.className = "w-full h-40 object-contain rounded-lg border border-slate-200"
        group.append(image)
        return url
      })
      const remove = document.createElement("button")
      remove.type = "button"
      remove.textContent = this.removeLabelValue
      remove.className = "text-sm text-red-600 cursor-pointer"
      remove.addEventListener("click", () => {
        input.remove()
        group.remove()
        urls.forEach(url => { URL.revokeObjectURL(url); this.urls.delete(url) })
      })
      group.append(remove)
      this.previewsTarget.append(group)
    }, { once: true })
    input.click()
  }
}
