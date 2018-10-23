library(tidyverse)
library(haven)
library(labelled)

source('bad_word_list.R')

survey <- read_sav('~/Downloads/CIRPA Tableau User Group_October 23, 2018_08.50.sav')

survey_questions_only <- survey[18:ncol(survey)]

question_data <- var_label(survey_questions_only)
questions <- tibble(field_name = names(question_data),
                    question_text = question_data)

questions <- questions %>% 
  unnest(question_text) %>%
  mutate(question_number = 1:n())

survey_questions_only %>%
  mutate_all(to_character) %>%
  mutate(respondent_id = 1:n()) %>%
  gather(field_name, label, -respondent_id) %>%
  mutate(lower_label = tolower(label)) -> response_label
survey_questions_only %>%
  mutate(respondent_id = 1:n()) %>%
  gather(field_name, response, -respondent_id) -> response_original
response_original %>%
  inner_join(response_label, by = c('respondent_id', 'field_name')) %>%
  mutate(score = as.numeric(response)) %>%
  filter(!is.na(response)) %>%
  filter(response!='') -> responses

responses %>%
  inner_join(questions, by='field_name') -> survey_out

write_csv(survey_out, 'cirpa_tableau_survey.csv')




