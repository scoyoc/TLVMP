utils::globalVariables(c("C", "Date", "DateTime", "F", "Key", "NAs", "PlotID",
                         "Quad", "SampleYear", "SppCode", "Value", "Var"))

export_table <- function(my_db, my_df, my_table){
  # my_df = dat$file_info; my_table = "tblWxImportLog2"
  if(my_table %in% RODBC::sqlTables(my_db)$TABLE_NAME){
    RODBC::sqlSave(my_db, my_df, tablename = my_table,
                   append = TRUE, rownames = FALSE, colnames = FALSE,
                   safer = TRUE, addPK = TRUE, fast = TRUE)
  } else({
    RODBC::sqlSave(my_db, my_df, tablename = my_table,
                   append = FALSE, rownames = FALSE, colnames = FALSE,
                   safer = TRUE, addPK = TRUE, fast = TRUE)
  })
}
