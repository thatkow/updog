Sys.setenv(OMP_NUM_THREADS = "1", OPENBLAS_NUM_THREADS = "1", MKL_NUM_THREADS = "1")

suppressPackageStartupMessages(library(updog))

if (requireNamespace("future", quietly = TRUE)) {
  future::plan(future::sequential)
}

data("uitdewilligen", package = "updog")

refmat <- t(uitdewilligen$refmat)[seq_len(min(50, ncol(t(uitdewilligen$refmat)))), seq_len(min(50, nrow(t(uitdewilligen$refmat)))), drop = FALSE]
sizemat <- t(uitdewilligen$sizemat)[seq_len(min(50, ncol(t(uitdewilligen$sizemat)))), seq_len(min(50, nrow(t(uitdewilligen$sizemat)))), drop = FALSE]

nc <- 1
if (requireNamespace("parallelly", quietly = TRUE)) {
  nc <- max(1L, min(2L, parallelly::availableCores()))
}

cat("Benchmark config:\n")
cat("  OMP_NUM_THREADS=", Sys.getenv("OMP_NUM_THREADS"), "\n", sep = "")
cat("  OPENBLAS_NUM_THREADS=", Sys.getenv("OPENBLAS_NUM_THREADS"), "\n", sep = "")
cat("  MKL_NUM_THREADS=", Sys.getenv("MKL_NUM_THREADS"), "\n", sep = "")
cat("  nc=", nc, "\n", sep = "")

elapsed <- system.time({
  mout <- multidog(
    refmat = refmat,
    sizemat = sizemat,
    ploidy = uitdewilligen$ploidy,
    model = "norm",
    nc = nc
  )
})

cat("\nBenchmark elapsed (sec):\n")
print(elapsed)
cat("Output dimensions:\n")
cat("  snpdf rows=", nrow(mout$snpdf), "\n", sep = "")
cat("  inddf rows=", nrow(mout$inddf), "\n", sep = "")
