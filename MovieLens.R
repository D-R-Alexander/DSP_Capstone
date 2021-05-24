##########################################################
# Create edx set, validation set (final hold-out test set)
##########################################################

# Note: this process could take a couple of minutes

if(!require(tidyverse)) install.packages("tidyverse", repos = "http://cran.us.r-project.org")
if(!require(caret)) install.packages("caret", repos = "http://cran.us.r-project.org")
if(!require(data.table)) install.packages("data.table", repos = "http://cran.us.r-project.org")

library(tidyverse)
library(caret)
library(data.table)

# MovieLens 10M dataset:
# https://grouplens.org/datasets/movielens/10m/
# http://files.grouplens.org/datasets/movielens/ml-10m.zip

dl <- tempfile()
download.file("http://files.grouplens.org/datasets/movielens/ml-10m.zip", dl)

ratings <- fread(text = gsub("::", "\t", readLines(unzip(dl, "ml-10M100K/ratings.dat"))),
                 col.names = c("userId", "movieId", "rating", "timestamp"))

movies <- str_split_fixed(readLines(unzip(dl, "ml-10M100K/movies.dat")), "\\::", 3)
colnames(movies) <- c("movieId", "title", "genres")

# if using R 4.0 or later:
movies <- as.data.frame(movies) %>% mutate(movieId = as.numeric(movieId),
                                           title = as.character(title),
                                           genres = as.character(genres))


movielens <- left_join(ratings, movies, by = "movieId")

# Validation set will be 10% of MovieLens data
set.seed(1, sample.kind="Rounding") # if using R 3.5 or earlier, use `set.seed(1)`
test_index <- createDataPartition(y = movielens$rating, times = 1, p = 0.1, list = FALSE)
edx <- movielens[-test_index,]
temp <- movielens[test_index,]

# Make sure userId and movieId in validation set are also in edx set
validation <- temp %>% 
  semi_join(edx, by = "movieId") %>%
  semi_join(edx, by = "userId")

# Add rows removed from validation set back into edx set
removed <- anti_join(temp, validation)
edx <- rbind(edx, removed)

rm(dl, ratings, movies, test_index, temp, movielens, removed)
#######################################
##### END OF COURSE-PROVIDED CODE #####
#######################################

##### EXPLORATION #####
# What is the average rating
mu <- mean(edx$rating)

# Learned in Pt. 1 that some genres received many more ratings than others
# Explore distribution - quantity of ratings per genre
edx %>% separate_rows(genres, sep = "\\|") %>%
  count(genres) %>%
  ggplot(aes(n)) +
  geom_histogram(bins = 30, color = "black") +
  scale_x_log10() +
  ggtitle("Number of Ratings per Genre")
# Result: Two genres received significantly fewer ratings than the others.
# The majority received 100K or more ratings with 7 of 20 over 1M.

# Explore if positive or negative bias by genre
genre_bias_avg <- edx %>% 
  separate_rows(genres, sep = "\\|") %>%
  group_by(genres) %>% 
  summarize(g_bias = mean(rating - mu))

genre_bias_avg %>%
  ggplot(aes(g_bias)) +
  geom_histogram(bins = 30, color = "black") + 
  ggtitle("Bias of Ratings by Genre")
# Result: More genres ~14 of the 20 received ratings higher than the average

# Learned in Pt. 1 that some some ratings were more common than others
# Explore distribution of ratings
edx %>% 
  group_by(rating) %>%
  ggplot(aes(rating)) +
  geom_histogram(bins = 20, color = "black") +
  scale_x_log10() +
  ggtitle("Distribution of Ratings")
# Result: Majority of ratings are over 3.0

# Explore distribution - quantity of ratings per movie
edx %>% 
  count(movieId) %>%
  ggplot(aes(n)) +
  geom_histogram(bins = 30, color = "black") +
  scale_x_log10() +
  ggtitle("Number of Ratings per Movie")
# Result: Majority of movies received between 50-500 ratings

