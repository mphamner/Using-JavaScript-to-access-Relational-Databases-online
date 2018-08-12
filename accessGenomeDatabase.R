#  R script to access the Genome database at UCSC, find out how many tables 
#  are in the database, then look at the contents of one of the tables. 
#  This script was written and executed in R version 3.3.3.  

#  First access the UCSC Genome website and see how many databases there are. 
#  Store the output and print out the results.  

library("RMySQL", lib.loc="~/R/win-library/3.3")
ucscDb <- dbConnect(MySQL(), user="genome", host="genome-mysql.cse.ucsc.edu")
result <- dbGetQuery(ucscDb, "show databases;"); dbDisconnect(ucscDb);
cat("The following are the databases on the UCSC Genome website.", "\n")
print(result)
cat("\n")

#  Next, consider one of the databases, hg19.  Query how many tables there are in #  one of the databases, hg19.  Also, query the names of the first 5 tables in the
#  hg19 database.  

hg19 <- dbConnect(MySQL(), user="genome", db="hg19", host="genome-mysql.cse.ucsc.edu")
allTables <- dbListTables(hg19)
cat("The number of tables in the hg19 database is: ", length(allTables), "\n")
cat("\n")

cat("The names of the first 5 tables are: ", "\n")
print(allTables[1:5])
cat("\n")

#  Now, consider one of the tables in the hg19 database, affyU133Plus2.  Query what fields 
#  exist in this table.  And, query how many observations or lines there are in this table. 

cat("The names of the fields in the affyU133Plus2 table are:", "\n")
flds <- dbListFields(hg19, "affyU133Plus2")
print(flds)
cat("\n")

cat("The number of lines in the affyU133Plus2 table is:", "\n")
lns <- dbGetQuery(hg19, "select count(*) from affyU133Plus2")
print(lns)
cat("\n")

#  Now, read and print the first 6 lines of the affyU133Plus2 table in the hg19 database.  Query this table for entries
#  where the value in the MisMatches field is between 1 and 3.  That is, subset the data 
#  in this database using the given parameter(s).  Calculate the quantiles for this data, 
#  i.e. the records or lines for which MisMatches is between 1 and 3 and return the results.  

affyData <- dbReadTable(hg19, "affyU133Plus2")
hdlns <- head(affyData)
cat("The first 6 lines of the affyU133Plus2 table are:", "\n")
print(hdlns)
cat("\n")

query <- dbSendQuery(hg19, "select * from affyU133Plus2 where MisMatches between 1 and 3")
affyMis <- fetch(query)
qts <- quantile(affyMis$misMatches)
cat("The resulting quantiles are:", "\n")
print(qts)
cat("\n")

#  We probably do not want to return every line in this table.  So, let's just get the
#  first 10 lines to inspect.  Also, good online database "netiquette" says that we 
#  should close out or "clear" queries that we open.  

#  If we printed the return from the "fetch" command it would be "TRUE" but we'll skip
#  that for now.  

affyMisSmall <- fetch(query,n=10); dbClearResult(query);


#  If we want to check some of the details about what we've got we can use the dim()
#  function which is a bit similar to the str() command we've been using.  In this case
#  we have 10 lines so it should tell us that.  And, there are 22 fields (if you counted
#  them when we listed them before).  So, using the dim() function we should get 10 22.

cat("The dimensions of the returned data are (rows, columns)", "\n")
dm <- dim(affyMisSmall)
print(dm)
cat("\n")

#  Always practice good online database "netiquette" cleaning up after your queries and
#  disconnecting when you are finished.  

#  Again, if we printed out the return from the disconnect it would be "TRUE"

dbDisconnect(hg19)

