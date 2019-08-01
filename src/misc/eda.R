# prelim exploration of the data


library(here)
library(dplyr)
library(readr)
library(janitor)
library(ggplot2)

p_po <- here::here("data", "external", "ca-po", "PURCHASE ORDER DATA EXTRACT 2012-2015 CLEANED.csv")

po <- read_csv(p_po, col_types = cols(.default = "c")) %>% 
    clean_names()

po %>% nrow() # 344504 rows

po %>% str()

po %>% summary()

po %>% colnames()

po %>% count(requisition_number, sort = TRUE)

po %>% count(purchase_order_number, sort = TRUE)

po %>% count(purchase_date, sort = TRUE)

po %>% count(creation_date, sort = TRUE)

po %>% count(acquisition_type, sort = TRUE)

po %>% count(sub_acquisition_type, sort = TRUE)

po %>% count(acquisition_method, sort = TRUE)

po %>% count(sub_acquisition_method, sort = TRUE)

po %>% count(department_name, sort = TRUE)

po %>% count(supplier_code, sort = TRUE)

po %>% count(supplier_name, sort = TRUE)

po %>% count(supplier_zip_code, sort = TRUE)

po %>% count(normalized_unspsc, sort = TRUE)
po %>% count(is.na(normalized_unspsc))

po %>% count(commodity_title, sort = TRUE)

po %>% count(classification_codes, sort = TRUE)

po %>% count(class, sort = TRUE)

po %>% count(class_title, sort = TRUE)

po %>% count(family, sort = TRUE)

po %>% count(family_title, sort = TRUE)

po %>% count(segment, sort = TRUE)

po %>% count(segment_title, sort = TRUE)

# po %>% count(location, sort = TRUE)

# po %>% count(remove_amerisource, sort = TRUE)

# po %>% count(cal_card, sort = TRUE)




# can we use any of this data to simulate company items and descriptions?
po %>% count(item_name, sort = TRUE)

po %>% count(item_description, sort = TRUE)


# number of unique items
po %>% distinct(item_name) %>% nrow() # 179626

# number of unique item descriptions
po %>% distinct(item_description) %>% nrow() # 218691


# looks at the item name and descriptions
po %>% select(item_name, item_description) %>% sample_n(100) %>% View()

# ... how many items vs descriptions are exactly the same?
t1 <- po %>% 
    select(item_name, item_description) %>% 
    mutate(is_same = (item_name == item_description))
t1 %>% count(is_same)

# ... what is the edit distance between the name and description?
t2 <- t1 %>% 
    rowwise() %>% 
    mutate(ed = adist(item_name, item_description))
t2 %>% pull(ed) %>% hist()
t2 %>% 
    ggplot(aes(x = ed)) + 
    geom_histogram() + 
    geom_vline(xintercept = median(t2$ed, na.rm = TRUE), color = "red") +
    labs(
        title = "most item names and descriptions are quite similar"
        , subtitle = paste0("median edit distance ", median(t2$ed, na.rm = TRUE))
        , x = "edit distance"
    ) +
    scale_y_log10() 
t2 %>% count(ed, sort = TRUE)
t2 %>% select(ed) %>% summary

t2 %>% filter(ed == 0) %>% sample_n(100)
t2 %>% filter(ed > 1 & ed < 26) %>% sample_n(100)
t2 %>% filter(ed > 26) %>% sample_n(100)

# ... categorize them into bins by how different they are
qt <- quantile(t2$ed, na.rm = TRUE) %>% unique() %>% append(1e9)
t3 <- t2 %>% mutate(ct = cut(ed, breaks = qt, right = FALSE))
t3 %>% count(ct)




# items and unspsc ?
po %>% 
    distinct(normalized_unspsc, item_name, item_description) %>% 
    arrange(item_name, normalized_unspsc) %>% 
    View()

po %>% 
    distinct(normalized_unspsc, item_name, item_description) %>% 
    arrange(normalized_unspsc, item_name) %>% 
    View()


# ... how many examples do we have for each unspsc code?
po %>% 
    distinct(normalized_unspsc, item_name, item_description) %>% 
    count(normalized_unspsc, sort = TRUE) %>% 
    View("unspsc_counts")

t1 <- po %>% 
    distinct(normalized_unspsc, item_name) %>% 
    count(normalized_unspsc, sort = TRUE)
t1 %>% View("unspsc_counts_item_name")
t1 %>% pull(n) %>% hist()
t1$n %>% median()
t1$n %>% summary()
# ... the average unspsc code has about 3 examples
# ... most unspsc codes only have 1 to 11 
t1 %>% 
    ggplot(aes(x = n)) + 
    geom_histogram() + 
    geom_vline(xintercept = median(t1$n, na.rm = TRUE), color = "red") +
    labs(
        title = "most unspsc codes only have a few unique examples"
        , subtitle = paste0("median number of unique items per unspsc code ", median(t1$n, na.rm = TRUE))
        , x = "number of items"
    ) +
    scale_y_log10() 







# class is the unique id for and class title
po %>% 
    distinct(class, class_title) %>% 
    count(class, sort = TRUE) %>% 
    filter(n > 1) %>% 
    nrow() == 0

# family is the unique id for family title
po %>% 
    distinct(family, family_title) %>% 
    count(family, sort = TRUE) %>% 
    filter(n > 1) %>% 
    nrow() == 3

# ... three codes have duplicates that might be mis-codings
po %>% 
    distinct(family, family_title) %>% 
    filter(family %in% c("30100000", "31180000", "72150000" )) %>% 
    arrange(family)


# segment is the unique id for segment title
po %>% 
    distinct(segment, segment_title) %>% 
    count(segment, sort = TRUE) %>% 
    filter(n > 1) %>% 
    nrow() == 0




# whats the relationship between segment, family, and class?
po %>% 
    distinct(segment, segment_title, family, family_title, class, class_title) %>% 
    arrange(segment, family, class) %>% 
    View()
# ... by visual inspection, it looks like a hierarchial classification structure: segment > family > class
# ... note the actual numbers for segment, family, and class have this ###, ###, ### structure too



# whats the relationship between classification codes and the hierarchy?
po %>% 
    distinct(classification_codes, segment, segment_title, family, family_title, class, class_title) %>% 
    arrange(segment, family, class) %>% 
    View()
# ... looks kind of odd, some reqs seem to have more than one classification codes



# whats the relationship between req, item, and the various classifications?
po %>% 
    select(requisition_number, purchase_order_number, item_name, item_description, normalized_unspsc, classification_codes, segment, segment_title, family, family_title, class, class_title) %>% 
    arrange(requisition_number, purchase_order_number, item_name, segment, family, class) %>% 
    View()



# whats the relationship between pr and po?
# ... generally pr preceeds po, but not always
# ... sometimes it looks like there can be a po with no pr
# ... sometimes a single pr is associated with multiple po
# ... sometimes a single po is associated with multiple pr
po %>% 
    select(requisition_number, purchase_order_number) %>% 
    arrange(requisition_number, purchase_order_number) %>% 
    View()

po %>% 
    distinct(requisition_number, purchase_order_number) %>% 
    arrange(requisition_number, purchase_order_number) %>% 
    View()

po %>% 
    distinct(requisition_number, purchase_order_number) %>% 
    count(requisition_number, sort = TRUE)

po %>% 
    distinct(requisition_number, purchase_order_number) %>% 
    count(purchase_order_number, sort = TRUE)




