#!/usr/bin/env python3
"""Render the model figure and pack every simulated growth observation for web use."""

from pathlib import Path

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


ROOT = Path(__file__).resolve().parent
GENERATED = ROOT / "generated"
FIGURE = ROOT.parent.parent / "paper" / "figures" / "simulation.jpeg"
GAMMAS = (0.05, 0.10, 0.15, 0.20)
N_FIRMS = 1000


def main() -> None:
    series = []
    packed = []
    for gamma in GAMMAS:
        tag = f"g{round(gamma * 100):02d}"
        path = GENERATED / f"paper_partial_eq_{tag}_growth.csv"
        data = pd.read_csv(path).sort_values(["period", "firm"])
        if len(data) != N_FIRMS * 199:
            raise ValueError(f"{path.name} has {len(data):,} rows; expected 199,000.")
        if data["period"].nunique() != 199 or data["firm"].nunique() != N_FIRMS:
            raise ValueError(f"{path.name} does not contain the full 1,000 x 199 panel.")

        x = data["sales_growth"].to_numpy(dtype=np.float64)
        y = data["rnd_growth"].to_numpy(dtype=np.float64)
        beta = np.polyfit(x, y, 1)[0]
        series.append((gamma, x, y, beta))

        xy = data[["sales_growth", "rnd_growth"]].to_numpy(dtype="<f4")
        packed.append(xy.reshape(199, N_FIRMS, 2))

    FIGURE.parent.mkdir(parents=True, exist_ok=True)
    fig, axes = plt.subplots(2, 2, figsize=(10, 5.74), sharex=True, sharey=True)
    for ax, (gamma, x, y, beta) in zip(axes.flat, series):
        ax.scatter(x, y, s=0.34, c="#161616", alpha=0.38, linewidths=0, rasterized=True)
        xline = np.array([-0.5, 0.5])
        intercept = y.mean() - beta * x.mean()
        ax.plot(xline, intercept + beta * xline, color="#315fc7", linewidth=0.85)
        ax.set_xlim(-0.5, 0.5)
        ax.set_ylim(-0.2, 0.2)
        ax.set_xticks(np.arange(-0.5, 0.51, 0.25))
        ax.set_yticks(np.arange(-0.2, 0.21, 0.1))
        ax.grid(color="#d9d9d9", linewidth=0.35, alpha=0.55)
        ax.set_title(rf"$\gamma={gamma:.2f},\;\beta={beta:.3f}$", fontsize=10, pad=8)
        ax.set_xlabel("Sales Growth", fontsize=9, labelpad=1)
        ax.set_ylabel("R&D Growth", fontsize=9, labelpad=1)
        ax.tick_params(labelsize=7, length=2, colors="#666666")
        for spine in ax.spines.values():
            spine.set_visible(False)

    fig.subplots_adjust(left=0.06, right=0.99, top=0.93, bottom=0.09, wspace=0.11, hspace=0.23)
    fig.savefig(FIGURE, dpi=160, pil_kwargs={"quality": 92})
    plt.close(fig)

    binary_path = GENERATED / "research-cyclicality-float32.bin"
    np.stack(packed).tofile(binary_path)
    print(f"Saved {FIGURE}")
    print(f"Saved {binary_path}: {binary_path.stat().st_size:,} bytes, 199,000 dots per panel")
    for gamma, _, _, beta in series:
        print(f"gamma={gamma:.2f}: beta={beta:.4f}")


if __name__ == "__main__":
    main()
