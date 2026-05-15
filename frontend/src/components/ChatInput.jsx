import { useState, useRef } from "react"

export default function ChatInput({ onSubmit, disabled }) {
  const [text, setText] = useState("")
  const textareaRef = useRef(null)

  function handleKeyDown(e) {
    if (e.key === "Enter" && (e.metaKey || e.ctrlKey)) {
      e.preventDefault()
      submit()
    }
  }

  function submit() {
    const trimmed = text.trim()
    if (!trimmed || disabled) return
    onSubmit(trimmed)
    setText("")
    if (textareaRef.current) textareaRef.current.style.height = "auto"
  }

  function handleInput(e) {
    setText(e.target.value)
    e.target.style.height = "auto"
    e.target.style.height = Math.min(e.target.scrollHeight, 240) + "px"
  }

  return (
    <div className="chat-input-bar">
      <textarea
        ref={textareaRef}
        value={text}
        onChange={handleInput}
        onKeyDown={handleKeyDown}
        placeholder="Paste URS / AOR here… (Ctrl+Enter to submit)"
        disabled={disabled}
        rows={3}
        className="chat-textarea"
      />
      <button
        onClick={submit}
        disabled={disabled || !text.trim()}
        className="send-btn"
      >
        {disabled ? "Estimating…" : "Estimate ↗"}
      </button>
    </div>
  )
}