# Explore distribution - quantity of ratings per user
edx %>% count(userId) %>% 
  ggplot(aes(n)) + 
  geom_histogram(bins = 30, color = "black") + 
  scale_x_log10() + 
  ggtitle("Number of Ratings per User")
# Result: Most raters submitted 100 or fewer ratings.

# Explore rater tendencies
rater_bias_avg <- edx %>% 
  group_by(userId) %>%
  summarize(r_bias = mean(rating - mu))
rater_bias_avg %>%
  ggplot(aes(r_bias)) +
  geom_histogram(bins = 30, color = "black") +
  ggtitle("Rater Tendencies")
# Result: Skewed toward more positive ratings

# Explore if certain movies are rated differently than others
movie_bias_avg <- edx %>% 
  group_by(movieId) %>% 
  summarize(m_bias = mean(rating - mu))

movie_bias_avg %>%
  ggplot(aes(m_bias)) +
  geom_histogram(bins = 30, color = "black") +
  ggtitle("Bias of Ratings by Movie")
# Result: More movies received ratings lower than the average

# Explore how rater tendencies impact movie ratings
r_m_bias_avg <- edx %>% 
  left_join(movie_bias_avg, by = "movieId") %>%
  group_by(userId) %>%
  summarize(r_m_bias = mean(rating - mu - m_bias))
r_m_bias_avg %>%
  ggplot(aes(r_m_bias)) +
  geom_histogram(bins = 30, color = "black") +
  ggtitle("Rater Tendency Impact on Movie Ratings")
# Result shows a standard distribution

##### FUNCTIONS #####

#RMSE
rmse <- function(actualRatings, predictRatings){
  sqrt(mean((actualRatings - predictRatings)^2, na.rm = TRUE))
}

##### BEGIN #####
# Need something to hold and display results
results <- data.frame()

# Develop and Test Models on edx Data

# Model 1 - Naive using only mean rating
m1_rmse <- RMSE(edx$rating,mu)
results <- bind_rows(results, data_frame(model="M1 Naive", finalRMSE = m1_rmse))

# Model 2 - Effect of Genre 
pred_rating_genre <- edx %>%
  separate_rows(genres, sep = "\\|") %>%
  left_join(genre_bias_avg, by = "genres") %>%
  mutate(prediction = mu + g_bias)
m2_rmse <- RMSE(edx$rating,pred_rating_genre$prediction)
results <- bind_rows(results, data_frame(model = "M2 Genre", finalRMSE = m2_rmse))

# Model 3 - Effect of Movie
pred_rating_movie <- edx %>%
  left_join(movie_bias_avg, by = "movieId") %>%
  mutate(prediction = mu + m_bias)
m3_rmse <- RMSE(edx$rating,pred_rating_movie$prediction)
results <- bind_rows(results, data_frame(model = "M3 Movie", finalRMSE = m3_rmse))

# Model 4 - Effect of Rater
pred_rating_rater <- edx %>%
  left_join(rater_bias_avg, by = "userId") %>%
  mutate(prediction = mu + r_bias)
m4_rmse <- RMSE(edx$rating,pred_rating_rater$prediction)
results <- bind_rows(results, data_frame(model = "M4 Rater", finalRMSE = m4_rmse))


# Model 5 - Effect of Rater and Movie
pred_rating_r_m <- edx %>%
  left_join(movie_bias_avg, by = "movieId") %>%
  left_join(r_m_bias_avg, by = "userId") %>%
  mutate(prediction = mu + m_bias + r_m_bias)
m5_rmse <- RMSE(edx$rating,pred_rating_r_m$prediction)
results <- bind_rows(results, data_frame(model = "M5 Rater and Movie", finalRMSE = m5_rmse))

results

# Test on Validation Set 

pred_rating_final <- validation %>%
  left_join(movie_bias_avg, by = "movieId") %>%
  left_join(r_m_bias_avg, by = "userId") %>%
  mutate(prediction = mu + m_bias + r_m_bias)
finalResult <- RMSE(validation$rating,pred_rating_final$prediction)

finalResult
