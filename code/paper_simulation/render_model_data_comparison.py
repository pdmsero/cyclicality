#!/usr/bin/env python3
"""Build the model-versus-Compustat plot from simulated and stored panel data."""

from __future__ import annotations

import json
import sqlite3
from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parent
REPO = ROOT.parents[1]
GENERATED = ROOT / "generated"
FIGURE = REPO / "paper" / "figures" / "modelvsdata.jpeg"
DB_PATH = REPO / "data" / "cyclicality.db"
MODEL_PATH = GENERATED / "paper_partial_eq_g10_growth.csv"
MODEL_BIN = GENERATED / "research-cyclicality-model-float32.bin"
DATA_BIN = GENERATED / "research-cyclicality-compustat-float32.bin"
META_PATH = GENERATED / "research-cyclicality-comparison.json"


def regression(x: np.ndarray, y: np.ndarray) -> tuple[float, float]:
    slope, intercept = np.polyfit(x, y, 1)
    return float(slope), float(intercept)


def main() -> None:
    full_model = pd.read_csv(MODEL_PATH).sort_values(["period", "firm"])

    with sqlite3.connect(DB_PATH) as connection:
        empirical = pd.read_sql_query(
            """SELECT key, year, d_gdp_sale AS sales_growth,
                      d_gdp_xrd AS rnd_growth
               FROM processed_alldata_stage3""",
            connection,
        )
    empirical["year"] = pd.to_numeric(empirical["year"], errors="coerce")
    empirical = empirical.dropna(subset=["year", "sales_growth", "rnd_growth"])
    empirical = empirical[np.isfinite(empirical["sales_growth"]) & np.isfinite(empirical["rnd_growth"])]
    empirical = empirical.sort_values(["year", "key"], kind="stable")
    ex = empirical["sales_growth"].to_numpy(dtype=np.float64)
    ey = empirical["rnd_growth"].to_numpy(dtype=np.float64)
    e_slope, e_intercept = regression(ex, ey)
    target_n = len(empirical)

    # Keep every empirical row and select an equal-sized model sample without
    # replacement. Within each simulated period, firms are spread evenly over
    # the complete 1,000-firm cross-section; every selected point is an actual
    # output from the generated model panel.
    n_periods = int(full_model["period"].nunique())
    base, remainder = divmod(target_n, n_periods)
    selected_periods = []
    period_counts = []
    for period_index, (period, block) in enumerate(full_model.groupby("period", sort=True)):
        take = base + (period_index < remainder)
        positions = np.floor((np.arange(take) + 0.5) * len(block) / take).astype(int)
        selected_periods.append(block.iloc[positions])
        period_counts.append(int(take))
    model = pd.concat(selected_periods, ignore_index=True).sort_values(["period", "firm"])
    if len(model) != target_n:
        raise AssertionError("Matched model sample does not equal the Compustat observation count.")
    mx = model["sales_growth"].to_numpy(dtype=np.float64)
    my = model["rnd_growth"].to_numpy(dtype=np.float64)
    m_slope, m_intercept = regression(mx, my)
    model_xy = np.column_stack([mx, my]).astype("<f4")
    model_xy.tofile(MODEL_BIN)
    empirical[["sales_growth", "rnd_growth"]].to_numpy(dtype="<f4").tofile(DATA_BIN)

    by_year = empirical.groupby("year", sort=True).size()
    years = [
        {"year": int(year), "count": int(count)}
        for year, count in by_year.items()
    ]
    metadata = {
        "axes": {"xMin": -1.0, "xMax": 1.0, "yMin": -0.5, "yMax": 0.5},
        "model": {
            "label": "Model · γ = 0.10",
            "count": len(model_xy),
            "fullPanelCount": len(full_model),
            "periods": n_periods,
            "firms": int(model["firm"].nunique()),
            "periodCounts": period_counts,
            "selection": "Equal-size stratified sample without replacement across all 199 simulated periods; all selected values are actual model outputs.",
            "slope": m_slope,
            "intercept": m_intercept,
        },
        "data": {
            "label": "Compustat",
            "count": len(empirical),
            "startYear": int(by_year.index.min()),
            "endYear": int(by_year.index.max()),
            "slope": e_slope,
            "intercept": e_intercept,
            "years": years,
        },
        "source": "processed_alldata_stage3: d_gdp_sale and d_gdp_xrd, complete finite firm-year observations; no sampling or trimming.",
    }
    META_PATH.write_text(json.dumps(metadata, separators=(",", ":")))

    fig, axes = plt.subplots(1, 2, figsize=(8, 4), sharex=True, sharey=True)
    for ax, x, y, slope, intercept, title in [
        (axes[0], mx, my, m_slope, m_intercept, f"Model · γ = 0.10 · β = {m_slope:.3f}"),
        (axes[1], ex, ey, e_slope, e_intercept, f"Compustat · β = {e_slope:.3f}"),
    ]:
        ax.set_facecolor("#e8e8e8")
        ax.scatter(x, y, s=0.28, c="#171717", alpha=0.28, linewidths=0, rasterized=True)
        line_x = np.array([-1.0, 1.0])
        ax.plot(line_x, intercept + slope * line_x, color="#315fc7", linewidth=1.05)
        ax.set_xlim(-1, 1)
        ax.set_ylim(-0.5, 0.5)
        ax.set_xticks(np.arange(-1, 1.01, 0.5))
        ax.set_yticks(np.arange(-0.5, 0.51, 0.25))
        ax.grid(color="white", linewidth=0.8)
        ax.set_title(title, fontsize=10, pad=7)
        ax.set_xlabel("Sales Growth", fontsize=9)
        ax.tick_params(labelsize=8, length=2, colors="#555")
        for spine in ax.spines.values():
            spine.set_visible(False)
    axes[0].set_ylabel("R&D Growth", fontsize=9)
    fig.subplots_adjust(left=0.09, right=0.99, top=0.88, bottom=0.14, wspace=0.13)
    FIGURE.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(FIGURE, dpi=150, pil_kwargs={"quality": 92})
    plt.close(fig)

    print(f"Saved {FIGURE}")
    print(f"Model: {len(model_xy):,} actual simulated observations; beta={m_slope:.6f}")
    print(f"Compustat: {len(empirical):,} complete observations, {years[0]['year']}-{years[-1]['year']}; beta={e_slope:.6f}")
    print(f"Data: {MODEL_BIN.stat().st_size:,} + {DATA_BIN.stat().st_size:,} bytes")


if __name__ == "__main__":
    main()
