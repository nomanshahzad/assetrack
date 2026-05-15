import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas", "input"]

  connect() {
    this.drawing = false
    this.ctx = this.canvasTarget.getContext("2d")
    this._resize()
    this._restoreFromInput()

    this.canvasTarget.addEventListener("pointerdown", this._start.bind(this))
    this.canvasTarget.addEventListener("pointermove", this._draw.bind(this))
    this.canvasTarget.addEventListener("pointerup", this._stop.bind(this))
    this.canvasTarget.addEventListener("pointerleave", this._stop.bind(this))
  }

  disconnect() {
    this.canvasTarget.removeEventListener("pointerdown", this._start.bind(this))
    this.canvasTarget.removeEventListener("pointermove", this._draw.bind(this))
    this.canvasTarget.removeEventListener("pointerup", this._stop.bind(this))
    this.canvasTarget.removeEventListener("pointerleave", this._stop.bind(this))
  }

  clear() {
    this.ctx.clearRect(0, 0, this.canvasTarget.width, this.canvasTarget.height)
    this.inputTarget.value = ""
  }

  _start(e) {
    e.preventDefault()
    this.drawing = true
    this.canvasTarget.setPointerCapture(e.pointerId)
    const { x, y } = this._pos(e)
    this.ctx.beginPath()
    this.ctx.moveTo(x, y)
  }

  _draw(e) {
    if (!this.drawing) return
    e.preventDefault()
    const { x, y } = this._pos(e)
    this.ctx.lineWidth = 2
    this.ctx.lineCap = "round"
    this.ctx.lineJoin = "round"
    this.ctx.strokeStyle = "#1e293b"
    this.ctx.lineTo(x, y)
    this.ctx.stroke()
  }

  _stop(e) {
    if (!this.drawing) return
    this.drawing = false
    this.inputTarget.value = this.canvasTarget.toDataURL("image/png")
  }

  _pos(e) {
    const rect = this.canvasTarget.getBoundingClientRect()
    const scaleX = this.canvasTarget.width / rect.width
    const scaleY = this.canvasTarget.height / rect.height
    return {
      x: (e.clientX - rect.left) * scaleX,
      y: (e.clientY - rect.top) * scaleY
    }
  }

  _resize() {
    const rect = this.canvasTarget.getBoundingClientRect()
    this.canvasTarget.width = rect.width || 400
    this.canvasTarget.height = rect.height || 120
  }

  _restoreFromInput() {
    const val = this.inputTarget.value
    if (!val) return
    const img = new Image()
    img.onload = () => this.ctx.drawImage(img, 0, 0)
    img.src = val
  }
}
