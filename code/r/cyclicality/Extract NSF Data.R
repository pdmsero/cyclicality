library(rvest)
library(stringr)

# Destination folder
base_path <- "G:\\My Drive\\Work\\Academia\\Research\\Papers\\Cyclicality of R&D at the Firm Level\\R Version\\Data\\NSF"

# Initialize an empty vector to store folder paths
destination_folder <- vector("character", length = 28)

# Loop through numbers 1 to 28
for (i in 1:27) {
  # Create folder name with index
  folder_name <- paste0("index_", i)
  folder_path <- file.path(base_path, folder_name)
  
  # Store the folder path in the vector
  destination_folder[i] <- folder_path
  
  # Check if the folder exists
  if (!dir.exists(folder_path)) {
    # Create the folder if it does not exist
    dir.create(folder_path, recursive = TRUE)
    cat("Folder created at:", folder_path, "\n")
  } else {
    cat("Folder already exists at:", folder_path, "\n")
  }
}

folder_number<-length(destination_folder)

# Loop over each website URL and destination folder
for (indx in 1:folder_number) {
  # Construct the website URL
  website_url <- paste0("https://wayback.archive-it.org/5902/20181004145029/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=", indx)
  
  # Read the HTML content of the webpage
  webpage <- read_html(website_url)
  
  # Extract all links from the webpage
  links <- webpage %>% html_nodes("a")
  
  # Filter links that end with ".xls" or ".xlsx"
  xls_links <- links %>%
    html_attr("href") %>%
    grep("\\.xls$|\\.xlsx$", ., ignore.case = TRUE, value = TRUE)
  
  # Convert relative URLs to absolute URLs
  absolute_xls_links <- purrr::map_chr(xls_links, ~url_absolute(website_url, .))
  
  # Print the full URLs
  cat("Full URLs for XLS files at indx=", indx, ":\n")
  cat(absolute_xls_links, sep = "\n")
  
  # Concatenate base URL with relative links
  base_string <- "https://wayback.archive-it.org/5902/20181004145029/https://www.nsf.gov/statistics/iris/"
  combined_strings <- vector(length = length(xls_links))
  
  for (i in 1:length(xls_links)) {
    combined_strings[i] <- paste0(base_string, xls_links[i])
  }
  
  # Loop through URLs and download files to the corresponding destination folder
  for (url in combined_strings) {
    # Construct destination path
    destination <- file.path(destination_folder[indx], paste0(basename(dirname(url)), basename(url)))
    
    # Download the file
    download.file(url, destfile = destination, mode = "wb")
    
    # Print status
    cat("Downloaded:", basename(url), "to", destination_folder[indx], "\n")
  }
}











# SAFE CODE

## URL of the webpage containing XLS links
website_url <- "https://wayback.archive-it.org/5902/20181004145029/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=1"

# Read the HTML content of the webpage
webpage <- read_html(website_url)

# Extract all links from the webpage
links <- webpage %>% html_nodes("a")

# Filter links that end with ".xls" or ".xlsx"
xls_links <- links %>%
  html_attr("href") %>%
  grep("\\.xls$|\\.xlsx$", ., ignore.case = TRUE, value = TRUE)

# Convert relative URLs to absolute URLs
absolute_xls_links <- purrr::map_chr(xls_links, ~url_absolute(website_url, .))

# Print the full URLs
cat("Full URLs for XLS files:\n")
cat(absolute_xls_links, sep = "\n")

base_string <- "https://wayback.archive-it.org/5902/20181004145029/https://www.nsf.gov/statistics/iris/"

combined_strings <- vector(length = length(xls_links))  # Create an empty vector to store results

for (i in 1:length(xls_links)) {
  combined_strings[i] <- paste0(base_string, xls_links[i])  # Use paste0 for concatenation without spaces
}

print(combined_strings)

# Loop through URLs and download files
for (url in combined_strings) {
  # Construct destination path
  destination <- file.path(destination_folder, paste0(basename(dirname(url)),basename(url)))
  
  # Download the file
  download.file(url, destfile = destination, mode = "wb")
  
  # Print status
  cat("Downloaded:", basename(url), "\n")
}





https://wayback.archive-it.org/5902/20181004145029/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=2
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=3
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=4
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=5
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=6
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=7
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=8
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=9
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=10
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=11
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=12
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=13
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=14
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=15
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=16
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=17
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=18
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=19
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=20
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=21
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=22
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=23
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=24
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=25
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=26
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=27
https://wayback.archive-it.org/5902/20181004030254/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=28