library(tidyverse)
library(haven)
library(labelled)

survey <- read_sav('~/Downloads/CIRPA Tableau User Group_October 23, 2018_05.58.sav')

question_data <- var_label(survey)
questions <- tibble(field_name = names(question_data),
                    question_text = question_data)

questions <- questions %>% 
  unnest(question_text) %>%
  mutate(question_number = 1:n())

response_data <- survey[18:ncol(survey)]
response_data %>%
  mutate_all(to_character) %>%
  mutate(respondent_id = 1:n()) %>%
  gather(field_name, label, -respondent_id) -> response_label
response_data %>%
  mutate(respondent_id = 1:n()) %>%
  gather(field_name, response, -respondent_id) -> response
response %>%
  inner_join(response_label, by = c('respondent_id', 'field_name')) %>%
  mutate(score = as.numeric(response)) -> responses

responses %>%
  inner_join(questions, by='field_name') -> survey_out

write_csv(survey_out, 'cirpa_tableau_survey.csv')




