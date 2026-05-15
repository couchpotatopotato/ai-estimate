export default function HistoryPanel({ history }) {
  return (
    <div className="history-panel">
      <h2 className="history-title">Past estimates</h2>
      <ul className="history-list">
        {[...history].reverse().map((msg, i) => (
          <li key={i} className="history-item">
            <span className="history-summary">{msg.result.urs_summary}</span>
            <span className="history-effort">
              {msg.result.effort_estimation?.total_hours ?? "—"}h
            </span>
          </li>
        ))}
      </ul>
    </div>
  )
}
