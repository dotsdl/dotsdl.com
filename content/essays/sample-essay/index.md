---
title: "Sample essay with math and code"
date: 2026-11-14T09:00:00-08:00
draft: false
tags: [sample, math]
series: []
summary: "Sample essay exercising build-time math and highlighted code; delete before launch."
math: true
canonical: "https://example.com/originally-published-here/"
syndication: ["https://example.com/originally-published-here/", "https://example.org/a-cross-post/"]
---

Sample essay for testing the theme; delete before launch.

## Math

Inline math such as \(e^{i\pi} + 1 = 0\) renders at build time as MathML. A display equation:

$$
\Delta G = -k_B T \ln \frac{Z_1}{Z_0}
$$

And a multi-line one:

\[
\begin{aligned}
\langle A \rangle &= \frac{1}{Z} \int A(x)\, e^{-\beta U(x)}\, dx \\
Z &= \int e^{-\beta U(x)}\, dx
\end{aligned}
\]

## Code

```python
import numpy as np

def free_energy(u_kn: np.ndarray, beta: float) -> float:
    """Exponential averaging (Zwanzig) estimate."""
    return -np.log(np.mean(np.exp(-beta * u_kn))) / beta
```

Plain text after the code block.
