import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Show the toast with a fade-in effect
    setTimeout(() => {
      this.element.classList.remove("translate-x-full", "opacity-0")
      this.element.classList.add("translate-x-0", "opacity-100")
    }, 100)

    // Automatically hide after 5 seconds
    this.timeout = setTimeout(() => {
      this.close()
    }, 5000)
  }

  close() {
    if (this.timeout) clearTimeout(this.timeout)

    // Fade out and slide back
    this.element.classList.remove("translate-x-0", "opacity-100")
    this.element.classList.add("translate-x-full", "opacity-0")

    // Remove from DOM after animation
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
}
