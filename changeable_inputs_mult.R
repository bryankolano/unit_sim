



#Need to turn whole simulation into a function so that it can be used in Shiny reactive videos
#The two inputs into the function are the number of sims and the gains matrix that is created in the Shiny UI
whole_sim = function(gains, sims){
  
  library(dplyr)              # An opinionated collection of R packages designed for data science.
  library(EnvStats)               # A comprehensive R package for environmental statistics.
  library(tidyr)
  library(ggplot2)
  library(RColorBrewer)
  library(stringr)
  library(forcats)
  
  
  #Read in the data
  df <- readxl::read_xlsx("data_for_sim.xlsx",sheet = 'Sheet3')
  
  
  
  # Establish all your parameters to run the simulation.
  
  prob_uqr = .05        # Probability any officer will leave for a random reason.
  
  col_prob_promo = .25  # Probability an LTC will be picked up for COL
  ltc_prob_promo = .66  # Probability an MAJ will be picked up for LTC
  maj_prob_promo = .80  # Probability a CPT will be picked up for MAJ
  
  new_MAJ_each_year = 2 # Number of new MAJs assessed per year
  new_CPT_each_year = 1 # Number of new CPTs assessed per year
  
  total_years = 10      # Number of years to conduct the simulation
  
  num_of_sims = 5      # Number of times run the monte carlo
  
  # Set a seed for reproducible research.
  set.seed(135)
  
  
  
  #Create list to collect variation in numbers by rank, by year
  #each list element will be a year 1 to 10, and each element will collect number of officers
  #by rank after each year.
  ltc_by_year_grouping = rep(list(NULL),total_years)
  maj_by_year_grouping = rep(list(NULL),total_years)
  cpt_by_year_grouping = rep(list(NULL),total_years)
  
  
  
  
  # Loop across number of simulations.
  for (sim in 1:sims){
    
    # Rename the data set so that it resets itself after every simulation.
    df_copy <- df
    
    
    # Loop across year 1 to total years.
    for(year in 1:total_years){
      
      index_to_remove = c() # holder vector for officers to remove
      
      
      
      # For each officer in our pool, row by row
      for(i in 1:nrow(df_copy)){ 
        
        
        # If someone has at least 20 YOS, enter this if statement
        if(df_copy[i,'YS'] >= 20){
          
          # Check probability of years or service compared to triangular distribution number
          if (df_copy[i,'YS'] >= round(EnvStats::rtri(n =1, min = 20, mode = 22, max = 26))){
            # Append the index number to remove this officer later if officer chooses retirement
            index_to_remove <- append(index_to_remove,i)
            
            # If officer meets criteria, leave this for loop, and go onto next
            next
          }
        }
        
        # Check if LTC has 5 years time in grade, then run random promotion.
        if((df_copy[i,'rank'] == 'LTC') & (df_copy[i,'TIG'] >= 5)){
          
          # Check probability of retire against the random number.
          if (col_prob_promo >= runif(1)){
            # Append the index number to remove this officer later if picked up for promotion.
            index_to_remove <- append(index_to_remove,i)
            
            # If officer meets criteria, leave this for loop, and go onto next.
            next
          }
          
        }
        
        # Check if MAJ is going to be promoted.
        if((df_copy[i,'rank'] == 'MAJ') & (df_copy[i,'TIG'] >= 6)){
          
          # If promotion rate to LTC is greater than random number, then change rank. 
          if (ltc_prob_promo >= runif(1)){
            df_copy[i,'rank'] = 'LTC'
            
          }
        }
        
        # Check if CPT is going to be promoted.
        if((df_copy[i,'rank'] == 'CPT') & (df_copy[i,'TIG'] >= 8)){
          
          # If promotion rate to MAJ is greater than random number, then change rank. 
          if (maj_prob_promo >= runif(1)){
            df_copy[i,'rank'] = 'MAJ'
            
          }
        }
        
        # Remove random UQRs if probability of UQR is higher than random uniform probability.
        if (prob_uqr >= runif(1)){
          index_to_remove <-  append(index_to_remove,i)
          
        }
      }
      
      # Increment all officers by one year of service, and one year time in grade.
      df_copy <- df_copy %>% 
        mutate(YS = YS + 1,
               TIG = TIG + 1)
      
      # Add new CPTs to ranks.
      #In the shiny app, gains is the input matrix in the UI.  So we take the current year, and 
      #the number of CPTs gained that year get added to the pool
      for(j in 1:gains[year,'CPTs']){
        cpt_ys = round(EnvStats::rtri(1, min = 6, max = 11, mode = 8),0)
        new_cpt = tibble(rank ='CPT',
                         YS = cpt_ys, 
                         TIG = cpt_ys - 4)
        df_copy <- bind_rows(df_copy,new_cpt)
      }
      
      # Add new MAJs to ranks.
      #In the shiny app, gains is the input matrix in the UI.  So we take the current year, and 
      #the number of MAJs gained that year get added to the pool
      for(k in 1:gains[year,'MAJs']){
        maj_ys = round(EnvStats::rtri(1, min = 12, max = 18, mode = 15),0)
        new_maj = tibble(rank ='MAJ',
                         YS = maj_ys, 
                         TIG = maj_ys - 12)
        df_copy <- bind_rows(df_copy,new_maj)
      }
      
      # Remove retired officers, promoted to COLs, or UQRs based on the index collected in the loop.
      df_copy <- df_copy %>%
        filter(!row_number() %in% index_to_remove)
      
      
      
      # Count the number of LTCs at the end of each year.
      num_ltc_year_end <- df_copy %>% 
        filter(rank == 'LTC') %>% 
        summarize(n = n()) %>% 
        .[[1]]
      
      # Count the number of MAJs at the end of each year.
      num_maj_year_end <- df_copy %>% 
        filter(rank == 'MAJ') %>% 
        summarize(n = n()) %>% 
        .[[1]]
      
      # Count the number of CPTs at the end of each year.
      num_cpt_year_end <- df_copy %>% 
        filter(rank == 'CPT') %>% 
        summarize(n = n()) %>% 
        .[[1]]
      
      
      
      #these lists below takes each number of each rank, after each year, and appends it to the list.
      #therefore, at the end of n simulations, each list element will have n values that we can use for box plots.
      ltc_by_year_grouping[[year]] <- append(ltc_by_year_grouping[[year]],num_ltc_year_end)
      maj_by_year_grouping[[year]] <- append(maj_by_year_grouping[[year]],num_maj_year_end)
      cpt_by_year_grouping[[year]] <- append(cpt_by_year_grouping[[year]],num_cpt_year_end)
      
    }
    
    
  }
  
  
  
  ## these next three tibbles and the subsequent for loop will take each number of officers by rank per year and append
  ## to list, so at the end of the sims, we can find the exact number of LTCs at year 5 after 5000 sims for example.
  
  
  #Create empty tibbles for collections
  variance_collection_ltc = tibble()
  variance_collection_maj = tibble()
  variance_collection_cpt = tibble()
  
  current_year = 2022
  
  #The ltc_by_year_grouping is a list with 10 elements, one for each year
  # we need to loop through each of these and pull out each year element
  for (j in 1:total_years){
    
    #LTCs
    # for each year, j, pull out that year's list element
    current_list_ltc <- ltc_by_year_grouping[[j]]
    
    #convert the list to a matrix, then a dataframe
    current_run_ltc <- data.frame(matrix(unlist(current_list_ltc), nrow=length(current_list_ltc), byrow=TRUE))
    
    #add rank a year columns, rename weird named column to number
    current_run_ltc <- current_run_ltc %>% 
      mutate(rank = 'LTC', 
             year = current_year + j) %>% 
      rename(number = starts_with('matrix'))
    
    #take previous list of variance_collection_ltc and add append this current iteration to it
    variance_collection_ltc <- bind_rows(variance_collection_ltc,current_run_ltc)
    
    #MAJs
    # for each year, j, pull out that year's list element
    current_list_maj <- maj_by_year_grouping[[j]]
    
    #convert the list to a matrix, then a dataframe
    current_run_maj <- data.frame(matrix(unlist(current_list_maj), nrow=length(current_list_maj), byrow=TRUE))
    
    #add rank a year columns, rename weird named column to number
    current_run_maj <- current_run_maj %>% 
      mutate(rank = 'MAJ', 
             year = current_year + j) %>% 
      rename(number = starts_with('matrix'))
    
    #take previous list of variance_collection_maj and add append this current iteration to it
    variance_collection_maj <- bind_rows(variance_collection_maj,current_run_maj)
    
    #CPTs
    # for each year, j, pull out that year's list element
    current_list_cpt <- cpt_by_year_grouping[[j]]
    
    #convert the list to a matrix, then a dataframe
    current_run_cpt <- data.frame(matrix(unlist(current_list_cpt), nrow=length(current_list_cpt), byrow=TRUE))
    
    #add rank a year columns, rename weird named column to number
    #However, the team decided to combine CPTs and MAJs at the very end for ease of plotting.  
    #Therefore, the current_cpt_run will be given the rank MAJ for plotting purposes
    current_run_cpt <- current_run_cpt %>% 
      mutate(rank = 'MAJ', 
             year = current_year+ j) %>% 
      rename(number = starts_with('matrix'))
    
    #take previous list of variance_collection_cpt and add append this current iteration to it
    variance_collection_cpt <- bind_rows(variance_collection_cpt,current_run_cpt)
    
  }
  
  #take all three of our tibbles, by rank, and row bind them together for one large tibble
  variance_collection_total <- bind_rows(variance_collection_ltc,
                                         variance_collection_maj,
                                         variance_collection_cpt)
  
  return(variance_collection_total)
  
}