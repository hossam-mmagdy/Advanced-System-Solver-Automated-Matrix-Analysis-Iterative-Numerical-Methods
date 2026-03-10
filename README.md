# Advanced Linear System Solver

---

## Overview

The **Advanced Linear System Solver** is a comprehensive MATLAB framework designed for scientists, engineers, and researchers working with linear systems of equations ($Ax = b$). This tool integrates both **direct** and **iterative** numerical methods within an intelligent analysis environment that automatically evaluates matrix properties and recommends optimal solution strategies.

### Key Capabilities

- **Six Fundamental Algorithms**: From classical direct methods to modern iterative techniques
- **Intelligent Matrix Analysis**: Automated condition number, diagonal dominance, and definiteness assessment
- **Dynamic Visualization**: Interactive 2D/3D geometric interpretation for low-dimensional systems
- **Scientific Data Integration**: Native Excel and CSV support for complex datasets
- **High-Precision Computing**: Variable-Precision Arithmetic (VPA) for ill-conditioned systems
- **Performance Benchmarking**: Execution timing and convergence analysis

---

## Features

### Multi-Method Architecture

| Method | Type | Best For | Complexity |
|--------|------|----------|------------|
| **LU Decomposition** | Direct | General matrices, medium size | $O(n^3)$ |
| **Jacobi Iteration** | Iterative | Strictly diagonally dominant | $O(n^2)$ per iteration |
| **Gauss-Seidel** | Iterative | Diagonally dominant, faster convergence | $O(n^2)$ per iteration |
| **Cramer's Rule** | Direct | Small systems ($n \leq 5$), exact solutions | $O(n!)$ |
| **SVD** | Direct | Singular/near-singular matrices | $O(mn^2)$ |
| **Conjugate Gradient** | Iterative | Large SPD systems, sparse matrices | $O(n)$ per iteration |

### Intelligent Matrix Analysis

The solver automatically evaluates:

- **Condition Number** ($\kappa(A)$): Measures sensitivity to numerical errors
- **Diagonal Dominance**: Determines suitability for iterative methods
- **Positive Definiteness**: Identifies SPD systems for specialized solvers
- **Sparsity Pattern**: Optimizes storage and computation for sparse matrices

### Visualization Suite

For systems where $n \leq 3$:

- **2D Plots**: Line intersections for $2 \times 2$ systems
- **3D Surface Plots**: Plane intersections for $3 \times 3$ systems
- **Convergence Animation**: Iterative method progression
- **Residual Evolution**: Log-scale convergence history

---

## Installation

### Prerequisites

- MATLAB R2020b or later
- Symbolic Math Toolbox (optional, for VPA functionality)
- Statistics and Machine Learning Toolbox (optional)

### Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/linear-system-solver.git

# Navigate to directory
cd linear-system-solver

# Launch MATLAB and run the main script
matlab -r "Hossam"
