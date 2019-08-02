import pandas as pd
import janitor

def sample_unspsc_item(unspsc_items, samples_per_group = 1, samples_overall = 100, random_state = 0):
    '''
    helper function to sample samples_per_group number of examples per unspsc code,
    and samples_overall number of codes overall
    
    params
        unspsc_items
            the data frame that contains the unspsc_items
    '''
    t1 = unspsc_items.groupby("normalized_unspsc")
    t2 = t1.apply(lambda x: x.sample(n = samples_per_group, random_state = 0, replace = True))
    t3 = t2.reset_index(drop  = True)
    t4 = t3.sample(n = samples_overall, random_state = 0).sort_values(by = "item_name").reset_index(drop  = True)
    results = t4
    return(results)