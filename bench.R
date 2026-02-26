
load("test.RData")

library(updog)
Sys.setenv(OMP_NUM_THREADS = "1", OPENBLAS_NUM_THREADS = "1", MKL_NUM_THREADS = "1")

system.time({
  mout = multidog(refmat = refmat, sizemat = sizemat, ploidy = 8, model = "norm", nc = parallelly::availableCores())
  genomat = format_multidog(mout, varname = "geno")
})


# Read CSV exactly as written
genomat_csv <- read.csv("genomat.csv",
                        row.names = 1,
                        check.names = FALSE,
                        stringsAsFactors = FALSE)

# Coerce both to matrix for fair comparison
genomat_mat     <- as.matrix(genomat)
genomat_csv_mat <- as.matrix(genomat_csv)

# 1️⃣ Strict identical check
message("identical=",identical(genomat_mat, genomat_csv_mat))

# 2️⃣ Numeric-safe comparison (recommended)
all.equal(
  suppressWarnings(matrix(as.numeric(genomat_mat),
                          nrow = nrow(genomat_mat),
                          dimnames = dimnames(genomat_mat))),
  suppressWarnings(matrix(as.numeric(genomat_csv_mat),
                          nrow = nrow(genomat_csv_mat),
                          dimnames = dimnames(genomat_csv_mat))),
  check.attributes = TRUE
)

# 3️⃣ Show first difference if any
diff_idx <- which(genomat_mat != genomat_csv_mat, arr.ind = TRUE)

if (nrow(diff_idx) > 0) {
  i <- diff_idx[1,1]
  j <- diff_idx[1,2]
  list(
    row = rownames(genomat_mat)[i],
    col = colnames(genomat_mat)[j],
    genomat_value = genomat_mat[i,j],
    csv_value     = genomat_csv_mat[i,j]
  )
} else {
  print("No differences found")
}

rm(list = ls())
gc()
