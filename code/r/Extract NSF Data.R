library(rvest)
library(stringr)

# Specify the URL of the webpage containing the XLS files
url <- "https://wayback.archive-it.org/5902/20181004145029/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=1"

# Read the HTML content of the webpage
webpage <- read_html(url)

# Extract all links from the webpage
links <- webpage %>% html_nodes("a") %>% html_attr("href")

# Filter links that end with ".xls" or ".xlsx"
xls_links <- links[str_detect(links, "\\.xls$|\\.xlsx$")]

# Specify the directory where you want to save the downloaded files
download_dir <- "G:\\My Drive\\Work\\Academia\\Research\\Papers\\Cyclicality of R&D at the Firm Level\\R Version\\Data\\NSF\\"

# Download each XLS file
for (xls_link in xls_links) {
  xls_url <- ifelse(startsWith(xls_link, "http"), xls_link, paste0(url, xls_link))
  xls_name <- str_extract(xls_link, "[^/]+\\.xls$")
  xls_path <- file.path(download_dir, xls_name)
  
  # Download the file
  download.file(xls_url, xls_path, mode = "wb")
  
  cat("Downloaded:", xls_name, "\n")
}

url <- "https://wayback.archive-it.org/5902/20181004145029/https://www.nsf.gov/statistics/iris/excel-files/nsf_2007/32.xls"
destination <- "G:\\My Drive\\Work\\Academia\\Research\\Papers\\Cyclicality of R&D at the Firm Level\\R Version\\Data\\NSF\\32.xls"
download.file(url, destfile = destination, mode = "wb")


website_url <- "https://wayback.archive-it.org/5902/20181004145029/https://www.nsf.gov/statistics/iris/search_hist.cfm?indx=1"

htmlcode = read_html(website_url)
nodes=html_nodes(htmlcode,xpath='//*[contains(@href, "xls")]') %>% html_attr("href")
df=as.data.frame(as.character(nodes))
names(df)="link"








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

# Destination folder
destination_folder <- "G:\\My Drive\\Work\\Academia\\Research\\Papers\\Cyclicality of R&D at the Firm Level\\R Version\\Data\\NSF"

# Loop through URLs and download files
for (url in urls) {
  # Construct destination path
  destination <- file.path(destination_folder, basename(url))
  
  # Download the file
  download.file(url, destfile = destination, mode = "wb")
  
  # Print status
  cat("Downloaded:", basename(url), "\n")
}