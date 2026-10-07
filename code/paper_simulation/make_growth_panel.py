#!/usr/bin/env python3
"""Turn the simulated firm panel into the plotted model growth-rate dots."""

from pathlib import Path
import numpy as np
import pandas as pd

HERE = Path(__file__).resolve().parent / "generated"


def main() -> None:
    for panel_path in sorted(HERE.glob("paper_partial_eq_g*_panel.csv")):
        panel = pd.read_csv(panel_path)
        panel = panel.sort_values(["firm", "period"])
        grouped = panel.groupby("firm", sort=False)
        panel["sales_growth"] = grouped["sales"].transform(lambda x: np.log(x).diff())
        panel["rnd_growth"] = grouped["rnd"].transform(lambda x: np.log(x).diff())
        points = panel.dropna(subset=["sales_growth", "rnd_growth"])[
            ["firm", "period", "sales_growth", "rnd_growth", "sales", "rnd", "quality", "log_tfp"]
        ]
        out = panel_path.with_name(panel_path.stem.replace("_panel", "_growth") + ".csv")
        points.to_csv(out, index=False)
        print(f"{out.name}: {len(points):,} simulated model points")


if __name__ == "__main__":
    main()
