import pandas as pd
import janitor

def sample_unspsc_item(p_in, samples_per_group = 1, samples_overall = 100, random_state = 0):
    '''
    helper function to sample samples_per_group number of examples per unspsc code,
    and samples_overall number of codes overall
    
    params
        p_in
            path to the unspsc interim file, i.e.
            data/interim/unspsc-item.csv
    '''
    unspsc_item = pd.read_csv(p_in, dtype=str).clean_names()
    t1 = unspsc_item.groupby("normalized_unspsc")
    t2 = t1.apply(lambda x: x.sample(n = samples_per_group, random_state = 0))
    t3 = t2.reset_index(drop  = True)
    t4 = t3.sample(n = samples_overall, random_state = 0).sort_values(by = "item_name").reset_index(drop  = True)
    results = t4
    return(results)