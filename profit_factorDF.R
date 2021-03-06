
#===============================
# PROFIT FACTOR FUNCTION
#===============================
# function that returns the profit factors of the systems in a form of DataFrame
#
# x - data frame with orders
#     df must contain MagicNumber and Profit columns!
# x <- read_rds("test_data_profit_factorDF.rds")
# numOrders - desired number of orders to base profit factor calculation
# numOrders <- 10
#
profit_factorDF <- function(x, numOrders){
  # generate DF with only MagicNumbers when > 10 trades and all trades are losers
  DF_L <- x %>%
    group_by(MagicNumber) %>%
    summarise(nOrders = n())%>%
    filter(nOrders > numOrders)%>%
    select(MagicNumber)%>%
    # subset only rows that contans magic numbers from x
    inner_join(x, by = "MagicNumber")%>%
    group_by(MagicNumber)%>%
    filter(Profit < 0) %>%
    summarise(Loss = abs(sum(Profit)))
  # generate DF with only MagicNumbers when > 10 trades and all trades are profits
  DF_P <- x %>%
    group_by(MagicNumber) %>%
    summarise(nOrders = n())%>%
    filter(nOrders > numOrders)%>%
    select(MagicNumber)%>%
    # subset only rows that contans magic numbers from x
    inner_join(x, by = "MagicNumber")%>%
    group_by(MagicNumber)%>%
    filter(Profit > 0) %>%
    summarise(Gain = abs(sum(Profit)))
  # generate DF containing profit factor of all systems
  DF <- DF_P %>%
    full_join(DF_L, by = "MagicNumber")
  # replace any NA with 1!
  DF[is.na(DF)] <- 1
  # calculate profit factors of the each system!
  DF_PF <- DF%>%
    group_by(MagicNumber)%>%
    mutate(PrFact = Gain/(0.001+Loss))%>%
    select(MagicNumber, PrFact)
  return(DF_PF)
}
