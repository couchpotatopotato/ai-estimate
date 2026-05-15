import { useState } from "react"
import ChatInput from "./components/ChatInput"
import ResultsPanel from "./components/ResultsPanel"
import HistoryPanel from "./components/HistoryPanel"

export default function App() {
  const [history, setHistory] = useState([])
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState(null)

  async function handleSubmit(ursText) {
    setLoading(true)
    setError(null)

    const userMessage = { role: "user", text: ursText, ts: Date.now() }
    setHistory(prev => [...prev, userMessage])

    try {
      const res = await fetch("http://localhost:8000/estimate", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ urs_text: ursText }),
      })

      if (!res.ok) {
        const err = await res.json()
        throw new Error(err.detail || "Estimation failed")
      }

      const data = await res.json()
      const assistantMessage = { role: "assistant", result: data, ts: Date.now() }
      setHistory(prev => [...prev, assistantMessage])
    } catch (e) {
      setError(e.message)
      setHistory(prev => prev.slice(0, -1))
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="app-shell">
      <header className="app-header">
        <div className="header-inner">
          <span className="logo-badge">BEACON</span>
          <h1>Effort Estimator</h1>
          <span className="model-badge">Gemini Flash · Agent 1 + 2</span>
        </div>
      </header>

      <main className="main-layout">
        <div className="chat-column">
          <div className="message-list">
            {history.length === 0 && !loading && (
              <div className="empty-state">
                <p>Paste a URS or AOR below to get an effort estimate.</p>
                <p className="hint">Agent 1 will analyse BEACON impact. Agent 2 will calculate hours.</p>
              </div>
            )}

            {history.map((msg, i) => (
              <div key={i} className={`message message--${msg.role}`}>
                {msg.role === "user" && (
                  <div className="user-bubble">{msg.text}</div>
                )}
                {msg.role === "assistant" && (
                  <ResultsPanel result={msg.result} />
                )}
              </div>
            ))}

            {loading && (
              <div className="message message--assistant">
                <div className="loading-indicator">
                  <span />
                  <span />
                  <span />
                  <p>Analysing components…</p>
                </div>
              </div>
            )}

            {error && (
              <div className="error-banner">
                {error}
              </div>
            )}
          </div>

          <ChatInput onSubmit={handleSubmit} disabled={loading} />
        </div>

        {history.some(m => m.role === "assistant") && (
          <aside className="history-column">
            <HistoryPanel history={history.filter(m => m.role === "assistant")} />
          </aside>
        )}
      </main>
    </div>
  )
}
