import { useState } from "react"

const COMPLEXITY_LABEL = { L: "Low", M: "Medium", H: "High" }
const COMPLEXITY_CLASS = { L: "badge--low", M: "badge--med", H: "badge--high" }
const CHANGE_CLASS = { UI: "badge--ui", BL: "badge--bl", DB: "badge--db", INT: "badge--int" }

export default function ResultsPanel({ result }) {
  const [expanded, setExpanded] = useState(true)

  const {
    urs_summary,
    analysis_confidence,
    confidence_note,
    impacted_components,
    effort_estimation,
  } = result

  const hasEstimate = effort_estimation && effort_estimation.total_hours > 0

  function downloadReport() {
    const lines = [
      `# BEACON Effort Estimation Report`,
      ``,
      `**Requirement:** ${urs_summary}`,
      `**Confidence:** ${analysis_confidence}${confidence_note ? ` — ${confidence_note}` : ""}`,
      ``,
      `## Effort Summary`,
      `- Total hours: ${effort_estimation?.total_hours ?? "—"}`,
      `- Total days: ${effort_estimation?.total_days ?? "—"}`,
      ``,
      `## Impacted Components`,
      ``,
      `| Component | Change type | Complexity | Hours | Rationale |`,
      `|---|---|---|---|---|`,
      ...(effort_estimation?.component_breakdown ?? []).map((row, i) => {
        const comp = impacted_components[i]
        return `| ${row.component_name} | ${row.change_type} | ${COMPLEXITY_LABEL[row.complexity]} | ${row.estimated_hours}h | ${comp?.rationale ?? ""} |`
      }),
    ]
    const blob = new Blob([lines.join("\n")], { type: "text/markdown" })
    const url = URL.createObjectURL(blob)
    const a = document.createElement("a")
    a.href = url
    a.download = "beacon-estimation.md"
    a.click()
    URL.revokeObjectURL(url)
  }

  return (
    <div className="results-card">
      <div className="results-header" onClick={() => setExpanded(e => !e)}>
        <div className="results-summary-line">
          <span className={`confidence-dot confidence-dot--${analysis_confidence}`} />
          <span className="urs-summary">{urs_summary}</span>
        </div>
        {hasEstimate && (
          <div className="effort-pill">
            {effort_estimation.total_hours}h · {effort_estimation.total_days}d
          </div>
        )}
        <button className="expand-toggle">{expanded ? "▲" : "▼"}</button>
      </div>

      {confidence_note && (
        <div className="confidence-note">
          ⚠ {confidence_note}
        </div>
      )}

      {expanded && (
        <>
          {!hasEstimate && (
            <p className="no-estimate">Confidence too low to estimate — please clarify the URS.</p>
          )}

          {hasEstimate && (
            <>
              <div className="effort-stats">
                <div className="stat-box">
                  <span className="stat-label">Total hours</span>
                  <span className="stat-value">{effort_estimation.total_hours}h</span>
                </div>
                <div className="stat-box">
                  <span className="stat-label">Dev days</span>
                  <span className="stat-value">{effort_estimation.total_days}d</span>
                </div>
                <div className="stat-box">
                  <span className="stat-label">Components</span>
                  <span className="stat-value">{impacted_components.length}</span>
                </div>
              </div>

              <table className="components-table">
                <thead>
                  <tr>
                    <th>Component</th>
                    <th>Type</th>
                    <th>Complexity</th>
                    <th>Hours</th>
                    <th>Rationale</th>
                  </tr>
                </thead>
                <tbody>
                  {effort_estimation.component_breakdown.map((row, i) => (
                    <tr key={i}>
                      <td className="cell-name">{row.component_name}</td>
                      <td><span className={`badge ${CHANGE_CLASS[row.change_type] ?? ""}`}>{row.change_type}</span></td>
                      <td><span className={`badge ${COMPLEXITY_CLASS[row.complexity] ?? ""}`}>{COMPLEXITY_LABEL[row.complexity]}</span></td>
                      <td className="cell-hours">{row.estimated_hours}h</td>
                      <td className="cell-rationale">{impacted_components[i]?.rationale ?? ""}</td>
                    </tr>
                  ))}
                </tbody>
              </table>

              <div className="results-footer">
                <button className="download-btn" onClick={downloadReport}>
                  Download report ↓
                </button>
              </div>
            </>
          )}
        </>
      )}
    </div>
  )
}
